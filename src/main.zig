const std = @import("std");
const utils = @import("utils");

const ArgsParser = utils.ArgsParser;
const CCService = utils.CCService;
const FileService = utils.FileService;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var args = std.array_list.Managed([]const u8).init(allocator);
    try ArgsParser.parse(&args);

    var is_stdin = false;
    var flags: [][]const u8 = &[_][]const u8{};
    var file_name: []const u8 = "";

    if (args.items.len == 0) {
        is_stdin = true;
    } else {
        const last_arg = args.items[args.items.len - 1];
        if (last_arg.len > 0 and last_arg[0] == '-') {
            is_stdin = true;
            flags = args.items;
        } else {
            file_name = last_arg;
            flags = if (args.items.len > 1)
                args.items[0 .. args.items.len - 1]
            else
                flags;
        }
    }

    if (is_stdin) {
        var stdin = std.fs.File.stdin();
        try CCService.do_counting(@constCast(flags), &stdin);
        try utils.bufferedPrint("\n", .{});
    } else {
        var file: std.fs.File = undefined;
        FileService.openFile(file_name, &file) catch {
            std.process.exit(0);
        };
        defer file.close();

        try CCService.do_counting(@constCast(flags), &file);
        try utils.bufferedPrint(" {s}\n", .{file_name});
    }
}
