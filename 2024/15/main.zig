const std = @import("std");
const raw_input = @embedFile("input.txt");

const example =
    \\##########
    \\#..O..O.O#
    \\#......O.#
    \\#.OO..O.O#
    \\#..O@..O.#
    \\#O#..O...#
    \\#O..O..O.#
    \\#.OO.O.OO#
    \\#....O...#
    \\##########
    \\
    \\<vv>^<v^>v>^vv^v>v<>v^v<v<^vv<<<^><<><>>v<vvv<>^v^>^<<<><<v<<<v^vv^v>^
    \\vvv<<^>^v^^><<>>><>^<<><^vv^^<>vvv<>><^^v>^>vv<>v<<<<v<^v>^<^^>>>^<v<v
    \\><>vv>v^v^<>><>>>><^^>vv>v<^^^>>v^v^<^^>v^^>v^<^v>v<>>v^v^<v>v^^<^^vv<
    \\<<v<^>>^^^^>>>v^<>vvv^><v<<<>^^^vv^<vvv>^>v<^^^^v<>^>vvvv><>>v^<<^^^^^
    \\^><^><>>><>^^<<^^v>>><^<v>^<vv>>v>>>^v><>^v><<<<v>>v<v<v>vvv>^<><<>^><
    \\^>><>^v<><^vvv<^^<><v<<<<<><^v<<<><<<^^<v<^^^><^>>^<v^><<<^>>^v<v^v<v^
    \\>^>>^v>vv>^<<^v<>><<><<v<<v><>v<^vv<<<>^^v^>^^>>><<^v>>v^v><^^>>^<>vv^
    \\<><^^>^^^<><vvvvv^v<v<<>^v<v>v<<^><<><<><<<^^<<<^<<>><<><^^^>^^<>^>v<>
    \\^^>vv<^v^v<vv>^<><v<^v>^^^>>>^^vvv^>vvv<>>>^<^>>>>>^<<^v>^vvv<>^<><<v>
    \\v^^>>><<^^<>>^v^<v^vv<>v^<<>^<^v^v><^<<<><<^<v><v<>vv>>v><v^<vv<>v^<<^
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
    data: struct { map: Map, moves: []Direction },
    allocator: Allocator,
    fn deinit(self: *Input) void {
        self.data.map.deinit();
        self.allocator.free(self.data.moves);
    }
};

fn parseInput(allocator: Allocator, str: []const u8) !Input {
    const s = std.mem.indexOf(u8, str, "\n\n").?;
    var map = Map.init(allocator);
    {
        var lines = std.mem.tokenizeScalar(u8, str[0..s], '\n');
        var y: isize = 0;
        while (lines.next()) |line| : (y += 1) {
            for (0.., line) |x, c| try map.put(.{ @intCast(x), y }, c);
        }
    }
    const moves = blk: {
        var list = std.ArrayList(Direction).init(allocator);
        defer list.deinit();
        for (str[s..]) |c| try list.append(Direction.parse(c) catch continue);
        break :blk try list.toOwnedSlice();
    };
    return .{ .data = .{ .map = map, .moves = moves }, .allocator = allocator };
}

test parseInput {
    const allocator = std.testing.allocator;
    var input = try parseInput(allocator, example);
    defer input.deinit();
    try std.testing.expectEqual(100, input.data.map.count());
    try std.testing.expectEqual(700, input.data.moves.len);
}

fn part1(input: Input) !u64 {
    var map = try input.data.map.clone();
    defer map.deinit();
    var pos = blk: {
        var items = map.iterator();
        while (items.next()) |item| {
            if (item.value_ptr.* == '@') break :blk item.key_ptr.*;
        } else unreachable;
    };
    for (input.data.moves) |dir| {
        var moved_map = try map.clone();
        defer moved_map.deinit();
        move(&moved_map, pos, dir) catch continue;
        std.mem.swap(Map, &map, &moved_map);
        pos = dir.of(pos);
    }
    var result: u64 = 0;
    {
        var items = map.iterator();
        while (items.next()) |item| {
            if (item.value_ptr.* == 'O') {
                const x = item.key_ptr[0];
                const y = item.key_ptr[1];
                result += @intCast(x + 100 * y);
            }
        }
    }
    return result;
}

test part1 {
    const allocator = std.testing.allocator;
    var input = try parseInput(allocator, example);
    defer input.deinit();
    try std.testing.expectEqual(10092, try part1(input));
}

fn part2(input: Input) !u64 {
    var map = Map.init(input.allocator);
    defer map.deinit();
    {
        var entries = input.data.map.iterator();
        while (entries.next()) |entry| {
            const x = entry.key_ptr[0];
            const y = entry.key_ptr[1];
            const chars = switch (entry.value_ptr.*) {
                '#' => "##",
                'O' => "[]",
                '.' => "..",
                '@' => "@.",
                else => unreachable,
            };
            try map.put(.{ x * 2, y }, chars[0]);
            try map.put(.{ x * 2 + 1, y }, chars[1]);
        }
    }
    var pos = blk: {
        var items = map.iterator();
        while (items.next()) |item| {
            if (item.value_ptr.* == '@') break :blk item.key_ptr.*;
        } else unreachable;
    };
    for (input.data.moves) |dir| {
        var moved_map = try map.clone();
        defer moved_map.deinit();
        move(&moved_map, pos, dir) catch continue;
        std.mem.swap(Map, &map, &moved_map);
        pos = dir.of(pos);
    }
    var result: u64 = 0;
    {
        var items = map.iterator();
        while (items.next()) |item| {
            if (item.value_ptr.* == '[') {
                const x = item.key_ptr[0];
                const y = item.key_ptr[1];
                result += @intCast(x + 100 * y);
            }
        }
    }
    return result;
}

test part2 {
    const allocator = std.testing.allocator;
    var input = try parseInput(allocator, example);
    defer input.deinit();
    try std.testing.expectEqual(9021, try part2(input));
}

const Position = @Vector(2, isize);
const Direction = enum {
    Up,
    Down,
    Left,
    Right,
    fn parse(char: u8) !Direction {
        return switch (char) {
            '^' => .Up,
            'v' => .Down,
            '<' => .Left,
            '>' => .Right,
            else => error.InvalidInput,
        };
    }
    fn of(self: Direction, p: Position) Position {
        const x = p[0];
        const y = p[1];
        return switch (self) {
            .Up => .{ x, y - 1 },
            .Down => .{ x, y + 1 },
            .Left => .{ x - 1, y },
            .Right => .{ x + 1, y },
        };
    }
};
const Map = std.AutoHashMap(Position, u8);
fn move(map: *Map, pos: Position, dir: Direction) !void {
    const c = map.get(pos) orelse return error.InvalidPosition;
    const p = dir.of(pos);
    const o = map.get(p) orelse return error.InvalidPosition;
    switch (o) {
        '#' => return error.InvalidMove,
        'O' => try move(map, p, dir),
        '[', ']' => switch (dir) {
            .Left, .Right => try move(map, p, dir),
            .Up, .Down => {
                const dx: isize = if (o == '[') 1 else -1;
                try move(map, p, dir);
                try move(map, .{ p[0] + dx, p[1] }, dir);
            },
        },
        else => {},
    }
    try map.put(p, c);
    try map.put(pos, '.');
}
