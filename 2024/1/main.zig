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
    data: [2][]const i32,
    allocator: Allocator,
    fn deinit(self: Input) void {
        for (self.data) |list| self.allocator.free(list);
    }
};

fn parseInput(allocator: Allocator, str: []const u8) !Input {
    var list_1 = std.ArrayList(i32).init(allocator);
    errdefer list_1.deinit();
    var list_2 = std.ArrayList(i32).init(allocator);
    errdefer list_2.deinit();
    var lines = std.mem.tokenizeScalar(u8, str, '\n');
    while (lines.next()) |line| {
        var nums = std.mem.tokenizeScalar(u8, line, ' ');
        if (nums.next()) |num| try list_1.append(try std.fmt.parseInt(i32, num, 10));
        if (nums.next()) |num| try list_2.append(try std.fmt.parseInt(i32, num, 10));
    }
    return .{ .data = .{ try list_1.toOwnedSlice(), try list_2.toOwnedSlice() }, .allocator = allocator };
}

test "parseInput" {
    const allocator = std.testing.allocator;
    const example =
        \\3   4
        \\4   3
        \\2   5
        \\1   3
        \\3   9
        \\3   3
    ;
    const input = try parseInput(allocator, example);
    defer input.deinit();
    try std.testing.expectEqualSlices(i32, &.{ 3, 4, 2, 1, 3, 3 }, input.data[0]);
    try std.testing.expectEqualSlices(i32, &.{ 4, 3, 5, 3, 9, 3 }, input.data[1]);
}

fn part1(allocator: Allocator, input: Input) !u32 {
    const list_1 = try allocator.dupe(i32, input.data[0]);
    defer allocator.free(list_1);
    const list_2 = try allocator.dupe(i32, input.data[1]);
    defer allocator.free(list_2);
    std.mem.sort(i32, list_1, {}, std.sort.asc(i32));
    std.mem.sort(i32, list_2, {}, std.sort.asc(i32));
    var total: u32 = 0;
    for (list_1, list_2) |n1, n2| {
        total += @abs(n1 - n2);
    }
    return total;
}

fn part2(allocator: Allocator, input: Input) !u32 {
    var map = std.AutoHashMap(i32, u32).init(allocator);
    defer map.deinit();
    for (input.data[1]) |k| {
        const gop = try map.getOrPut(k);
        if (gop.found_existing) {
            gop.value_ptr.* += 1;
        } else {
            gop.value_ptr.* = 1;
        }
    }
    var total: u32 = 0;
    for (input.data[0]) |k| {
        const v = map.get(k) orelse 0;
        total += @abs(k) * v;
    }
    return total;
}
