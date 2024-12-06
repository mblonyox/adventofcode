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
    var result: u32 = 0;
    for (0..4) |i| {
        var arena = std.heap.ArenaAllocator.init(allocator);
        defer arena.deinit();
        const arenaAllocator = arena.allocator();
        var matrix = input.data;
        if ((i & 1) != 0) matrix = try rotate(arenaAllocator, matrix);
        if ((i & 2) != 0) matrix = try diagonal(arenaAllocator, matrix);
        result += try wordSearch(allocator, matrix, "XMAS");
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

fn rotate(allocator: Allocator, src: []const []const u8) ![]const []const u8 {
    const dest = try allocator.alloc([]u8, src[0].len);
    for (dest) |*row| row.* = try allocator.alloc(u8, src.len);
    for (0.., src) |i, row| {
        for (1.., row) |j, c| dest[row.len - j][i] = c;
    }
    return dest;
}

fn diagonal(allocator: Allocator, source: []const []const u8) ![]const []const u8 {
    const max_row = source.len;
    const max_col = source[0].len;
    var array_list = std.ArrayList([]u8).init(allocator);
    defer array_list.deinit();
    for (0..max_row) |row| {
        var list = std.ArrayList(u8).init(allocator);
        defer list.deinit();
        var i: usize = row;
        var j: usize = 0;
        while (i < max_row and j < max_col) : ({
            i += 1;
            j += 1;
        }) try list.append(source[i][j]);
        try array_list.append(try list.toOwnedSlice());
    }
    for (1..max_col) |col| {
        var list = std.ArrayList(u8).init(allocator);
        defer list.deinit();
        var i: usize = 0;
        var j: usize = col;
        while (i < max_row and j < max_col) : ({
            i += 1;
            j += 1;
        }) try list.append(source[i][j]);
        try array_list.insert(0, try list.toOwnedSlice());
    }
    return array_list.toOwnedSlice();
}

fn wordSearch(allocator: Allocator, source: []const []const u8, word: []const u8) !u32 {
    var result: u32 = 0;
    for (source) |s| {
        const r = try allocator.dupe(u8, s);
        defer allocator.free(r);
        std.mem.reverse(u8, r);
        result += @intCast(std.mem.count(u8, r, word));
        result += @intCast(std.mem.count(u8, s, word));
    }
    return result;
}
