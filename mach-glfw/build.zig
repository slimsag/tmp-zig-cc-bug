const builtin = @import("builtin");
const std = @import("std");

pub fn build(b: *std.Build) !void {
    const optimize = b.standardOptimizeOption(.{});
    const target = b.standardTargetOptions(.{});

    const glfw_dep = b.dependency("glfw", .{
        .target = target,
        .optimize = optimize,
    });

    const module = b.addModule("mach-glfw", .{
        .root_source_file = .{ .path = "src/main.zig" },
    });
    module.linkLibrary(glfw_dep.artifact("glfw"));
}
