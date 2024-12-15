const std = @import("std");
const raw_input = @embedFile("input.txt");

const example =
    \\190: 10 19
    \\3267: 81 40 27
    \\83: 17 5
    \\156: 15 6
    \\7290: 6 8 6 15
    \\161011: 16 10 13
    \\192: 17 8 14
    \\21037: 9 7 18 13
    \\292: 11 6 16 20
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
    data: []Equation,
    allocator: Allocator,
    fn deinit(self: Input) void {
        for (self.data) |value| self.allocator.free(value.numbers);
        self.allocator.free(self.data);
    }
};

fn parseInput(allocator: Allocator, str: []const u8) !Input {
    var list = std.ArrayList(Equation).init(allocator);
    defer list.deinit();
    var lines = std.mem.tokenizeScalar(u8, str, '\n');
    while (lines.next()) |line| {
        const separator = std.mem.indexOfScalar(u8, line, ':') orelse return error.InvalidInput;
        const value = try std.fmt.parseUnsigned(u64, line[0..separator], 10);
        var number_list = std.ArrayList(u64).init(allocator);
        defer number_list.deinit();
        var numbers = std.mem.tokenizeScalar(u8, line[separator + 1 ..], ' ');
        while (numbers.next()) |number| try number_list.append(try std.fmt.parseUnsigned(u64, number, 10));
        try list.append(.{ .value = value, .numbers = try number_list.toOwnedSlice() });
    }
    return .{ .data = try list.toOwnedSlice(), .allocator = allocator };
}

test parseInput {
    const allocator = std.testing.allocator;
    const input = try parseInput(allocator, example);
    defer input.deinit();
    try std.testing.expectEqual(9, input.data.len);
}

fn part1(allocator: Allocator, input: Input) !u64 {
    var result: u64 = 0;
    for (input.data) |eq| {
        var values = try allocator.alloc(u64, std.math.pow(usize, 2, eq.numbers.len - 1));
        defer allocator.free(values);
        @memset(values, eq.numbers[0]);
        for (0.., eq.numbers[1..]) |i, number| {
            for (0.., values) |j, value| {
                values[j] = if (j >> @intCast(i) & 1 == 0) value + number else value * number;
            }
        }
        for (values) |value| if (value == eq.value) {
            result += value;
            break;
        };
    }
    return result;
}

test part1 {
    const allocator = std.testing.allocator;
    const input = try parseInput(allocator, example);
    defer input.deinit();
    try std.testing.expectEqual(3749, try part1(allocator, input));
}

fn part2(allocator: Allocator, input: Input) !u64 {
    var result: u64 = 0;
    for (input.data) |eq| {
        var values = try allocator.alloc(u64, std.math.pow(usize, 3, eq.numbers.len - 1));
        defer allocator.free(values);
        @memset(values, eq.numbers[0]);
        for (0.., eq.numbers[1..]) |i, number| {
            for (0.., values) |j, value| {
                const n = @divFloor(j, std.math.pow(usize, 3, i));
                values[j] = switch (n % 3) {
                    0 => value + number,
                    1 => value * number,
                    2 => try concat(value, number),
                    else => unreachable,
                };
            }
        }
        for (values) |value| if (value == eq.value) {
            result += value;
            break;
        };
    }
    return result;
}

test part2 {
    const allocator = std.testing.allocator;
    const input = try parseInput(allocator, example);
    defer input.deinit();
    try std.testing.expectEqual(11387, try part2(allocator, input));
}

const Equation = struct {
    value: u64,
    numbers: []const u64,
};

fn concat(num_1: u64, num_2: u64) !u64 {
    var buf: [20]u8 = undefined;
    const str = try std.fmt.bufPrint(&buf, "{}{}", .{ num_1, num_2 });
    return try std.fmt.parseUnsigned(u64, str, 10);
}
