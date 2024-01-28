const std = @import("std");
const glfw = @import("mach-glfw");

pub fn main() !void {
    const glfw_native = glfw.Native(.{ .cocoa = true });
    const ns_window = glfw_native.getCocoaWindow(.{ .handle = undefined });
    _ = ns_window;
}
