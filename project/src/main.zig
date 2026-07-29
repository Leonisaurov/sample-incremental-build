const std = @import("std");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("═══ termux-zig sample ═══\n", .{});
    try stdout.print("Version: {s}\n", .{@import("builtin").zig_version_string});
    try stdout.print("Target:  {s}\n", .{@tagName(@import("builtin").target.cpu.arch)});
    try stdout.print("OS:      {s}\n", .{@tagName(@import("builtin").target.os.tag)});

    if (std.os.getenv("PREFIX")) |prefix| {
        try stdout.print("PREFIX:  {s}\n", .{prefix});
    }
}
