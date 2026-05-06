const Allocator = @import("std").mem.Allocator;

const sokol = @import("sokol");
const slog = sokol.log;
const sg = sokol.gfx;
const sapp = sokol.app;
const sglue = sokol.glue;

/// Game is the platform harness and entry point for a game. It accepts a `comptime T` as the type of the game state,
/// along with initial values for platform-related settings, the game lifecycle callbacks, and an instance of `T` as
/// the initial game state. The `user_data` holds a pointer to the state and supplies it to every lifecycle callback.
pub fn Game(comptime T: type) type {
    return struct {
        const Self = @This();

        init_fn: *const fn (user_data: *T) anyerror!void,
        update_fn: *const fn (user_data: *T, delta_time: f64) anyerror!void,
        render_fn: *const fn (user_data: *T, delta_time: f64) anyerror!void,
        deinit_fn: *const fn (user_data: *T) void,
        window_width: u16,
        window_height: u16,
        window_title: [*:0]const u8,
        user_data: T = T{},

        const state = struct {
            var game: ?*Self = null;
            var pass_action: sg.PassAction = .{};
        };

        export fn init() void {
            if (state.game) |game| {
                game.init_fn(&game.user_data) catch {
                    sapp.requestQuit();
                    return;
                };
            } else {
                sapp.requestQuit();
            }

            sg.setup(.{
                .environment = sglue.environment(),
                .logger = .{ .func = slog.func },
            });
            state.pass_action.colors[0] = .{
                .load_action = .CLEAR,
                .clear_value = .{ .r = 1, .g = 1, .b = 0, .a = 1 },
            };
        }

        export fn frame() void {
            const dt: f64 = sapp.frameDuration();

            if (state.game) |game| {
                game.update_fn(&game.user_data, dt) catch {
                    sapp.requestQuit();
                    return;
                };
                game.render_fn(&game.user_data, dt) catch {
                    sapp.requestQuit();
                    return;
                };
            }

            const g = state.pass_action.colors[0].clear_value.g + 0.01;
            state.pass_action.colors[0].clear_value.g = if (g > 1.0) 0.0 else g;
            sg.beginPass(.{ .action = state.pass_action, .swapchain = sglue.swapchain() });
            sg.endPass();
            sg.commit();
        }

        export fn cleanup() void {
            if (state.game) |game| {
                game.deinit_fn(&game.user_data);
            }

            sg.shutdown();
        }

        pub fn run(self: *Self) void {
            state.game = self;

            sapp.run(.{
                .init_cb = init,
                .frame_cb = frame,
                .cleanup_cb = cleanup,
                .width = self.window_width,
                .height = self.window_height,
                .window_title = self.window_title,
                .icon = .{ .sokol_default = true },
                .logger = .{ .func = slog.func },
                .win32 = .{ .console_attach = true },
            });
        }
    };
}
