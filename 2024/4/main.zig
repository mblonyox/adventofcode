const std = @import("std");
const raw_input = @embedFile("input.txt");

const example =
    \\MMMSXXMASM
    \\MSAMXMSMSA
    \\AMXSXMAAMM
    \\MSAMASMSMX
    \\XMASAMXAMM
    \\XXAMMXXAMA
    \\SMSMSASXSS
    \\SAXAMASAAA
    \\MAMMMXMMMM
    \\MXMXAXMASX
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
    data: []const []const u8,
    allocator: Allocator,
    fn deinit(self: Input) void {
        self.allocator.free(self.data);
    }
};

fn parseInput(allocator: Allocator, str: []const u8) !Input {
    var list = std.ArrayList([]const u8).init(allocator);
    errdefer list.deinit();
    var lines = std.mem.tokenizeScalar(u8, str, '\n');
    while (lines.next()) |line| try list.append(line);
    return .{ .data = try list.toOwnedSlice(), .allocator = allocator };
}

test parseInput {
    const allocator = std.testing.allocator;
    const input = try parseInput(allocator, example);
    defer input.deinit();
    try std.testing.expectEqualSlices(u8, "MMMSXXMASM", input.data[0]);
    try std.testing.expectEqualSlices(u8, "MSAMXMSMSA", input.data[1]);
}

fn part1(allocator: Allocator, input: Input) !u32 {
    _ = allocator;
    const src = input.data;
    var buffer: [3]u8 = undefined;
    var result: u32 = 0;
    for (0.., src) |i, row| {
        for (0.., row) |j, c| {
            if (c != 'X') continue;
            for (0..8) |d| {
                const di: i32 = if (d == 4 or d == 7) 0 else if (d & 1 != 0) 1 else -1;
                const dj: i32 = if (d == 5 or d == 6) 0 else if (d & 2 != 0) 1 else -1;
                if (di < 0 and i < 3) continue;
                if (di > 0 and i >= src.len - 3) continue;
                if (dj < 0 and j < 3) continue;
                if (dj > 0 and j >= row.len - 3) continue;
                const si: i32 = @intCast(i);
                const sj: i32 = @intCast(j);
                for ([_]i32{ 1, 2, 3 }) |x| @memset(buffer[@intCast(x - 1)..@intCast(x)], src[@intCast(si + x * di)][@intCast(sj + x * dj)]);
                if (std.mem.eql(u8, &buffer, "MAS")) result += 1;
            }
        }
    }
    return result;
}

test part1 {
    const allocator = std.testing.allocator;
    const input = try parseInput(allocator, example);
    defer input.deinit();
    try std.testing.expectEqual(18, try part1(allocator, input));
}

fn part2(allocator: Allocator, input: Input) !u32 {
    _ = allocator;
    const src = input.data;
    var result: u32 = 0;
    for (0.., src) |i, row| {
        if (i == 0 or i >= (input.data.len - 1)) continue;
        for (0.., row) |j, c| {
            if (j == 0 or j >= (row.len - 1) or c != 'A') continue;
            const tl = src[i - 1][j - 1];
            const tr = src[i - 1][j + 1];
            const bl = src[i + 1][j - 1];
            const br = src[i + 1][j + 1];
            const tlbr = (tl == 'M' and br == 'S') or (tl == 'S' and br == 'M');
            const trbl = (tr == 'M' and bl == 'S') or (tr == 'S' and bl == 'M');
            if (tlbr and trbl) result += 1;
        }
    }
    return result;
}

test part2 {
    const allocator = std.testing.allocator;
    const input = try parseInput(allocator, example);
    defer input.deinit();
    try std.testing.expectEqual(9, try part2(allocator, input));
}
