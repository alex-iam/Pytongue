const std = @import("std");
const s = @import("state.zig");
const m = @import("../lsp_specs/messages.zig");
const ec = @import("../lsp_specs/error_codes.zig");
const p = @import("../lsp_specs/params.zig");
const t = @import("../lsp_specs/lsp_types.zig");
const e = @import("../lsp_specs/enums.zig");
const j = @import("../utils/json.zig");
const Config = @import("../utils/config.zig").Config;

pub const Handler = struct {
    stateManager: *s.StateManager,
    allocator: std.mem.Allocator,
    parsedId: ?t.IntOrString = undefined,
    parsedRequest: std.json.Value = undefined,
    config: *Config,

    pub fn init(stateManager: *s.StateManager, allocator: std.mem.Allocator, config: *Config) Handler {
        return Handler{
            .stateManager = stateManager,
            .allocator = allocator,
            .config = config,
        };
    }

    pub fn makeResponse(self: *Handler, response: anytype) []const u8 {
        var strResponse = std.ArrayList(u8).init(self.allocator);
        // FIXME
        std.json.stringify(response, .{}, strResponse.writer()) catch unreachable;
        return strResponse.toOwnedSlice() catch unreachable;
    }

    pub fn makeError(self: *Handler, code: i32, message: []const u8) []const u8 {
        return self.makeResponse(m.ResponseMessage{
            .id = self.parsedId,
            .@"error" = m.ResponseError{
                .code = code,
                .message = message,
            },
        });
    }

    pub fn handleRequest(self: *Handler) []const u8 {
        if (std.meta.stringToEnum(e.RequestMethod, self.parsedRequest.object.get("method").?.string)) |method| {
            switch (method) {
                e.RequestMethod.initialize => {
                    const response = m.ResponseMessage{
                        .id = self.parsedId,
                        .result = p.InitializeResult{
                            .capabilities = .{},
                            .serverInfo = .{
                                .name = self.config.projectName,
                                .version = self.config.projectVersion,
                            },
                        },
                    };
                    self.stateManager.initServer() catch {
                        return self.makeError(ec.InvalidRequest, "Method not allowed");
                    };
                    return self.makeResponse(response);
                },
                e.RequestMethod.shutdown => {
                    self.stateManager.shutdownServer() catch {
                        return self.makeError(ec.InvalidRequest, "Method not allowed");
                    };
                    return self.makeResponse(m.ResponseMessage{ .id = self.parsedId, .result = null });
                },
            }
        } else { // not found in enum
            return self.makeError(ec.MethodNotFound, "Unknown method");
        }
    }

    pub fn parseId(self: *Handler, id: ?std.json.Value) void {
        self.parsedId = null;
        if (id) |id_v| {
            switch (id_v) {
                .integer => |v| self.parsedId = t.IntOrString{ .integer = v },
                .string => |v| self.parsedId = t.IntOrString{ .string = v },
                else => {},
            }
        }
    }

    pub fn handle(self: *Handler, request: []const u8) ?[]const u8 {
        defer {
            self.parsedId = null;
            self.parsedRequest = undefined;
        }
        self.parsedRequest = j.parseValue(
            self.allocator,
            request,
        ) catch |err| {
            std.log.debug("{any}", .{err});
            return self.makeError(ec.ParseError, "Request parsing failed");
        };
        // TODO pass ID's
        if (self.stateManager.state == s.ServerState.Shutdown) {
            return self.makeError(ec.InvalidRequest, "Server is shutdown");
        }

        self.parseId(self.parsedRequest.object.get("id"));

        // RequestMessage
        if (self.parsedId) |_| {
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
                return self.makeError(ec.MethodNotFound, "Unknown method");
            }
            return null;
        }
    }
};
