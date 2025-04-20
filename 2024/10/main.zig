const std = @import("std");
const raw_input = @embedFile("input.txt");

const example =
    \\89010123
    \\78121874
    \\87430965
    \\96549874
    \\45678903
    \\32019012
    \\01329801
    \\10456732
;

const Allocator = std.mem.Allocator;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    var input: Input = try parseInput(allocator, raw_input);
    defer input.deinit();
    const result_1 = try part1(input);
    std.debug.print("Part 1: {}\n", .{result_1});
    const result_2 = try part2(input);
    std.debug.print("Part 2: {}\n", .{result_2});
}

const Input = struct {
    data: std.AutoHashMap(Position, u8),
    allocator: Allocator,
    fn deinit(self: *Input) void {
        self.data.deinit();
    }
};

fn parseInput(allocator: Allocator, str: []const u8) !Input {
    var data = std.AutoHashMap(Position, u8).init(allocator);
    var lines = std.mem.tokenizeScalar(u8, str, '\n');
    var y: isize = 0;
    while (lines.next()) |line| : (y += 1) {
        for (0.., line) |x, c| {
            try data.put(.{ @intCast(x), y }, c - 48);
        }
    }
    return .{ .data = data, .allocator = allocator };
}

test parseInput {
    const allocator = std.testing.allocator;
    var input = try parseInput(allocator, example);
    defer input.deinit();
    try std.testing.expectEqual(64, input.data.count());
}

fn part1(input: Input) !u32 {
    const allocator = input.allocator;
    var result: u32 = 0;
    var entries = input.data.iterator();
    while (entries.next()) |entry| {
        if (entry.value_ptr.* != 0) continue;
        var peaks = std.AutoHashMap(Position, void).init(allocator);
        defer peaks.deinit();
        var queue = std.ArrayList(Position).init(allocator);
        defer queue.deinit();
        try queue.append(entry.key_ptr.*);
        while (queue.pop()) |p| {
            const h = input.data.get(p).?;
            for (orthogonals) |d| {
                const q = p + d;
                if (input.data.get(q)) |c| {
                    if (c > h and c - h == 1) {
                        if (c == 9) try peaks.put(q, {}) else try queue.append(q);
                    }
                }
            }
        }
        result += peaks.count();
    }
    return result;
}

test part1 {
    const allocator = std.testing.allocator;
    var input = try parseInput(allocator, example);
    defer input.deinit();
    try std.testing.expectEqual(36, try part1(input));
}

fn part2(input: Input) !u64 {
    const allocator = input.allocator;
    var result: u32 = 0;
    var entries = input.data.iterator();
    while (entries.next()) |entry| {
        if (entry.value_ptr.* != 0) continue;
        var queue = std.ArrayList(Position).init(allocator);
        defer queue.deinit();
        try queue.append(entry.key_ptr.*);
        while (queue.pop()) |p| {
            const h = input.data.get(p).?;
            for (orthogonals) |d| {
                const q = p + d;
                if (input.data.get(q)) |c| {
                    if (c > h and c - h == 1) {
                        if (c == 9) result += 1 else try queue.append(q);
                    }
                }
            }
        }
    }
    return result;
}

test part2 {
    const allocator = std.testing.allocator;
    var input = try parseInput(allocator, example);
    defer input.deinit();
    try std.testing.expectEqual(81, try part2(input));
}

const Position = @Vector(2, isize);
const orthogonals = [_]Position{ .{ 0, -1 }, .{ 0, 1 }, .{ -1, 0 }, .{ 1, 0 } };
