const std = @import("std");
const raw_input = @embedFile("input.txt");

const example =
    \\p=0,4 v=3,-3
    \\p=6,3 v=-1,-3
    \\p=10,3 v=-1,2
    \\p=2,0 v=2,-1
    \\p=0,0 v=1,3
    \\p=3,0 v=-2,-2
    \\p=7,6 v=-1,-3
    \\p=3,0 v=-1,-2
    \\p=9,3 v=2,3
    \\p=7,3 v=-1,2
    \\p=2,4 v=2,-3
    \\p=9,5 v=-3,-3
;

const Allocator = std.mem.Allocator;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    var input: Input = try parseInput(allocator, raw_input);
    defer input.deinit();
    const space = Position{ 101, 103 };
    const result_1 = try part1(input, space);
    std.debug.print("Part 1: {}\n", .{result_1});
    const result_2 = try part2(input, space);
    std.debug.print("Part 2: {}\n", .{result_2});
}

const Input = struct {
    data: []Robot,
    allocator: Allocator,
    fn deinit(self: *Input) void {
        self.allocator.free(self.data);
    }
};

fn parseInput(allocator: Allocator, str: []const u8) !Input {
    var data = std.ArrayList(Robot).init(allocator);
    defer data.deinit();
    var lines = std.mem.tokenizeScalar(u8, str, '\n');
    while (lines.next()) |line| {
        var tokens = std.mem.tokenizeAny(u8, line, "pv=, ");
        const p = Position{ try std.fmt.parseInt(isize, tokens.next().?, 10), try std.fmt.parseInt(isize, tokens.next().?, 10) };
        const v = Velocity{ try std.fmt.parseInt(isize, tokens.next().?, 10), try std.fmt.parseInt(isize, tokens.next().?, 10) };
        try data.append(Robot{ .p = p, .v = v });
    }
    return .{ .data = try data.toOwnedSlice(), .allocator = allocator };
}

test parseInput {
    const allocator = std.testing.allocator;
    var input = try parseInput(allocator, example);
    defer input.deinit();
    try std.testing.expectEqual(12, input.data.len);
}

fn part1(input: Input, space: Position) !u64 {
    var result = @as(@Vector(4, u64), @splat(0));
    const robots = try input.allocator.dupe(Robot, input.data);
    defer input.allocator.free(robots);
    for (robots) |*robot| {
        robot.move(space, 100);
        const x = @divFloor(space, @as(Position, @splat(2)));
        if (@reduce(.Or, robot.p == x)) continue;
        const q = robot.p > x;
        const i: usize = 2 * @as(usize, @intFromBool(q[0])) + @as(usize, @intFromBool(q[1]));
        result[i] += 1;
    }
    return @reduce(.Mul, result);
}

test part1 {
    const allocator = std.testing.allocator;
    var input = try parseInput(allocator, example);
    defer input.deinit();
    const space = Position{ 11, 7 };
    try std.testing.expectEqual(12, try part1(input, space));
}

fn part2(input: Input, space: Position) !u64 {
    var result: u64 = 0;
    const robots = try input.allocator.dupe(Robot, input.data);
    defer input.allocator.free(robots);
    std.debug.print("Starting...\n", .{});
    var map = std.AutoHashMap(Position, void).init(input.allocator);
    defer map.deinit();
    var triangle_size: isize = 4;
    while (true) {
        result += 1;
        std.debug.print("\x1B[1F\x1B[2KLoop #{}\n", .{result});
        map.clearAndFree();
        for (robots) |*robot| {
            robot.move(space, 1);
            try map.put(robot.p, {});
        }
        var keys = map.keyIterator();
        while (keys.next()) |k| {
            var d: isize = 1;
            while (map.contains(k.* + Position{ d, d }) and map.contains(k.* + Position{ -d, d })) : (d += 1) {}
            if (d >= triangle_size) {
                triangle_size = d;
                break;
            }
        } else continue;
        try printAlloc(input.allocator, robots, space);
        {
            std.debug.print("\nStop? (y/N) ", .{});
            var stdin = std.io.getStdIn();
            var buf: [1]u8 = undefined;
            _ = try stdin.read(&buf);
            if (buf[0] == 'Y' or buf[0] == 'y') break;
        }
    }
    return result;
}

test part2 {
    const allocator = std.testing.allocator;
    var input = try parseInput(allocator, example);
    defer input.deinit();
    // try std.testing.expectEqual(undefined, try part2(input));
}

const Position = @Vector(2, isize);
const Velocity = @Vector(2, isize);
const Robot = struct {
    p: Position,
    v: Velocity,
    fn move(self: *Robot, space: Position, n: isize) void {
        self.p = @mod(self.p + self.v * @as(@Vector(2, isize), @splat(n)), space);
    }
};

fn printAlloc(allocator: Allocator, robots: []Robot, space: Position) !void {
    const buf = try allocator.alloc(u8, @as(usize, @intCast(@reduce(.Mul, space))));
    defer allocator.free(buf);
    @memset(buf, ' ');
    for (robots) |robot| {
        const i = @as(usize, @intCast(robot.p[1] * space[0] + robot.p[0]));
        buf[i] = '*';
    }
    for (0..@as(usize, @intCast(space[1]))) |i| {
        const start = i * @as(usize, @intCast(space[0]));
        const end = start + @as(usize, @intCast(space[0]));
        std.debug.print("{s}\n", .{buf[start..end]});
    }
}
