const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addStaticLibrary(.{
        .name = "pixman",
        .target = target,
        .optimize = optimize,
    });
    lib.linkLibC();
    if (!target.isWindows()) {
        lib.linkSystemLibrary("pthread");
    }

    lib.addIncludePath(.{ .path = "upstream" });
    lib.addIncludePath(.{ .path = "include" });

    var flags = std.ArrayList([]const u8).init(b.allocator);
    defer flags.deinit();
    try flags.appendSlice(&.{
        "-DHAVE_SIGACTION=1",
        "-DHAVE_ALARM=1",
        "-DHAVE_MPROTECT=1",
        "-DHAVE_GETPAGESIZE=1",
        "-DHAVE_MMAP=1",
        "-DHAVE_GETISAX=1",
        "-DHAVE_GETTIMEOFDAY=1",

        "-DHAVE_FENV_H=1",
        "-DHAVE_SYS_MMAN_H=1",
        "-DHAVE_UNISTD_H=1",

        "-DSIZEOF_LONG=8",
        "-DPACKAGE=foo",

        // There is ubsan
        "-fno-sanitize=undefined",
        "-fno-sanitize-trap=undefined",
    });
    if (!target.isWindows()) {
        try flags.appendSlice(&.{
            "-DHAVE_PTHREADS=1",

            "-DHAVE_POSIX_MEMALIGN=1",
        });
    }

    lib.addCSourceFiles(srcs, flags.items);

    lib.installHeader("include/pixman-version.h", "pixman-version.h");
    lib.installHeadersDirectoryOptions(.{
        .source_dir = .{ .path = "upstream/pixman" },
        .install_dir = .header,
        .install_subdir = "",
        .exclude_extensions = &.{
            ".build",
            ".c",
            ".cc",
            ".hh",
            ".in",
            ".py",
            ".rs",
            ".rl",
            ".S",
            ".ttf",
            ".txt",
        },
    });

    b.installArtifact(lib);
}

const srcs = &.{
    "upstream/pixman/pixman.c",
    "upstream/pixman/pixman-access.c",
    "upstream/pixman/pixman-access-accessors.c",
    "upstream/pixman/pixman-bits-image.c",
    "upstream/pixman/pixman-combine32.c",
    "upstream/pixman/pixman-combine-float.c",
    "upstream/pixman/pixman-conical-gradient.c",
    "upstream/pixman/pixman-filter.c",
    "upstream/pixman/pixman-x86.c",
    "upstream/pixman/pixman-mips.c",
    "upstream/pixman/pixman-arm.c",
    "upstream/pixman/pixman-ppc.c",
    "upstream/pixman/pixman-edge.c",
    "upstream/pixman/pixman-edge-accessors.c",
    "upstream/pixman/pixman-fast-path.c",
    "upstream/pixman/pixman-glyph.c",
    "upstream/pixman/pixman-general.c",
    "upstream/pixman/pixman-gradient-walker.c",
    "upstream/pixman/pixman-image.c",
    "upstream/pixman/pixman-implementation.c",
    "upstream/pixman/pixman-linear-gradient.c",
    "upstream/pixman/pixman-matrix.c",
    "upstream/pixman/pixman-noop.c",
    "upstream/pixman/pixman-radial-gradient.c",
    "upstream/pixman/pixman-region16.c",
    "upstream/pixman/pixman-region32.c",
    "upstream/pixman/pixman-solid-fill.c",
    //"upstream/pixman/pixman-timer.c",
    "upstream/pixman/pixman-trap.c",
    "upstream/pixman/pixman-utils.c",
};
