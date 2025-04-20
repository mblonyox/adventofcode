const std = @import("std");
const raw_input = @embedFile("input.txt");

const example =
    \\RRRRIICCFF
    \\RRRRIICCCF
    \\VVRRRCCFFF
    \\VVRCCCJFFF
    \\VVVVCJJCFE
    \\VVIVCCJJEE
    \\VVIIICJJEE
    \\MIIIIIJJEE
    \\MIIISIJEEE
    \\MMMISSJEEE
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
    try std.testing.expectEqual(100, input.data.count());
}

fn part1(input: Input) !u64 {
    const allocator = input.allocator;
    var mapped = std.AutoHashMap(Position, void).init(allocator);
    defer mapped.deinit();
    var result: u64 = 0;
    var entries = input.data.iterator();
    while (entries.next()) |entry| {
        if (mapped.contains(entry.key_ptr.*)) continue;
        var stacks = std.ArrayList(Position).init(allocator);
        defer stacks.deinit();
        try stacks.append(entry.key_ptr.*);
        var areas: u64 = 0;
        var perimeters: u64 = 0;
        const char = entry.value_ptr.*;
        while (stacks.pop()) |pos| {
            if (mapped.contains(pos)) continue;
            for (orthogonals) |value| {
                const p = pos + value;
                const c = input.data.get(p);
                if (c != char) perimeters += 1 else try stacks.append(p);
            }
            areas += 1;
            try mapped.put(pos, {});
        }
        result += areas * perimeters;
    }
    return result;
}

test part1 {
    const allocator = std.testing.allocator;
    var input = try parseInput(allocator, example);
    defer input.deinit();
    try std.testing.expectEqual(1930, try part1(input));
}

fn part2(input: Input) !u64 {
    const allocator = input.allocator;
    var mapped = std.AutoHashMap(Position, void).init(allocator);
    defer mapped.deinit();
    var result: u64 = 0;
    var entries = input.data.iterator();
    while (entries.next()) |entry| {
        if (mapped.contains(entry.key_ptr.*)) continue;
        var stacks = std.ArrayList(Position).init(allocator);
        defer stacks.deinit();
        try stacks.append(entry.key_ptr.*);
        var areas: u64 = 0;
        var sides_map = std.AutoHashMap(struct { usize, isize }, std.ArrayList(isize)).init(allocator);
        defer {
            var values = sides_map.valueIterator();
            while (values.next()) |value| value.deinit();
            sides_map.deinit();
        }
        const char = entry.value_ptr.*;
        while (stacks.pop()) |pos| {
            if (mapped.contains(pos)) continue;
            for (0.., orthogonals) |i, value| {
                const p = pos + value;
                const c = input.data.get(p);
                if (c != char) {
                    var gop = try sides_map.getOrPut(.{ i, p[i & 1] });
                    if (!gop.found_existing) gop.value_ptr.* = std.ArrayList(isize).init(allocator);
                    try gop.value_ptr.append(p[~i & 1]);
                } else try stacks.append(p);
            }
            areas += 1;
            try mapped.put(pos, {});
        }
        var sides_count: u64 = 0;
        var sides = sides_map.valueIterator();
        while (sides.next()) |side| {
            const items = try side.toOwnedSlice();
            defer allocator.free(items);
            std.mem.sort(isize, items, {}, std.sort.asc(isize));
            for (1.., items) |i, value| {
                if (i == items.len or items[i] - value != 1) sides_count += 1;
            }
        }
        result += areas * sides_count;
    }
    return result;
}

test part2 {
    const allocator = std.testing.allocator;
    var input = try parseInput(allocator, example);
    defer input.deinit();
    try std.testing.expectEqual(1206, try part2(input));
}

const Position = @Vector(2, isize);
const orthogonals = [_]Position{ .{ -1, 0 }, .{ 0, -1 }, .{ 1, 0 }, .{ 0, 1 } };
