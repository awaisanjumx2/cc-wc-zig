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

    if (args.items.len == 0) {
        return;
    }

    const file_name = args.items[args.items.len - 1];
    const flags = if (args.items.len > 1)
        args.items[0 .. args.items.len - 1]
    else
        &[_][]const u8{};

    var file: std.fs.File = undefined;
    FileService.openFile(file_name, &file) catch {
        std.process.exit(0);
    };
    defer file.close();

    try CCService.do_counting(@constCast(flags), &file);
    try utils.bufferedPrint(" {s}\n", .{file_name});
}
