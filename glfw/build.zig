const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = std.Build.Step.Compile.create(b, .{
        .name = "glfw",
        .kind = .lib,
        .linkage = .static,
        .root_module = .{
            .target = target,
            .optimize = optimize,
        },
    });
    lib.addIncludePath(.{ .path = "include" });
    lib.linkLibC();

    lib.installHeadersDirectory("include/GLFW", "GLFW");
    // GLFW headers depend on these headers, so they must be distributed too.
    const vulkan_headers_dep = b.dependency("vulkan_headers", .{
        .target = target,
        .optimize = optimize,
    });
    lib.installLibraryHeaders(vulkan_headers_dep.artifact("vulkan-headers"));
    if (target.result.os.tag == .linux) {
        const x11_headers_dep = b.dependency("x11_headers", .{
            .target = target,
            .optimize = optimize,
        });
        const wayland_headers_dep = b.dependency("wayland_headers", .{
            .target = target,
            .optimize = optimize,
        });
        lib.linkLibrary(x11_headers_dep.artifact("x11-headers"));
        lib.linkLibrary(wayland_headers_dep.artifact("wayland-headers"));
        lib.installLibraryHeaders(x11_headers_dep.artifact("x11-headers"));
        lib.installLibraryHeaders(wayland_headers_dep.artifact("wayland-headers"));
    }

    if (target.result.isDarwin()) {
        // MacOS: this must be defined for macOS 13.3 and older.
        lib.defineCMacro("__kernel_ptr_semantics", "");
        @import("xcode_frameworks").addPaths(lib);
    }

    // Transitive dependencies, explicit linkage of these works around
    // ziglang/zig#17130
    lib.linkFramework("CFNetwork");
    lib.linkFramework("ApplicationServices");
    lib.linkFramework("ColorSync");
    lib.linkFramework("CoreText");
    lib.linkFramework("ImageIO");

    // Direct dependencies
    lib.linkSystemLibrary("objc");
    lib.linkFramework("IOKit");
    lib.linkFramework("CoreFoundation");
    lib.linkFramework("AppKit");
    lib.linkFramework("CoreServices");
    lib.linkFramework("CoreGraphics");
    lib.linkFramework("Foundation");
    lib.linkFramework("Metal");

    const flags = [_][]const u8{ "-D_GLFW_COCOA", "-Isrc" };
    lib.addCSourceFiles(.{
        .files = &base_sources,
        .flags = &flags,
    });
    lib.addCSourceFiles(.{
        .files = &macos_sources,
        .flags = &flags,
    });
    b.installArtifact(lib);
}

const base_sources = [_][]const u8{
    "src/context.c",
    "src/egl_context.c",
    "src/init.c",
    "src/input.c",
    "src/monitor.c",
    "src/null_init.c",
    "src/null_joystick.c",
    "src/null_monitor.c",
    "src/null_window.c",
    "src/osmesa_context.c",
    "src/platform.c",
    "src/vulkan.c",
    "src/window.c",
};

const macos_sources = [_][]const u8{
    // C sources
    "src/cocoa_time.c",
    "src/posix_module.c",
    "src/posix_thread.c",

    // ObjC sources
    "src/cocoa_init.m",
    "src/cocoa_joystick.m",
    "src/cocoa_monitor.m",
    "src/cocoa_window.m",
    "src/nsgl_context.m",
};
