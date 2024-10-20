const Server = @import("server/server.zig").Server;
const std = @import("std");
const StateManager = @import("server/state.zig").StateManager;
const m = @import("lsp_specs/messages.zig");
const ec = @import("lsp_specs/error_codes.zig");

pub fn baseHandler(_: *StateManager, allocator: std.mem.Allocator, request: []const u8) ?[]const u8 {
    var response: m.ResponseMessage = undefined;
    var parsedRequest = std.json.Value.jsonParse(
        allocator,
        request,
        .{},
    ) catch |err| {
        response = m.ResponseMessage{
            .id = null,
            .@"error" = m.ResponseError{
                .code = ec.ParseError,
                .message = "Request parsing failed",
                .data = .{err},
            },
        };
    };
    return "Your request is very important for us";
}
