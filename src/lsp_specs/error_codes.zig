// This file is a part of Pytongue.
// 
// Copyright (C) 2024 Oleksandr Korzh
// 
// Pytongue is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// Pytongue is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with Pytongue. If not, see <https://www.gnu.org/licenses/>.

pub const ParseError = -32700;
pub const InvalidRequest = -32600;
pub const MethodNotFound = -32601;
pub const InvalidParams = -32602;
pub const InternalError = -32603;

/// This is the start range of JSON-RPC reserved error codes.
/// It doesn't denote a real error code. No LSP error codes should
/// be defined between the start and end range. For backwards
/// compatibility the `ServerNotInitialized` and the `UnknownErrorCode`
/// are left in the range.
///
/// @since 3.16.0
pub const jsonrpcReservedErrorRangeStart = -32099;
/// @deprecated use jsonrpcReservedErrorRangeStart
pub const serverErrorStart = jsonrpcReservedErrorRangeStart;

/// Error code indicating that a server received a notification or
/// request before the server has received the `initialize` request.
pub const ServerNotInitialized = -32002;
pub const UnknownErrorCode = -32001;

/// This is the end range of JSON-RPC reserved error codes.
/// It doesn't denote a real error code.
///
/// @since 3.16.0
pub const jsonrpcReservedErrorRangeEnd = -32000;
/// @deprecated use jsonrpcReservedErrorRangeEnd
pub const serverErrorEnd = jsonrpcReservedErrorRangeEnd;

/// This is the start range of LSP specific error codes.
/// It doesn't denote a real error code.
///
/// @since 3.16.0
pub const lspReservedErrorRangeStart = -32899;

/// A request failed but it was syntactically correct, e.g. the
/// method name is known and the parameters were valid. The error
/// message should contain human readable information about why
/// the request failed.
///
/// @since 3.17.0
pub const RequestFailed = -32803;

/// The server cancelled the request. This error code should
/// only be used for requests that explicitly support being
/// server cancellable.
///
/// @since 3.17.0
pub const ServerCancelled = -32802;

/// The server detected that the content of a document got
/// modified outside normal conditions. A server should
/// NOT send this error code if it detects a content change
/// in it unprocessed messages. The result even computed
/// on an older state might still be useful for the client.
///
/// If a client decides that a result is not of any use anymore
/// the client should cancel the request.
pub const ContentModified = -32801;

/// The client has canceled a request and a server has detected
/// the cancel.
pub const RequestCancelled = -32800;

/// This is the end range of LSP specific error codes.
/// It doesn't denote a real error code.
///
/// @since 3.16.0
pub const lspReservedErrorRangeEnd = -32800;
