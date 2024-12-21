const std = @import("std");
const raw_input = @embedFile("input.txt");

const example =
    \\Button A: X+94, Y+34
    \\Button B: X+22, Y+67
    \\Prize: X=8400, Y=5400
    \\
    \\Button A: X+26, Y+66
    \\Button B: X+67, Y+21
    \\Prize: X=12748, Y=12176
    \\
    \\Button A: X+17, Y+86
    \\Button B: X+84, Y+37
    \\Prize: X=7870, Y=6450
    \\
    \\Button A: X+69, Y+23
    \\Button B: X+27, Y+71
    \\Prize: X=18641, Y=10279
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
    data: []Claw,
    allocator: Allocator,
    fn deinit(self: *Input) void {
        self.allocator.free(self.data);
    }
};

fn parseInput(allocator: Allocator, str: []const u8) !Input {
    var data = std.ArrayList(Claw).init(allocator);
    defer data.deinit();
    var claws = std.mem.tokenizeSequence(u8, str, "\n\n");
    while (claws.next()) |claw| {
        var num = std.mem.tokenizeAny(u8, claw, "ABPXYeinortuz :+=,\n");
        const a = Position{ try std.fmt.parseUnsigned(u32, num.next().?, 10), try std.fmt.parseUnsigned(u32, num.next().?, 10) };
        const b = Position{ try std.fmt.parseUnsigned(u32, num.next().?, 10), try std.fmt.parseUnsigned(u32, num.next().?, 10) };
        const prize = Position{ try std.fmt.parseUnsigned(u32, num.next().?, 10), try std.fmt.parseUnsigned(u32, num.next().?, 10) };
        try data.append(.{ .a = a, .b = b, .prize = prize });
    }
    return .{ .data = try data.toOwnedSlice(), .allocator = allocator };
}

test parseInput {
    const allocator = std.testing.allocator;
    var input = try parseInput(allocator, example);
    defer input.deinit();
    try std.testing.expectEqual(4, input.data.len);
}

fn part1(input: Input) !u64 {
    var result: u64 = 0;
    for (input.data) |claw| {
        if (claw.winningCost()) |cost| result += cost;
    }
    return result;
}

test part1 {
    const allocator = std.testing.allocator;
    var input = try parseInput(allocator, example);
    defer input.deinit();
    try std.testing.expectEqual(480, try part1(input));
}

fn part2(input: Input) !u64 {
    var result: u64 = 0;
    for (input.data) |*claw| {
        claw.prize += @as(Position, @splat(10000000000000));
        if (claw.winningCost()) |cost| result += cost;
    }
    return result;
}

test part2 {
    const allocator = std.testing.allocator;
    var input = try parseInput(allocator, example);
    defer input.deinit();
    // try std.testing.expectEqual(undefined, try part2(input));
}

const Position = @Vector(2, u64);

const Claw = struct {
    a: Position,
    b: Position,
    prize: Position,
    fn winningCost(self: Claw) ?u64 {
        const a: u64 = self.a[0];
        const b: u64 = self.b[0];
        const c: u64 = self.prize[0];
        const d: u64 = self.a[1];
        const e: u64 = self.b[1];
        const f: u64 = self.prize[1];
        const bf: u64 = b * f;
        const ce: u64 = c * e;
        const bd: u64 = b * d;
        const ae: u64 = a * e;
        const x: u64 = if (bf > ce and bd > ae) @divFloor(bf - ce, bd - ae) else if (bf < ce and bd < ae) @divFloor(ce - bf, ae - bd) else return null;
        const ax: u64 = a * x;
        const y: u64 = if (c >= ax) @divFloor(c - ax, b) else return null;
        if (a * x + b * y == c and d * x + e * y == f) return 3 * x + y;
        return null;
    }
};
