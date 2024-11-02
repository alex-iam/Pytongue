const std = @import("std");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) !void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard optimization options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall. Here we do not
    // set a preferred release mode, allowing the user to decide how to optimize.
    const optimize = b.standardOptimizeOption(.{});

    const lsp_specs = b.createModule(.{
        .root_source_file = b.path("src/lsp_specs/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    const utils = b.createModule(.{
        .root_source_file = b.path("src/utils/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    const server = b.createModule(.{
        .root_source_file = b.path("src/server/root.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{
                .name = "lsp_specs",
                .module = lsp_specs,
            },
            .{
                .name = "utils",
                .module = utils,
            },
        },
    });
    const parser = b.createModule(.{
        .root_source_file = b.path("src/parser/root.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{.{
            .name = "lsp_specs",
            .module = lsp_specs,
        }},
        .link_libc = true,
    });

    parser.addObjectFile(b.path("lib/libtree-sitter.a"));
    parser.addObjectFile(b.path("lib/libtree-sitter-python.a"));

    parser.addIncludePath(b.path("include"));

    const version_contents = try std.fs.cwd().readFileAlloc(
        b.allocator,
        "version",
        32,
    );
    defer b.allocator.free(version_contents);
    const version = std.mem.trim(u8, version_contents, &std.ascii.whitespace);

    const exe_options = b.addOptions();
    exe_options.addOption([]const u8, "version", version);

    const exe = b.addExecutable(.{
        .name = "pytongue",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    exe.root_module.addObjectFile(b.path("lib/libtree-sitter.a"));
    exe.root_module.addObjectFile(b.path("lib/libtree-sitter-python.a"));

    exe.root_module.addIncludePath(b.path("include"));

    exe.root_module.link_libc = true;

    exe.root_module.addOptions("build_options", exe_options);

    exe.root_module.addImport("server", server);
    exe.root_module.addImport("parser", server);
    exe.root_module.addImport("utils", utils);
    exe.root_module.addImport("lsp_specs", lsp_specs);

    // This declares intent for the executable to be installed into the
    // standard location when the user invokes the "install" step (the default
    // step when running `zig build`).
    b.installArtifact(exe);

    // This *creates* a Run step in the build graph, to be executed when another
    // step is evaluated that depends on it. The next line below will establish
    // such a dependency.
    const run_cmd = b.addRunArtifact(exe);

    // By making the run step depend on the install step, it will be run from the
    // installation directory rather than directly from within the cache directory.
    // This is not necessary, however, if the application depends on other installed
    // files, this ensures they will be present and in the expected location.
    run_cmd.step.dependOn(b.getInstallStep());

    // This allows the user to pass arguments to the application in the build
    // command itself, like this: `zig build run -- arg1 arg2 etc`
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    // This creates a build step. It will be visible in the `zig build --help` menu,
    // and can be selected like this: `zig build run`
    // This will evaluate the `run` step rather than the default, which is "install".
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const exe_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/tests.zig"),
        .target = target,
        .test_runner = b.path("test_runner.zig"),
        .optimize = optimize,
    });

    exe_unit_tests.root_module.addImport("parser", parser);
    exe_unit_tests.root_module.addImport("utils", utils);
    exe_unit_tests.root_module.addImport("server", server);
    exe_unit_tests.root_module.addImport("lsp_specs", lsp_specs);

    exe_unit_tests.root_module.link_libc = true;
    exe_unit_tests.root_module.addIncludePath(b.path("include"));
    exe_unit_tests.root_module.addObjectFile(b.path("lib/libtree-sitter.a"));
    exe_unit_tests.root_module.addObjectFile(b.path("lib/libtree-sitter-python.a"));

    exe_unit_tests.root_module.addOptions("build_options", exe_options);

    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

    // Similar to creating the run step earlier, this exposes a `test` step to
    // the `zig build --help` menu, providing a way for the user to request
    // running the unit tests.
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_exe_unit_tests.step);
}
