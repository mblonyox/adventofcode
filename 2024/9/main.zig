const std = @import("std");
const raw_input = @embedFile("input.txt");

const example = "2333133121414131402";

const Allocator = std.mem.Allocator;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    var input: Input = try parseInput(allocator, raw_input);
    defer input.deinit();
    const result_1 = try part1(allocator, input);
    std.debug.print("Part 1: {}\n", .{result_1});
    const result_2 = try part2(allocator, input);
    std.debug.print("Part 2: {}\n", .{result_2});
}

const Input = struct {
    data: []const u8,
    allocator: Allocator,
    fn deinit(self: *Input) void {
        self.allocator.free(self.data);
    }
};

fn parseInput(allocator: Allocator, str: []const u8) !Input {
    const trimmed = std.mem.trim(u8, str, " \n");
    const data = try allocator.dupe(u8, trimmed);
    return .{ .data = data, .allocator = allocator };
}

test parseInput {
    const allocator = std.testing.allocator;
    var input = try parseInput(allocator, example);
    defer input.deinit();
    try std.testing.expectEqual(19, input.data.len);
}

fn part1(allocator: Allocator, input: Input) !u64 {
    var file_blocks = std.ArrayList(Pointer).init(allocator);
    defer file_blocks.deinit();
    var free_blocks = std.ArrayList(Pointer).init(allocator);
    defer free_blocks.deinit();
    var moved_blocks = std.ArrayList(Pointer).init(allocator);
    defer moved_blocks.deinit();
    {
        var ptr: usize = 0;
        for (0.., input.data) |i, c| {
            const len = @as(usize, c - 48);
            if (i & 1 == 0) {
                const id = @divFloor(i, 2);
                try file_blocks.append(.{ .id = id, .len = len, .ptr = ptr });
            } else try free_blocks.append(.{ .len = len, .ptr = ptr });
            ptr += len;
        }
    }
    for (free_blocks.items) |free_block| {
        var len = free_block.len;
        var ptr = free_block.ptr;
        while (len > 0) {
            var last_file_block = file_blocks.pop();
            if (last_file_block.ptr < ptr) {
                try file_blocks.append(last_file_block);
                break;
            }
            const size = @min(len, last_file_block.len);
            try moved_blocks.append(.{ .id = last_file_block.id, .ptr = ptr, .len = size });
            len -= size;
            ptr += size;
            if (last_file_block.len > size) {
                last_file_block.len -= size;
                try file_blocks.append(last_file_block);
            }
        }
    }
    var result: u64 = 0;
    for (file_blocks.items) |p| {
        for (p.ptr..p.ptr + p.len) |i| result += @intCast(i * p.id.?);
    }
    for (moved_blocks.items) |p| {
        for (p.ptr..p.ptr + p.len) |i| result += @intCast(i * p.id.?);
    }
    return result;
}

test part1 {
    const allocator = std.testing.allocator;
    var input = try parseInput(allocator, example);
    defer input.deinit();
    try std.testing.expectEqual(1928, try part1(allocator, input));
}

fn part2(allocator: Allocator, input: Input) !u64 {
    var file_blocks = std.ArrayList(Pointer).init(allocator);
    defer file_blocks.deinit();
    var free_blocks = std.ArrayList(Pointer).init(allocator);
    defer free_blocks.deinit();
    var moved_blocks = std.ArrayList(Pointer).init(allocator);
    defer moved_blocks.deinit();
    {
        var ptr: usize = 0;
        for (0.., input.data) |i, c| {
            const len = @as(usize, c - 48);
            if (i & 1 == 0) {
                const id = @divFloor(i, 2);
                try file_blocks.append(.{ .id = id, .len = len, .ptr = ptr });
            } else try free_blocks.append(.{ .len = len, .ptr = ptr });
            ptr += len;
        }
    }
    while (file_blocks.items.len > 0) {
        var last_file_block = file_blocks.pop();
        for (0.., free_blocks.items) |i, p| {
            if (p.len < last_file_block.len) continue;
            if (p.ptr > last_file_block.ptr) break;
            last_file_block.ptr = p.ptr;
            {
                var free_block = p;
                free_block.len -= last_file_block.len;
                free_block.ptr += last_file_block.len;
                if (free_block.len > 0) free_blocks.items[i] = free_block else _ = free_blocks.orderedRemove(i);
            }
            break;
        }
        try moved_blocks.append(last_file_block);
    }
    var result: u64 = 0;
    for (moved_blocks.items) |p| {
        for (p.ptr..p.ptr + p.len) |i| result += @intCast(i * p.id.?);
    }
    return result;
}

test part2 {
    const allocator = std.testing.allocator;
    var input = try parseInput(allocator, example);
    defer input.deinit();
    try std.testing.expectEqual(2858, try part2(allocator, input));
}

const Pointer = struct { ptr: usize, len: usize, id: ?usize = null };
