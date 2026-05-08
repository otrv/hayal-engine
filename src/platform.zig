const sokol = @import("sokol");
const slog = sokol.log;
const sapp = sokol.app;
const sglue = sokol.glue;

/// Platform is the platform harness and entry point for the game. It accepts a `comptime T` as the type of the state,
/// along with initial values for platform-related settings, the lifecycle callbacks, and a pointer to `T` as the
/// initial state. The `user_data` holds a pointer to the state and supplies it to every lifecycle callback.
pub fn Platform(comptime T: type) type {
    return struct {
        const Self = @This();

        init_fn: *const fn (user_data: *T) anyerror!void,
        frame_fn: *const fn (user_data: *T, dt: f64, framebuffer_size: [2]f32) anyerror!void,
        deinit_fn: *const fn (user_data: *T) void,
        window_width: u16,
        window_height: u16,
        window_title: [:0]const u8,
        user_data: *T,

        fn init(ud: ?*anyopaque) callconv(.c) void {
            const self: *Self = @ptrCast(@alignCast(ud.?));

            self.init_fn(self.user_data) catch {
                sapp.requestQuit();
                return;
            };
        }

        fn frame(ud: ?*anyopaque) callconv(.c) void {
            const self: *Self = @ptrCast(@alignCast(ud.?));

            const dt: f64 = sapp.frameDuration();
            self.frame_fn(self.user_data, dt, .{ sapp.widthf(), sapp.heightf() }) catch {
                sapp.requestQuit();
                return;
            };
        }

        fn cleanup(ud: ?*anyopaque) callconv(.c) void {
            const self: *Self = @ptrCast(@alignCast(ud.?));

            self.deinit_fn(self.user_data);
        }

        pub fn run(self: *Self) void {
            sapp.run(.{
                .user_data = self,
                .init_userdata_cb = init,
                .frame_userdata_cb = frame,
                .cleanup_userdata_cb = cleanup,
                .width = self.window_width,
                .height = self.window_height,
                .window_title = self.window_title.ptr,
                .icon = .{ .sokol_default = true },
                .logger = .{ .func = slog.func },
                .win32 = .{ .console_attach = true },
            });
        }
    };
}
