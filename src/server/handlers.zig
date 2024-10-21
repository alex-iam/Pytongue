const std = @import("std");
const s = @import("state.zig");
const m = @import("../lsp_specs/messages.zig");
const ec = @import("../lsp_specs/error_codes.zig");
const p = @import("../lsp_specs/params.zig");
const t = @import("../lsp_specs/lsp_types.zig");
const e = @import("../lsp_specs/enums.zig");
const j = @import("../utils/json.zig");

pub const Handler = struct {
    stateManager: *s.StateManager,
    allocator: std.mem.Allocator,
    id: ?std.json.Value = undefined,
    parsedRequest: std.json.Value = undefined,

    pub fn init(stateManager: *s.StateManager, allocator: std.mem.Allocator) Handler {
        return Handler{
            .stateManager = stateManager,
            .allocator = allocator,
        };
    }

    pub fn makeResponse(self: *Handler, response: anytype) []const u8 {
        var strResponse = std.ArrayList(u8).init(self.allocator);
        // FIXME
        std.json.stringify(response, .{}, strResponse.writer()) catch unreachable;
        return strResponse.toOwnedSlice() catch unreachable;
    }

    pub fn makeError(self: *Handler, code: i32, id: ?t.IntOrString, message: []const u8) []const u8 {
        return self.makeResponse(m.ResponseMessage{
            .id = id,
            .@"error" = m.ResponseError{
                .code = code,
                .message = message,
            },
        });
    }

    pub fn handleRequest(self: *Handler) []const u8 {
        var parsedId: t.IntOrString = undefined;
        switch (self.id.?) {
            .integer => |v| parsedId = t.IntOrString{ .integer = v },
            .string => |v| parsedId = t.IntOrString{ .string = v },
            else => {},
        }
        if (std.meta.stringToEnum(e.RequestMethod, self.parsedRequest.object.get("method").?.string)) |method| {
            switch (method) {
                e.RequestMethod.initialize => {
                    const response = m.ResponseMessage{
                        .id = parsedId,
                        .result = p.InitializeResult{
                            .capabilities = .{},
                            .serverInfo = .{
                                .name = "Pytongue",
                                .version = "0.1.0",
                            },
                        },
                    };
                    self.stateManager.initServer() catch {
                        return self.makeError(ec.InvalidRequest, parsedId, "Method not allowed");
                    };
                    return self.makeResponse(response);
                },
                e.RequestMethod.shutdown => {
                    self.stateManager.shutdownServer() catch {
                        return self.makeError(ec.InvalidRequest, parsedId, "Method not allowed");
                    };
                    return self.makeResponse(m.ResponseMessage{ .id = parsedId, .result = null });
                },
            }
        } else { // not found in enum
            return self.makeError(ec.MethodNotFound, parsedId, "Unknown method");
        }
    }

    pub fn handle(self: *Handler, request: []const u8) ?[]const u8 {
        self.parsedRequest = j.parseValue(
            self.allocator,
            request,
        ) catch |err| {
            std.log.debug("{any}", .{err});
            return self.makeError(ec.ParseError, null, "Request parsing failed");
        };
        // TODO pass ID's
        if (self.stateManager.state == s.ServerState.Shutdown) {
            return self.makeError(ec.InvalidRequest, null, "Server is shutdown");
        }

        self.id = self.parsedRequest.object.get("id");
        // RequestMessage
        if (self.id != null) {
            return self.handleRequest();
        } else { // NotificationMessage
            if (std.meta.stringToEnum(
                e.NotificationMethod,
                self.parsedRequest.object.get("method").?.string,
            )) |method| {
                switch (method) {
                    e.NotificationMethod.exit => {
                        self.stateManager.exitServer() catch {
                            std.process.exit(1);
                        };
                    },
                    e.NotificationMethod.initialized => {},
                }
            } else {
                return self.makeError(ec.MethodNotFound, null, "Unknown method");
            }
            return null;
        }
    }
};
