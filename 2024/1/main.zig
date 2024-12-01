const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    var a = std.mem.zeroes([1000]i32);
    var b = std.mem.zeroes([1000]i32);
    {
        const allocator = gpa.allocator();
        const input_path = try std.fs.cwd().realpathAlloc(allocator, "./input.txt");
        defer allocator.free(input_path);
        var input_file = try std.fs.openFileAbsolute(input_path, .{});
        defer input_file.close();
        var reader = input_file.reader();
        var buf: [4096]u8 = undefined;
        var i: usize = 0;
        while (try reader.readUntilDelimiterOrEof(&buf, 0xa)) |line| {
            a[i] = try std.fmt.parseInt(i32, line[0..5], 10);
            b[i] = try std.fmt.parseInt(i32, line[8..], 10);
            i += 1;
        }
    }
    {
        std.mem.sort(i32, &a, {}, std.sort.asc(i32));
        std.mem.sort(i32, &b, {}, std.sort.asc(i32));
        var total: u32 = 0;
        var i: usize = 0;
        while (i < 1000) {
            total += @abs(a[i] - b[i]);
            i += 1;
        }
        std.debug.print("Part 1: {}\n", .{total});
    }
    {
        const allocator = gpa.allocator();
        var map = std.AutoHashMap(i32, u32).init(allocator);
        defer map.deinit();
        for (b) |k| {
            const gop = try map.getOrPut(k);
            if (gop.found_existing) {
                gop.value_ptr.* += 1;
            } else {
                gop.value_ptr.* = 1;
            }
        }
        var total: u32 = 0;
        for (a) |k| {
            const v = map.get(k) orelse 0;
            total += @abs(k) * v;
        }
        std.debug.print("Part 2: {}\n", .{total});
    }
}
