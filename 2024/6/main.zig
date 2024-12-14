const std = @import("std");
const raw_input = @embedFile("input.txt");

const example =
    \\....#.....
    \\.........#
    \\..........
    \\..#.......
    \\.......#..
    \\..........
    \\.#..^.....
    \\........#.
    \\#.........
    \\......#...
;

const Allocator = std.mem.Allocator;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    var input: Input = try parseInput(allocator, raw_input);
    defer input.deinit();
    const result_1 = try part1(allocator, input);
    std.debug.print("Part 1: {}\n", .{result_1});
    const result_2 = try part2(allocator, input);
    std.debug.print("Part 2: {}\n", .{result_2});
}

const Input = struct {
    data: struct { map: std.AutoHashMap(Position, u8), start: Guard },
    allocator: Allocator,
    fn deinit(self: *Input) void {
        self.data.map.deinit();
    }
};

fn parseInput(allocator: Allocator, str: []const u8) !Input {
    var map = std.AutoHashMap(Position, u8).init(allocator);
    errdefer map.deinit();
    var start: Guard = undefined;
    var iter = std.mem.tokenizeScalar(u8, str, '\n');
    var y: usize = 0;
    while (iter.next()) |line| : (y += 1) {
        for (0.., line) |x, c| {
            const p = Position{ .x = x, .y = y };
            if (c == '^') start = .{ .pos = p, .dir = .Up };
            try map.put(p, c);
        }
    }
    return .{ .data = .{ .map = map, .start = start }, .allocator = allocator };
}

test parseInput {
    const allocator = std.testing.allocator;
    var input = try parseInput(allocator, example);
    defer input.deinit();
    try std.testing.expectEqual(100, input.data.map.count());
}

fn part1(allocator: Allocator, input: Input) !u32 {
    const map = input.data.map;
    const start = input.data.start;
    var paths = std.ArrayList(Position).init(allocator);
    defer paths.deinit();
    try paths.append(start.pos);
    var current = Guard{ .pos = start.pos, .dir = start.dir };
    while (current.move(map)) {
        for (paths.items) |item| {
            if (std.meta.eql(item, current.pos)) break;
        } else try paths.append(current.pos);
        if (std.meta.eql(start, current)) break;
    }
    return @intCast(paths.items.len);
}

test part1 {
    const allocator = std.testing.allocator;
    var input = try parseInput(allocator, example);
    defer input.deinit();
    try std.testing.expectEqual(41, try part1(allocator, input));
}

fn part2(allocator: Allocator, input: Input) !u32 {
    const map = input.data.map;
    const start = input.data.start;
    const obstacles = blk: {
        var paths = std.ArrayList(Position).init(allocator);
        defer paths.deinit();
        var current = Guard{ .pos = start.pos, .dir = start.dir };
        while (current.move(map)) {
            if (std.meta.eql(start, current)) break;
            for (paths.items) |item| {
                if (std.meta.eql(item, current.pos)) break;
            } else try paths.append(current.pos);
        }
        break :blk try paths.toOwnedSlice();
    };
    defer allocator.free(obstacles);
    var result: u32 = 0;
    for (obstacles) |obs| {
        var mod_map = try map.clone();
        defer mod_map.deinit();
        try mod_map.put(obs, '#');
        var trails = std.AutoHashMap(Guard, void).init(allocator);
        defer trails.deinit();
        var current = Guard{ .pos = start.pos, .dir = start.dir };
        try trails.put(current, {});
        while (current.move(mod_map)) {
            if (trails.contains(current)) {
                result += 1;
                break;
            } else try trails.put(current, {});
        }
    }

    return result;
}

test part2 {
    const allocator = std.testing.allocator;
    var input = try parseInput(allocator, example);
    defer input.deinit();
    try std.testing.expectEqual(6, try part2(allocator, input));
}

const Position = struct {
    x: usize,
    y: usize,
};

const Direction = enum { Up, Down, Left, Right };

const Guard = struct {
    pos: Position,
    dir: Direction,
    fn move(self: *Guard, map: std.AutoHashMap(Position, u8)) bool {
        const p: Position = switch (self.dir) {
            .Up => if (self.pos.y > 0) .{ .x = self.pos.x, .y = self.pos.y - 1 } else return false,
            .Down => .{ .x = self.pos.x, .y = self.pos.y + 1 },
            .Left => if (self.pos.x > 0) .{ .x = self.pos.x - 1, .y = self.pos.y } else return false,
            .Right => .{ .x = self.pos.x + 1, .y = self.pos.y },
        };
        const c = map.get(p) orelse return false;
        if (c == '#') {
            self.turn();
            return self.move(map);
        } else {
            self.pos = p;
            return true;
        }
    }
    fn turn(self: *Guard) void {
        self.dir = switch (self.dir) {
            .Up => .Right,
            .Down => .Left,
            .Right => .Down,
            .Left => .Up,
        };
    }
};
