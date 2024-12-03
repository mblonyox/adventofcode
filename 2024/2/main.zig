const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    var input: Input = undefined;
    defer input.deinit();
    {
        const input_path = try std.fs.cwd().realpathAlloc(allocator, "./input.txt");
        defer allocator.free(input_path);
        var input_file = try std.fs.openFileAbsolute(input_path, .{});
        defer input_file.close();
        const reader = input_file.reader();
        input = try parseInput(allocator, reader);
    }
    const result1 = part1(allocator, input);
    std.debug.print("Part 1: {}\n", .{result1});
    const result2 = part2(allocator, input);
    std.debug.print("Part 2: {}\n", .{result2});
}

const Input = struct {
    data: [][]i8,
    allocator: std.mem.Allocator,
    fn deinit(self: Input) void {
        for (self.data) |d| {
            self.allocator.free(d);
        }
        self.allocator.free(self.data);
    }
};

fn parseInput(allocator: std.mem.Allocator, reader: anytype) !Input {
    var outerList = std.ArrayList([]i8).init(allocator);
    defer outerList.deinit();
    while (try reader.readUntilDelimiterOrEofAlloc(allocator, 0x0a, 256)) |line| {
        defer allocator.free(line);
        var iterator = std.mem.splitSequence(u8, line, " ");
        var innerList = std.ArrayList(i8).init(allocator);
        defer innerList.deinit();
        while (iterator.next()) |number| {
            try innerList.append(try std.fmt.parseInt(i8, number, 10));
        }
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
    const BytesFifo = std.fifo.LinearFifo(u8, .{ .Static = 256 });
    var fifo: BytesFifo = BytesFifo.init();
    defer fifo.deinit();
    const reader = fifo.reader();
    try fifo.write(example[0..]);
    const input = try parseInput(allocator, reader);
    defer input.deinit();
    try std.testing.expectEqual(6, input.data.len);
}

fn part1(allocator: std.mem.Allocator, input: Input) u32 {
    var result: u32 = 0;
    for (input.data) |report| {
        if (isSafe(allocator, report)) result += 1;
    }
    return result;
}

fn part2(allocator: std.mem.Allocator, input: Input) u32 {
    var result: u32 = 0;
    for (input.data) |report| {
        if (isSafe(allocator, report) or dampen(allocator, report)) result += 1;
    }
    return result;
}

fn isSafe(allocator: std.mem.Allocator, report: []i8) bool {
    const diffs = allocator.alloc(i8, report.len - 1) catch return false;
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

fn dampen(allocator: std.mem.Allocator, report: []i8) bool {
    const fixed_report = allocator.alloc(i8, report.len - 1) catch return false;
    defer allocator.free(fixed_report);
    for (0..report.len) |i| {
        @memcpy(fixed_report[0..i], report[0..i]);
        @memcpy(fixed_report[i..], report[i + 1 ..]);
        if (isSafe(allocator, fixed_report)) return true;
    }
    return false;
}
