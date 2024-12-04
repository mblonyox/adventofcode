const std = @import("std");
const raw_input = @embedFile("input.txt");

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
    data: [][]const i8,
    allocator: Allocator,
    fn deinit(self: Input) void {
        for (self.data) |d| self.allocator.free(d);
        self.allocator.free(self.data);
    }
};

fn parseInput(allocator: Allocator, str: []const u8) !Input {
    var outerList = std.ArrayList([]i8).init(allocator);
    errdefer outerList.deinit();
    var lines = std.mem.tokenizeScalar(u8, str, '\n');
    while (lines.next()) |line| {
        var innerList = std.ArrayList(i8).init(allocator);
        errdefer innerList.deinit();
        var nums = std.mem.tokenizeScalar(u8, line, ' ');
        while (nums.next()) |num| try innerList.append(try std.fmt.parseInt(i8, num, 10));
        try outerList.append(try innerList.toOwnedSlice());
    }
    return .{ .data = try outerList.toOwnedSlice(), .allocator = allocator };
}

test "parseInput" {
    const allocator = std.testing.allocator;
    const example =
        \\7 6 4 2 1
        \\1 2 7 8 9
        \\9 7 6 2 1
        \\1 3 2 4 5
        \\8 6 4 4 1
        \\1 3 6 7 9
    ;
    const input = try parseInput(allocator, example);
    defer input.deinit();
    try std.testing.expectEqual(6, input.data.len);
}

fn part1(allocator: Allocator, input: Input) !u32 {
    var result: u32 = 0;
    for (input.data) |report| {
        if (try isSafe(allocator, report)) result += 1;
    }
    return result;
}

fn part2(allocator: Allocator, input: Input) !u32 {
    var result: u32 = 0;
    for (input.data) |report| {
        if (try isSafe(allocator, report) or try dampen(allocator, report)) result += 1;
    }
    return result;
}

fn isSafe(allocator: Allocator, report: []const i8) !bool {
    const diffs = try allocator.alloc(i8, report.len - 1);
    defer allocator.free(diffs);
    var previous = report[0];
    for (report[1..], 0..) |value, i| {
        diffs[i] = value - previous;
        previous = value;
    }
    var signs: i8 = 0;
    for (diffs) |value| {
        if (@abs(value) > 3) return false;
        signs += std.math.sign(value);
    }
    if (@abs(signs) != diffs.len) return false;
    return true;
}

fn dampen(allocator: Allocator, report: []const i8) !bool {
    const fixed_report = try allocator.alloc(i8, report.len - 1);
    defer allocator.free(fixed_report);
    for (0..report.len) |i| {
        @memcpy(fixed_report[0..i], report[0..i]);
        @memcpy(fixed_report[i..], report[i + 1 ..]);
        if (try isSafe(allocator, fixed_report)) return true;
    }
    return false;
}
