const std = @import("std");
const raw_input = @embedFile("input.txt");

const example =
    \\............
    \\........0...
    \\.....0......
    \\.......0....
    \\....0.......
    \\......A.....
    \\............
    \\............
    \\........A...
    \\.........A..
    \\............
    \\............
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
    data: std.AutoHashMap(Position, u8),
    allocator: Allocator,
    fn deinit(self: *Input) void {
        self.data.deinit();
    }
};

fn parseInput(allocator: Allocator, str: []const u8) !Input {
    var map = std.AutoHashMap(Position, u8).init(allocator);
    errdefer map.deinit();
    var iter = std.mem.tokenizeScalar(u8, str, '\n');
    var y: isize = 0;
    while (iter.next()) |line| : (y += 1) {
        for (0.., line) |x, c| {
            const p = Position{ @intCast(x), y };
            try map.put(p, c);
        }
    }
    return .{ .data = map, .allocator = allocator };
}

test parseInput {
    const allocator = std.testing.allocator;
    var input = try parseInput(allocator, example);
    defer input.deinit();
    try std.testing.expectEqual(144, input.data.count());
}

fn part1(allocator: Allocator, input: Input) !u32 {
    var groups_map = std.AutoHashMap(u8, std.ArrayList(Position)).init(allocator);
    defer {
        var values = groups_map.valueIterator();
        while (values.next()) |value| {
            value.deinit();
        }
        groups_map.deinit();
    }
    {
        var entries = input.data.iterator();
        while (entries.next()) |entry| {
            if (entry.value_ptr.* == '.') continue;
            const gop = try groups_map.getOrPut(entry.value_ptr.*);
            if (!gop.found_existing) gop.value_ptr.* = std.ArrayList(Position).init(allocator);
            try gop.value_ptr.append(entry.key_ptr.*);
        }
    }
    var antinode_map = std.AutoHashMap(Position, void).init(allocator);
    defer antinode_map.deinit();
    {
        var groups = groups_map.valueIterator();
        while (groups.next()) |group| {
            const items = group.items;
            for (items) |self| {
                for (items) |other| {
                    if (@reduce(.And, self == other)) continue;
                    const antinode = self + (self - other);
                    if (input.data.contains(antinode)) try antinode_map.put(antinode, {});
                }
            }
        }
    }
    return antinode_map.count();
}

test part1 {
    const allocator = std.testing.allocator;
    var input = try parseInput(allocator, example);
    defer input.deinit();
    try std.testing.expectEqual(14, try part1(allocator, input));
}

fn part2(allocator: Allocator, input: Input) !u32 {
    var groups_map = std.AutoHashMap(u8, std.ArrayList(Position)).init(allocator);
    defer {
        var values = groups_map.valueIterator();
        while (values.next()) |value| {
            value.deinit();
        }
        groups_map.deinit();
    }
    {
        var entries = input.data.iterator();
        while (entries.next()) |entry| {
            if (entry.value_ptr.* == '.') continue;
            const gop = try groups_map.getOrPut(entry.value_ptr.*);
            if (!gop.found_existing) gop.value_ptr.* = std.ArrayList(Position).init(allocator);
            try gop.value_ptr.append(entry.key_ptr.*);
        }
    }
    var antinode_map = std.AutoHashMap(Position, void).init(allocator);
    defer antinode_map.deinit();
    {
        var groups = groups_map.valueIterator();
        while (groups.next()) |group| {
            const items = group.items;
            for (items) |self| {
                for (items) |other| {
                    if (@reduce(.And, self == other)) continue;
                    const diff = self - other;
                    var antinode = other;
                    while (true) {
                        antinode += diff;
                        if (input.data.contains(antinode)) try antinode_map.put(antinode, {}) else break;
                    }
                }
            }
        }
    }
    return antinode_map.count();
}

test part2 {
    const allocator = std.testing.allocator;
    var input = try parseInput(allocator, example);
    defer input.deinit();
    try std.testing.expectEqual(34, try part2(allocator, input));
}

const Position = @Vector(2, isize);
