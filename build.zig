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

    // Main Module
    const mod = b.addModule("hayal", .{ .root_source_file = b.path("src/root.zig"), .target = target, .imports = &.{.{
        .name = "sokol",
        .module = dep_sokol.module("sokol"),
    }} });

    // Create library steps
    const dyn_lib = b.addLibrary(.{ .name = "hayal", .root_module = mod, .linkage = .dynamic });
    const static_lib = b.addLibrary(.{ .name = "hayal", .root_module = mod, .linkage = .static });

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
            .slang = .{ .hlsl5 = true },
        }) catch {
            return;
        };
        dyn_lib.step.dependOn(shdc_step);
    }

    // Install library artifacts
    b.installArtifact(dyn_lib);
    b.installArtifact(static_lib);

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

    // Dynamically create run steps and executables for each example
    const examples_dir = b.build_root.handle.openDir(io, "examples", .{ .iterate = true }) catch {
        return;
    };
    defer examples_dir.close(io);
    var examples_it = examples_dir.iterate();
    while (examples_it.next(io) catch null) |entry| {
        if (entry.kind != .directory) continue;
        const ex_name = b.dupe(entry.name);
        const ex_mod = b.addModule(ex_name, .{ .root_source_file = b.path(b.fmt("examples/{s}/src/main.zig", .{ex_name})), .target = target, .optimize = optimize, .imports = &.{
            .{ .name = "hayal", .module = mod },
        } });
        const ex_exe = b.addExecutable(.{
            .name = ex_name,
            .root_module = ex_mod,
            .use_llvm = true,
        });

        const run_step = b.step(b.fmt("run-{s}", .{ex_name}), b.fmt("Run example {s}", .{ex_name}));
        const run_cmd = b.addRunArtifact(ex_exe);
        run_step.dependOn(&run_cmd.step);
        run_cmd.step.dependOn(b.getInstallStep());
        if (b.args) |args| {
            run_cmd.addArgs(args);
        }
    }
}
