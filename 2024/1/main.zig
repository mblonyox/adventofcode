const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    var input: Input = undefined;
    defer allocator.free(input[0]);
    defer allocator.free(input[1]);
    {
        const input_path = try std.fs.cwd().realpathAlloc(allocator, "./input.txt");
        defer allocator.free(input_path);
        var input_file = try std.fs.openFileAbsolute(input_path, .{});
        defer input_file.close();
        const reader = input_file.reader();
        input = try parseInput(allocator, reader);
    }
    const result1 = part1(input);
    std.debug.print("Part 1: {}\n", .{result1});
    const result2 = try part2(allocator, input);
    std.debug.print("Part 2: {}\n", .{result2});
}

const Input = struct {
    []i32,
    []i32,
};

fn parseInput(allocator: std.mem.Allocator, reader: anytype) !Input {
    var arr1 = std.ArrayList(i32).init(allocator);
    var arr2 = std.ArrayList(i32).init(allocator);
    var buf: [256]u8 = undefined;
    while (try reader.readUntilDelimiterOrEof(&buf, 0xa)) |line| {
        if (std.mem.indexOf(u8, line, "   ")) |i| {
            try arr1.append(try std.fmt.parseInt(i32, line[0..i], 10));
            try arr2.append(try std.fmt.parseInt(i32, line[i + 3 ..], 10));
        }
    }
    return .{ try arr1.toOwnedSlice(), try arr2.toOwnedSlice() };
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
    const BytesFifo = std.fifo.LinearFifo(u8, .{ .Static = 256 });
    var fifo: BytesFifo = BytesFifo.init();
    defer fifo.deinit();
    const reader = fifo.reader();
    try fifo.write(example[0..]);
    const input = try parseInput(allocator, reader);
    defer allocator.free(input[0]);
    defer allocator.free(input[1]);
    try std.testing.expectEqual(2, input.len);
    try std.testing.expectEqual(6, input[0].len);
    try std.testing.expectEqual(6, input[1].len);
    try std.testing.expectEqualSlices(i32, &.{ 3, 4, 2, 1, 3, 3 }, input[0]);
    try std.testing.expectEqualSlices(i32, &.{ 4, 3, 5, 3, 9, 3 }, input[1]);
}

fn part1(input: Input) u32 {
    const arr1: []i32 = input[0];
    const arr2: []i32 = input[1];
    std.mem.sort(i32, arr1, {}, std.sort.asc(i32));
    std.mem.sort(i32, arr2, {}, std.sort.asc(i32));
    var total: u32 = 0;
    for (arr1, arr2) |n1, n2| {
        total += @abs(n1 - n2);
    }
    return total;
}

fn part2(allocator: std.mem.Allocator, input: Input) !u32 {
    const arr1: []i32 = input[0];
    const arr2: []i32 = input[1];
    var map = std.AutoHashMap(i32, u32).init(allocator);
    defer map.deinit();
    for (arr2) |k| {
        const gop = try map.getOrPut(k);
        if (gop.found_existing) {
            gop.value_ptr.* += 1;
        } else {
            gop.value_ptr.* = 1;
        }
    }
    var total: u32 = 0;
    for (arr1) |k| {
        const v = map.get(k) orelse 0;
        total += @abs(k) * v;
    }
    return total;
}
