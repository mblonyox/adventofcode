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
    const result1 = part1(input);
    std.debug.print("Part 1: {}\n", .{result1});
    const result2 = part2(input);
    std.debug.print("Part 2: {}\n", .{result2});
}

const Input = struct {
    data: []const u8,
    allocator: std.mem.Allocator,
    fn deinit(self: Input) void {
        self.allocator.free(self.data);
    }
};

fn parseInput(allocator: std.mem.Allocator, reader: anytype) !Input {
    const data = try reader.readAllAlloc(allocator, std.math.maxInt(usize));
    return .{ .data = data, .allocator = allocator };
}

test "parseInput" {
    const allocator = std.testing.allocator;
    const example =
        \\xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))
    ;
    const BytesFifo = std.fifo.LinearFifo(u8, .{ .Static = 256 });
    var fifo: BytesFifo = BytesFifo.init();
    defer fifo.deinit();
    const reader = fifo.reader();
    try fifo.write(example[0..]);
    const input = try parseInput(allocator, reader);
    defer input.deinit();
    try std.testing.expectEqual(71, input.data.len);
}

fn part1(input: Input) u32 {
    return multipy(input.data);
}

fn part2(input: Input) u32 {
    var result: u32 = 0;
    var iterator = std.mem.splitSequence(u8, input.data, "do()");
    while (iterator.next()) |str| {
        result += if (std.mem.indexOf(u8, str, "don't()")) |dont| multipy(str[0..dont]) else multipy(str);
    }
    return result;
}

fn multipy(instruction: []const u8) u32 {
    var result: u32 = 0;
    var iterator = std.mem.splitSequence(u8, instruction, "mul(");
    _ = iterator.next();
    while (iterator.next()) |str| {
        if (std.mem.indexOfScalar(u8, str, ',')) |comma| {
            const num_a = parseNum(str[0..comma]) catch continue;
            if (std.mem.indexOfScalarPos(u8, str, comma + 1, ')')) |closing| {
                const num_b = parseNum(str[comma + 1 .. closing]) catch continue;
                result += @as(u32, num_a) * @as(u32, num_b);
            }
        }
    }
    return result;
}

fn parseNum(str: []const u8) !u16 {
    const min_max = std.mem.minMax(u8, str);
    if (min_max[0] < '0' or min_max[1] > '9') return error.Invalid;
    return std.fmt.parseUnsigned(u16, str, 10);
}
