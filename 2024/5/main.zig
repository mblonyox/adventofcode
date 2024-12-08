const std = @import("std");
const raw_input = @embedFile("input.txt");

const example =
    \\47|53
    \\97|13
    \\97|61
    \\97|47
    \\75|29
    \\61|13
    \\75|53
    \\29|13
    \\97|29
    \\53|29
    \\61|53
    \\97|53
    \\61|29
    \\47|13
    \\75|47
    \\97|75
    \\47|61
    \\75|61
    \\47|29
    \\75|13
    \\53|13
    \\
    \\75,47,61,53,29
    \\97,61,53,29,13
    \\75,29,13
    \\75,97,47,61,53
    \\61,13,29
    \\97,13,75,29,47
;

const Allocator = std.mem.Allocator;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    const input: Input = try parseInput(allocator, raw_input);
    defer input.deinit();
    const result_1 = try part1(allocator, input);
    std.debug.print("Part 1: {}\n", .{result_1});
    const result_2 = try part2(allocator, input);
    std.debug.print("Part 2: {}\n", .{result_2});
}

const Input = struct {
    data: struct { rules: []const [2]u8, updates: []const []const u8 },
    allocator: Allocator,
    fn deinit(self: Input) void {
        self.allocator.free(self.data.rules);
        for (self.data.updates) |value| self.allocator.free(value);
        self.allocator.free(self.data.updates);
    }
};

fn parseInput(allocator: Allocator, str: []const u8) !Input {
    const separator = std.mem.indexOf(u8, str, "\n\n") orelse return error.InvalidInput;
    const rules = blk: {
        var list = std.ArrayList([2]u8).init(allocator);
        defer list.deinit();
        var lines = std.mem.tokenizeScalar(u8, str[0..separator], '\n');
        while (lines.next()) |line| {
            const d = std.mem.indexOfScalar(u8, line, '|') orelse return error.InvalidInput;
            try list.append(.{ try std.fmt.parseUnsigned(u8, line[0..d], 10), try std.fmt.parseUnsigned(u8, line[d + 1 ..], 10) });
        }
        break :blk try list.toOwnedSlice();
    };
    const updates = blk: {
        var list = std.ArrayList([]const u8).init(allocator);
        defer list.deinit();
        var lines = std.mem.tokenizeScalar(u8, str[separator..], '\n');
        while (lines.next()) |line| {
            var num_list = std.ArrayList(u8).init(allocator);
            defer num_list.deinit();
            var nums = std.mem.tokenizeScalar(u8, line, ',');
            while (nums.next()) |num| try num_list.append(try std.fmt.parseUnsigned(u8, num, 10));
            try list.append(try num_list.toOwnedSlice());
        }
        break :blk try list.toOwnedSlice();
    };
    return .{ .data = .{ .rules = rules, .updates = updates }, .allocator = allocator };
}

test parseInput {
    const allocator = std.testing.allocator;
    const input = try parseInput(allocator, example);
    defer input.deinit();
    try std.testing.expectEqual(21, input.data.rules.len);
    try std.testing.expectEqual(6, input.data.updates.len);
}

fn part1(allocator: Allocator, input: Input) !u32 {
    _ = allocator;
    var result: u32 = 0;
    for (input.data.updates) |update| {
        if (indicesOfWrong(input.data.rules, update) != null) continue;
        result += update[@divFloor(update.len, 2)];
    }
    return result;
}

test part1 {
    const allocator = std.testing.allocator;
    const input = try parseInput(allocator, example);
    defer input.deinit();
    try std.testing.expectEqual(143, try part1(allocator, input));
}

fn part2(allocator: Allocator, input: Input) !u32 {
    var result: u32 = 0;
    for (input.data.updates) |update| {
        const rules = input.data.rules;
        if (indicesOfWrong(rules, update) == null) continue;
        const sorted = try allocator.dupe(u8, update);
        defer allocator.free(sorted);
        while (indicesOfWrong(rules, sorted)) |indices| std.mem.swap(u8, &sorted[indices[0]], &sorted[indices[1]]);
        result += sorted[@divFloor(sorted.len, 2)];
    }
    return result;
}

test part2 {
    const allocator = std.testing.allocator;
    const input = try parseInput(allocator, example);
    defer input.deinit();
    try std.testing.expectEqual(123, try part2(allocator, input));
}

fn indicesOfWrong(rules: []const [2]u8, update: []const u8) ?[2]usize {
    for (rules) |rule| {
        const i_0 = std.mem.indexOfScalar(u8, update, rule[0]) orelse continue;
        const i_1 = std.mem.indexOfScalar(u8, update, rule[1]) orelse continue;
        if (i_1 < i_0) return .{ i_0, i_1 };
    }
    return null;
}
