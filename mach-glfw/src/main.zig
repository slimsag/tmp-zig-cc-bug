pub fn Native(comptime options: anytype) type {
    _ = options;

    const native = @cImport({
        @cDefine("GLFW_INCLUDE_VULKAN", "1");
        @cDefine("GLFW_INCLUDE_NONE", "1");
        @cDefine("GLFW_EXPOSE_NATIVE_COCOA", "1");
        @cDefine("__kernel_ptr_semantics", "");
        @cInclude("GLFW/glfw3.h");
        @cInclude("GLFW/glfw3native.h");
    });

    return struct {
        pub fn getCocoaWindow() ?*anyopaque {
            return native.glfwGetCocoaWindow(undefined);
        }
    };
}
