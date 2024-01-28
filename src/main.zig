const std = @import("std");
const glfw = @import("mach-glfw");

pub fn main() !void {
    const ns_window = glfw.Native(.{}).getCocoaWindow();
    _ = ns_window;
}
