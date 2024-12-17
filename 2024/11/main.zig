const std = @import("std");
const raw_input = @embedFile("input.txt");

const example = "0 1 10 99 999";

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
    data: []u64,
    allocator: Allocator,
    fn deinit(self: *Input) void {
        self.allocator.free(self.data);
    }
};

fn parseInput(allocator: Allocator, str: []const u8) !Input {
    const trimmed = std.mem.trim(u8, str, " \n");
    var data = std.ArrayList(u64).init(allocator);
    defer data.deinit();
    var numbers = std.mem.tokenizeScalar(u8, trimmed, ' ');
    while (numbers.next()) |number| {
        try data.append(try std.fmt.parseUnsigned(u64, number, 10));
    }
    return .{ .data = try data.toOwnedSlice(), .allocator = allocator };
}

test parseInput {
    const allocator = std.testing.allocator;
    var input = try parseInput(allocator, example);
    defer input.deinit();
    try std.testing.expectEqual(5, input.data.len);
}

fn part1(input: Input) !u64 {
    const allocator = input.allocator;
    var memo = std.AutoHashMap(Stone, u64).init(allocator);
    defer memo.deinit();
    var result: u64 = 0;
    for (input.data) |number| {
        result += try evolve(&memo, .{ .changes = 25, .number = number });
    }
    return result;
}

test part1 {
    const allocator = std.testing.allocator;
    var input = try parseInput(allocator, "125 17");
    defer input.deinit();
    try std.testing.expectEqual(55312, try part1(input));
}

fn part2(input: Input) !u64 {
    const allocator = input.allocator;
    var memo = std.AutoHashMap(Stone, u64).init(allocator);
    defer memo.deinit();
    var result: u64 = 0;
    for (input.data) |number| {
        result += try evolve(&memo, .{ .changes = 75, .number = number });
    }
    return result;
}

// test part2 {
//     const allocator = std.testing.allocator;
//     var input = try parseInput(allocator, example);
//     defer input.deinit();
//     try std.testing.expectEqual(81, try part2(input));
// }

const Stone = struct {
    changes: usize,
    number: u64,
};

fn split(n: u64) !?@Vector(2, u64) {
    var buf: [20]u8 = undefined;
    const str = std.fmt.bufPrintIntToSlice(&buf, n, 10, .lower, .{});
    if (str.len & 1 == 1) return null;
    const i = @divFloor(str.len, 2);
    const n1 = try std.fmt.parseUnsigned(u64, str[0..i], 10);
    const n2 = try std.fmt.parseUnsigned(u64, str[i..], 10);
    return .{ n1, n2 };
}

fn evolve(memo: *std.AutoHashMap(Stone, u64), stone: Stone) !u64 {
    if (memo.get(stone)) |v| return v;
    const result: u64 = blk: {
        if (stone.changes == 0) break :blk 1;
        if (stone.number == 0) break :blk try evolve(memo, .{ .changes = stone.changes - 1, .number = 1 });
        if (try split(stone.number)) |v| {
            const result_1 = try evolve(memo, .{ .changes = stone.changes - 1, .number = v[0] });
            const result_2 = try evolve(memo, .{ .changes = stone.changes - 1, .number = v[1] });
            break :blk result_1 + result_2;
        }
        break :blk try evolve(memo, .{ .changes = stone.changes - 1, .number = stone.number * 2024 });
    };
    try memo.put(stone, result);
    return result;
}
