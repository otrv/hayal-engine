const sokol = @import("sokol");
const slog = sokol.log;
const sg = sokol.gfx;
const sapp = sokol.app;
const sglue = sokol.glue;

/// Game is the platform harness and entry point for a game. It accepts a `comptime T` as the type of the game state,
/// along with initial values for platform-related settings, the game lifecycle callbacks, and a pointer to `T` as
/// the initial game state. The `user_data` holds a pointer to the state and supplies it to every lifecycle
/// callback.
pub fn Game(comptime T: type) type {
    return struct {
        const Self = @This();

        init_fn: *const fn (*T) anyerror!void,
        update_fn: *const fn (*T, f64) anyerror!void,
        render_fn: *const fn (*T, f64) anyerror!void,
        deinit_fn: *const fn (*T) void,
        window_width: u16,
        window_height: u16,
        window_title: [:0]const u8,
        user_data: *T,

        var pass_action: sg.PassAction = .{};

        export fn init(ud: ?*anyopaque) callconv(.c) void {
            const self: *Self = @ptrCast(@alignCast(ud.?));

            sg.setup(.{
                .environment = sglue.environment(),
                .logger = .{ .func = slog.func },
            });
            pass_action.colors[0] = .{
                .load_action = .CLEAR,
                .clear_value = .{ .r = 1, .g = 1, .b = 0, .a = 1 },
            };

            self.init_fn(self.user_data) catch {
                sapp.requestQuit();
                return;
            };
        }

        export fn frame(ud: ?*anyopaque) callconv(.c) void {
            const self: *Self = @ptrCast(@alignCast(ud.?));

            const dt: f64 = sapp.frameDuration();

            self.update_fn(self.user_data, dt) catch {
                sapp.requestQuit();
                return;
            };

            self.render_fn(self.user_data, dt) catch {
                sapp.requestQuit();
                return;
            };

            const g = pass_action.colors[0].clear_value.g + 0.01;
            pass_action.colors[0].clear_value.g = if (g > 1.0) 0.0 else g;
            sg.beginPass(.{ .action = pass_action, .swapchain = sglue.swapchain() });
            sg.endPass();
            sg.commit();
        }

        export fn cleanup(ud: ?*anyopaque) callconv(.c) void {
            const self: *Self = @ptrCast(@alignCast(ud.?));

            self.deinit_fn(self.user_data);

            sg.shutdown();
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
