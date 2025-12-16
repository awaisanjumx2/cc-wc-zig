const std = @import("std");

pub fn bufferedPrint(comptime fmt: []const u8, args: anytype) !void {
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout = &stdout_writer.interface;

    try stdout.print(fmt, args);

    try stdout.flush();
}

pub const ArgsParser = struct {
    pub fn parse(args: *std.array_list.Managed([]const u8)) !void {
        var gpa = std.heap.GeneralPurposeAllocator(.{}){};
        const allocator = gpa.allocator();
        var args_iter = try std.process.argsWithAllocator(allocator);
        defer args_iter.deinit();

        _ = args_iter.next();

        while (args_iter.next()) |arg| {
            try args.append(arg);
        }
    }
};

pub const FileService = struct {
    pub fn openFile(file_name: []const u8, file: *std.fs.File) anyerror!void {
        const cwd = std.fs.cwd();

        file.* = cwd.openFile(file_name, .{ .mode = .read_only }) catch |err| {
            if (err == error.FileNotFound) {
                try bufferedPrint("{s}: open: No such file or directory\n", .{file_name});
            } else {
                try bufferedPrint("{s}: {any}\n", .{ file_name, err });
            }
            return error.FileNotFound;
        };

        const stat = file.stat() catch |err| {
            try bufferedPrint("{s}: stat: {any}\n", .{ file_name, err });
            return error.FileError;
        };

        if (stat.kind == .directory) {
            try bufferedPrint("{s}: read: Is a directory\n", .{file_name});
            return error.NotAFile;
        }
    }
};

pub const CCService = struct {
    pub fn do_counting(flags: [][]const u8, file: *std.fs.File) !void {
        const total_flags = flags.len;

        try file.seekTo(0);
        var buf: [4096]u8 = undefined;

        var word_count: usize = 0;
        var byte_count: usize = 0;
        var char_count: usize = 0;
        var line_count: usize = 0;
        var in_word: bool = false;

        while (true) {
            const n = try file.read(&buf);
            if (n == 0) break;

            for (buf[0..n]) |c| {
                byte_count += 1;

                if (c == '\n') {
                    line_count += 1;
                }

                if (std.ascii.isWhitespace(c)) {
                    if (in_word) {
                        in_word = false;
                    }
                } else {
                    if (!in_word) {
                        word_count += 1;
                        in_word = true;
                    }
                }

                // UTF-8 continuation bytes start with 10xxxxxx (0x80-0xBF)
                // Count all bytes that are NOT continuation bytes
                if (c & 0xC0 != 0x80) {
                    char_count += 1;
                }
            }
        }

        if (total_flags == 0 or contains(flags, "-l")) {
            try bufferedPrint("    {d}", .{line_count});
        }

        if (total_flags == 0 or contains(flags, "-w")) {
            try bufferedPrint("    {d}", .{word_count});
        }

        if (total_flags == 0 or (contains(flags, "-c") and !contains(flags, "-m"))) {
            try bufferedPrint("    {d}", .{byte_count});
        }

        if (contains(flags, "-m")) {
            try bufferedPrint("    {d}", .{char_count});
        }
    }

    fn contains(haystack: [][]const u8, needle: *const [2:0]u8) bool {
        for (haystack) |item| {
            if (std.mem.eql(u8, item, needle)) return true;
        }
        return false;
    }
};
