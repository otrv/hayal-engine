const std = @import("std");
const sokol = @import("sokol");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Dependencies
    const dep_sokol = b.dependency("sokol", .{
        .target = target,
        .optimize = optimize,
    });
    const mod_sokol = dep_sokol.module("sokol");

    // Main Module
    const mod = b.addModule("hayal", .{ .root_source_file = b.path("src/root.zig"), .target = target, .imports = &.{.{
        .name = "sokol",
        .module = mod_sokol,
    }} });

    // The executable
    const exe = b.addExecutable(.{
        .name = "hayal",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "hayal", .module = mod },
                .{ .name = "sokol", .module = mod_sokol },
            },
        }),
        .use_llvm = true,
    });

    b.installArtifact(exe);

    // Run step
    const run_step = b.step("run", "Run the app");
    const run_cmd = b.addRunArtifact(exe);
    run_step.dependOn(&run_cmd.step);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    // ZLS Check Step
    const exe_check = b.addExecutable(.{ .name = "hayal", .root_module = mod });
    const check = b.step("check", "Check if foo compiles");
    check.dependOn(&exe_check.step);

    // Test Step
    const mod_tests = b.addTest(.{
        .root_module = mod,
    });
    const run_mod_tests = b.addRunArtifact(mod_tests);
    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_mod_tests.step);

    // Compile available shaders
    const io = b.graph.io;
    const shaders_dir = b.build_root.handle.openDir(io, "shaders", .{ .iterate = true }) catch {
        return;
    };
    defer shaders_dir.close(io);
    var shaders_it = shaders_dir.iterate();
    while (shaders_it.next(io) catch null) |entry| {
        const shd_name = b.dupe(entry.name);
        const dep_shdc = dep_sokol.builder.dependency("shdc", .{});
        const shdc_step = sokol.shdc.createSourceFile(b, .{
            .shdc_dep = dep_shdc,
            .input = b.fmt("shaders/{s}", .{shd_name}),
            .output = b.fmt("src/shaders/{s}.zig", .{shd_name}),
            .slang = .{
                .glsl430 = true,
                .glsl300es = true,
                .hlsl5 = true,
                .metal_macos = true,
                .wgsl = true,
            },
        }) catch {
            return;
        };
        exe.step.dependOn(shdc_step);
        run_step.dependOn(shdc_step);
    }
}
