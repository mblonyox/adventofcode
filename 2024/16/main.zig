const std = @import("std");
const raw_input = @embedFile("input.txt");

const example =
    \\###############
    \\#.......#....E#
    \\#.#.###.#.###.#
    \\#.....#.#...#.#
    \\#.###.#####.#.#
    \\#.#.#.......#.#
    \\#.#.#####.###.#
    \\#...........#.#
    \\###.#.#####.#.#
    \\#...#.....#.#.#
    \\#.#.#.###.#.#.#
    \\#.....#...#.#.#
    \\#.###.#.#.#.#.#
    \\#S..#.....#...#
    \\###############
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
    data: struct { map: Map, start: Position, end: Position },
    allocator: Allocator,
    fn deinit(self: *Input) void {
        self.data.map.deinit();
    }
};

fn parseInput(allocator: Allocator, str: []const u8) !Input {
    var map = Map.init(allocator);
    var start: Position = undefined;
    var end: Position = undefined;
    var lines = std.mem.tokenizeScalar(u8, str, '\n');
    var y: isize = 0;
    while (lines.next()) |line| : (y += 1) {
        for (line, 0..) |c, x| {
            const p = Position{ @intCast(x), y };
            if (c == 'S') start = p;
            if (c == 'E') end = p;
            try map.put(p, c);
        }
    }
    return .{ .data = .{ .map = map, .start = start, .end = end }, .allocator = allocator };
}

test parseInput {
    const allocator = std.testing.allocator;
    var input = try parseInput(allocator, example);
    defer input.deinit();
    try std.testing.expectEqual(225, input.data.map.count());
    try std.testing.expectEqual(.{ 1, 13 }, input.data.start);
    try std.testing.expectEqual(.{ 13, 1 }, input.data.end);
}

fn part1(input: Input) !u64 {
    const allocator = input.allocator;
    const map = input.data.map;
    var memo = std.AutoHashMap(Position, u64).init(allocator);
    defer memo.deinit();
    var stack = std.ArrayList(Path).init(allocator);
    defer stack.deinit();
    try stack.append(.{ .pos = input.data.start, .dir = .E, .value = 0 });
    while (stack.pop()) |path| {
        if (map.get(path.pos) == '#') continue;
        if (memo.get(path.pos)) |value| if (value < path.value) continue;
        try memo.put(path.pos, path.value);
        try stack.append(.{ .pos = path.dir.forward(path.pos), .dir = path.dir, .value = path.value + 1 });
        try stack.append(.{ .pos = path.dir.left().forward(path.pos), .dir = path.dir.left(), .value = path.value + 1001 });
        try stack.append(.{ .pos = path.dir.right().forward(path.pos), .dir = path.dir.right(), .value = path.value + 1001 });
    }
    return memo.get(input.data.end) orelse 0;
}

test part1 {
    const allocator = std.testing.allocator;
    var input = try parseInput(allocator, example);
    defer input.deinit();
    try std.testing.expectEqual(7036, try part1(input));
}

fn part2(input: Input) !u64 {
    const allocator = input.allocator;
    const map = input.data.map;
    var memo = std.AutoHashMap(Position, u64).init(allocator);
    defer memo.deinit();
    var stack = std.ArrayList(Path).init(allocator);
    defer stack.deinit();
    try stack.append(.{ .pos = input.data.start, .dir = .E, .value = 0 });
    while (stack.pop()) |path| {
        if (map.get(path.pos) == '#') continue;
        if (memo.get(path.pos)) |value| if (value < path.value) continue;
        try memo.put(path.pos, path.value);
        try stack.append(.{ .pos = path.dir.forward(path.pos), .dir = path.dir, .value = path.value + 1 });
        try stack.append(.{ .pos = path.dir.left().forward(path.pos), .dir = path.dir.left(), .value = path.value + 1001 });
        try stack.append(.{ .pos = path.dir.right().forward(path.pos), .dir = path.dir.right(), .value = path.value + 1001 });
    }
    return memo.get(input.data.end) orelse 0;
}

test part2 {
    const allocator = std.testing.allocator;
    var input = try parseInput(allocator, example);
    defer input.deinit();
    // try std.testing.expectEqual(undefined, try part2(input));
}

const Position = @Vector(2, isize);
const Map = std.AutoHashMap(Position, u8);
const Direction = enum {
    N,
    E,
    S,
    W,
    fn right(it: Direction) Direction {
        return switch (it) {
            .N => .E,
            .E => .S,
            .S => .W,
            .W => .N,
        };
    }
    fn left(it: Direction) Direction {
        return switch (it) {
            .N => .W,
            .E => .N,
            .S => .E,
            .W => .S,
        };
    }
    fn forward(it: Direction, pos: Position) Position {
        return pos + switch (it) {
            .N => Position{ 0, -1 },
            .E => Position{ 1, 0 },
            .S => Position{ 0, 1 },
            .W => Position{ -1, 0 },
        };
    }
};
const State = struct { pos: Position, dir: Direction };
const Path = struct { pos: Position, dir: Direction, value: u64 };
const Paths = std.ArrayList(Path);
