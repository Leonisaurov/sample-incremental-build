const std = @import("std");

pub fn main() !void {
    std.debug.print("═══ termux-zig sample ═══\n", .{});
    std.debug.print("Version: {s}\n", .{@import("builtin").zig_version_string});
    std.debug.print("Target:  {s}\n", .{@tagName(@import("builtin").target.cpu.arch)});
    std.debug.print("OS:      {s}\n", .{@tagName(@import("builtin").target.os.tag)});
}
