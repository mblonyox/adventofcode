const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    const session_cookie = try getSessionCookie(allocator);
    defer allocator.free(session_cookie);
    var client: std.http.Client = .{ .allocator = allocator };
    defer client.deinit();
    const cookie_value = try std.fmt.allocPrint(allocator, "session={s};", .{session_cookie});
    defer allocator.free(cookie_value);
    const cookie_header: std.http.Header = .{ .name = "cookie", .value = cookie_value };
    for (1..26) |day| {
        const url = try std.fmt.allocPrint(allocator, "https://adventofcode.com/2024/day/{}/input", .{day});
        defer allocator.free(url);
        var output = std.ArrayList(u8).init(allocator);
        defer output.deinit();
        const result = try client.fetch(.{ .location = .{ .url = url }, .extra_headers = &.{cookie_header}, .response_storage = .{ .dynamic = &output } });
        switch (result.status) {
            .ok => {
                std.debug.print("Input found for day {}\n", .{day});
                var subpath: [2]u8 = undefined;
                const dir = try std.fs.cwd().makeOpenPath(std.fmt.bufPrintIntToSlice(&subpath, day, 10, .lower, .{}), .{});
                try dir.writeFile(.{ .sub_path = "input.txt", .data = output.items });
            },
            .not_found => std.debug.print("No input found for day {}\n", .{day}),
            else => std.debug.print("Error getting input fo day {}: {d}\n", .{ day, result.status }),
        }
    }
}

fn getSessionCookie(allocator: std.mem.Allocator) ![]u8 {
    for (std.os.environ) |value| {
        if (std.mem.eql(u8, value[0..15], "SESSION_COOKIE=")) return allocator.dupe(u8, std.mem.span(value[15..]));
    }
    for (std.os.argv) |value| {
        if (std.mem.eql(u8, value[0..17], "--session-cookie=")) return allocator.dupe(u8, std.mem.span(value[17..]));
    }
    {
        const stdout = std.io.getStdOut();
        defer stdout.close();
        _ = try stdout.write("Set cookie value:\n");
    }
    const stdin = std.io.getStdIn();
    defer stdin.close();
    const reader = stdin.reader();
    return reader.readUntilDelimiterAlloc(allocator, '\n', std.math.maxInt(usize));
}
