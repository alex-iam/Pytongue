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

const enums = @import("../enums.zig");
const base_c = @import("base.zig");

pub const DiagnosticClientCapabilities = struct {
    ///
    /// Whether implementation supports dynamic registration. If this is set to
    /// `true` the client supports the new
    /// `(TextDocumentRegistrationOptions & StaticRegistrationOptions)`
    /// return value for the corresponding server capability as well.
    ///
    const dynamicRegistration: ?bool = null;
    ///
    /// Whether the client supports related documents for documents diagnostic
    /// pulls.
    ///
    const relatedDocumentSupport: ?bool = null;
};

pub const InlayHintClientCapabilities = struct {
    ///
    /// Whether inlay hints support dynamic registration.
    ///
    const dynamicRegistration: ?bool = null;
    ///
    /// Indicates which properties a client can resolve lazily on an inlay
    /// hint.
    ///
    const resolveSupport: ?struct {
        const properties: [][]const u8 = undefined;
    } = null;
};

pub const SemanticTokensClientCapabilities = struct {
    ///
    /// Whether implementation supports dynamic registration. If this is set to
    /// `true` the client supports the new `(TextDocumentRegistrationOptions &
    /// StaticRegistrationOptions)` return value for the corresponding server
    /// capability as well.
    ///
    const dynamicRegistration: ?bool = null;

    ///
    /// Which requests the client supports and might send to the server
    /// depending on the server's capability. Please note that clients might not
    /// show semantic tokens or degrade some of the user experience if a range
    /// or full request is advertised by the client but not provided by the
    /// server. If for example the client capability `requests.full` and
    /// `request.range` are both set to true but the server only provides a
    /// range provider the client might not render a minimap correctly or might
    /// even decide to not show any semantic tokens at all.
    ///
    const requests: struct {
        ///
        /// The client will send the `textDocument/semanticTokens/range` request if
        /// the server provides a corresponding handler.
        ///
        const range: ?union { Boolean: bool, Struct: struct {} } = null;
        ///
        /// The client will send the `textDocument/semanticTokens/full` request if
        /// the server provides a corresponding handler.
        ///
        const full: ?union {
            Boolean: bool,
            Struct: struct {
                ///
                /// The client will send the `textDocument/semanticTokens/full/delta`
                /// request if the server provides a corresponding handler.
                ///
                const delta: ?bool = null;
            },
        } = null;
    } = undefined;
    ///
    /// The token types that the client supports.
    ///
    const tokenTypes: [][]const u8 = undefined;
    ///
    /// The token modifiers that the client supports.
    ///
    const tokenModifiers: [][]const u8 = undefined;
    ///
    /// The formats the clients supports.
    ///
    const formats: [][]const u8 = undefined;
    ///
    /// Whether the client supports tokens that can overlap each other.
    ///
    const overlappingTokenSupport: ?bool = null;
    ///
    /// Whether the client supports tokens that can span multiple lines.
    ///
    const multilineTokenSupport: ?bool = null;
    ///
    /// Whether the client allows the server to actively cancel a
    /// semantic token request, e.g. supports returning
    /// ErrorCodes.ServerCancelled. If a server does the client
    /// needs to retrigger the request.
    ///
    /// @since 3.17.0
    ///
    const serverCancelSupport: ?bool = null;
    ///
    /// Whether the client uses semantic tokens to augment existing
    /// syntax tokens. If set to `true` client side created syntax
    /// tokens and semantic tokens are both used for colorization. If
    /// set to `false` the client only uses the returned semantic tokens
    /// for colorization.
    ///
    /// If the value is `undefined` then the client behaviour is not
    /// specified.
    ///
    /// @since 3.17.0
    ///
    const augmentsSyntaxTokens: ?bool = null;
};

pub const FoldingRangeClientCapabilities = struct {
    ///
    /// Whether implementation supports dynamic registration for folding range
    /// providers. If this is set to `true` the client supports the new
    /// `FoldingRangeProviderOptions` return value for the corresponding
    /// server capability as well.
    ///
    const dynamicRegistration: ?bool = null;
    ///
    /// The maximum number of folding ranges that the client prefers to receive
    /// per document. The value serves as a hint, servers are free to follow the
    /// limit.
    ///
    const rangeLimit: ?u64 = null;
    ///
    /// If set, the client signals that it only supports folding complete lines.
    /// If set, client will ignore specified `startCharacter` and `endCharacter`
    /// properties in a FoldingRange.
    ///
    const lineFoldingOnly: ?bool = null;
    ///
    /// Specific options for the folding range kind.
    ///
    /// @since 3.17.0
    ///
    const foldingRangeKind: ?struct {
        const valueSet: ?[]enums.FoldingRangeKind = null;
    } = null;
    ///
    /// Specific options for the folding range.
    ///
    /// @since 3.17.0
    ///
    const foldingRange: ?struct {
        const collapsedText: ?bool = null;
    } = null;
};

pub const PublishDiagnosticsClientCapabilities = struct {
    ///
    /// Whether the clients accepts diagnostics with related information.
    ///
    const relatedInformation: ?bool = null;
    ///
    /// Client supports the tag property to provide meta data about a diagnostic.
    /// Clients supporting tags have to handle unknown tags gracefully.
    ///
    /// @since 3.15.0
    ///
    const tagSupport: ?struct {
        const valueSet: ?[]enums.DiagnosticTag = null;
    } = null;
    ///
    /// Whether the client interprets the version property of the
    /// `textDocument/publishDiagnostics` notification's parameter.
    ///
    /// @since 3.15.0
    ///
    const versionSupport: ?bool = null;
    ///
    /// Client supports a codeDescription property
    ///
    /// @since 3.16.0
    ///
    const codeDescriptionSupport: ?bool = null;
    ///
    /// Whether code action supports the `data` property which is
    /// preserved between a `textDocument/publishDiagnostics` and a
    /// `textDocument/codeAction` request.
    ///
    /// @since 3.16.0
    ///
    const dataSupport: ?bool = null;
};

pub const RenameClientCapabilities = struct {
    ///
    /// Whether rename supports dynamic registration.
    ///
    const dynamicRegistration: ?bool = null;
    ///
    /// Client supports testing for validity of rename operations
    /// before execution.
    ///
    /// @since 3.12.0
    ///
    const prepareSupport: ?bool = null;
    ///
    /// Client supports the default behavior result
    /// (`{ defaultBehavior: boolean }`).
    ///
    /// The value indicates the default behavior used by the
    /// client.
    ///
    /// @since 3.16.0
    ///
    const prepareSupportDefaultBehavior: ?u64 = null;
    ///
    /// Whether the client honors the change annotations in
    /// text edits and resource operations returned via the
    /// rename request's workspace edit by for example presenting
    /// the workspace edit in the user interface and asking
    /// for confirmation.
    ///
    /// @since 3.16.0
    ///
    const honorsChangeAnnotations: ?bool = null;
};

pub const DocumentLinkClientCapabilities = struct {
    ///
    /// Whether document link supports dynamic registration.
    ///
    const dynamicRegistration: ?bool = null;
    ///
    /// Whether the client support the `tooltip` property on `DocumentLink`.
    ///
    /// @since 3.15
    ///
    const tooltipSupport: ?bool = null;
};

pub const CodeActionClientCapabilities = struct {
    ///
    /// Whether code action supports dynamic registration.
    ///
    const dynamicRegistration: ?bool = null;
    ///
    /// The client support code action literals as a valid
    /// response of the `textDocument/codeAction` request.
    ///
    const codeActionLiteralSupport: ?struct {
        ///
        /// The code action kind is support with the following value
        /// set.
        ///
        const codeActionKind: ?struct {
            const valueSet: ?[][]const u8 = null;
        } = null;
    } = null;
    ///
    /// Whether code action supports the `isPreferred` property.
    ///
    /// @since 3.15
    ///
    const isPreferredSupport: ?bool = null;
    ///
    /// Whether code action supports the `disabled` property.
    ///
    /// @since 3.15.0
    ///
    const disabledSupport: ?bool = null;
    ///
    /// Whether code action supports the `data` property which is
    /// preserved between a `textDocument/codeAction` and a
    /// `codeAction/resolve` request.
    ///
    /// @since 3.16.0
    ///
    const dataSupport: ?bool = null;
    ///
    /// Whether the client supports resolving additional code action
    /// properties via a separate `codeAction/resolve` request.
    ///
    /// @since 3.16.0
    ///
    const resolveSupport: ?struct {
        const properties: [][]const u8 = undefined;
    } = null;
    ///
    /// Whether the client supports the change annotations
    /// in text edits and resource operations returned via the
    /// `CodeAction#edit` property by for example presenting
    /// the workspace edit in the user interface and asking
    /// for confirmation.
    ///
    /// @since 3.16.0
    ///
    const honorsChangeAnnotations: ?bool = null;
};

pub const DocumentSymbolClientCapabilities = struct {
    ///
    /// Whether document symbol supports dynamic registration.
    ///
    const dynamicRegistration: ?bool = null;
    ///
    /// Specific capabilities for the `SymbolKind` in the
    /// `textDocument/documentSymbol` request.
    ///
    const symbolKind: ?struct {
        const valueSet: ?[]enums.SymbolKind = null;
    } = null;
    ///
    /// The client supports hierarchical document symbols.
    ///
    const hierarchicalDocumentSymbolSupport: ?bool = null;
    ///
    /// The client supports tags on `SymbolInformation`. Tags are supported on
    /// `DocumentSymbol` if `hierarchicalDocumentSymbolSupport` is set to true.
    /// Clients supporting tags have to handle unknown tags gracefully.
    ///
    /// @since 3.16.0
    ///
    const tagSupport: ?struct {
        const valueSet: ?[]u64 = null;
    } = null;
    ///
    /// The client supports an additional label presented in the UI when
    /// showing references.
    ///
    /// @since 3.17.0
    ///
    const labelSupport: ?bool = null;
};

pub const HoverClientCapabilities = struct {
    ///
    /// Whether hover supports dynamic registration.
    ///
    const dynamicRegistration: ?bool = null;
    ///
    /// Client supports the follow content formats for the content
    /// property. The order describes the preferred format of the client.
    ///
    const contentFormat: ?[]enums.MarkupKind = null;
};

pub const SignatureInformation = struct {
    ///
    /// Client supports the follow content formats for the documentation
    /// property. The order describes the preferred format of the client.
    ///
    const documentationFormat: ?[]enums.MarkupKind = null;
    ///
    /// Client capabilities specific to parameter information.
    ///
    const parameterInformation: ?struct {
        const labelOffsetSupport: ?bool = null;
    } = null;
    ///
    /// The client supports the `activeParameter` property on
    /// `SignatureInformation` literal.
    ///
    /// @since 3.16.0
    ///
    const activeParameterSupport: ?bool = null;
};

pub const SignatureHelpClientCapabilities = struct {
    ///
    /// Whether hover supports dynamic registration.
    ///
    const dynamicRegistration: ?bool = null;
    ///
    /// The client supports the following `SignatureInformation`
    /// specific properties.
    ///
    const signatureInformation: ?SignatureInformation = null;
    ///
    /// The client supports to send additional context information for a
    /// `textDocument/signatureHelp` request. A client that opts into
    /// contextSupport will also support the `retriggerCharacters` on
    /// `SignatureHelpOptions`.
    ///
    /// @since 3.15.0
    ///
    const contextSupport: ?bool = null;
};

pub const TextDocumentSyncClientCapabilities = struct {
    ///
    /// Whether text document synchronization supports dynamic registration.
    ///
    const dynamicRegistration: ?bool = null;
    ///
    /// The client supports sending will save notifications.
    ///
    const willSave: ?bool = null;
    ///
    /// The client supports sending a will save request and
    /// waits for a response providing text edits which will
    /// be applied to the document before it is saved.
    ///
    const willSaveWaitUntil: ?bool = null;
    ///
    /// The client supports did save notifications.
    ///
    const didSave: ?bool = null;
};

pub const CompletionItem = struct {
    ///
    /// Client supports snippets as insert text.
    ///
    /// A snippet can define tab stops and placeholders with `$1`, `$2`
    /// and `${3:foo}`. `$0` defines the final tab stop, it defaults to
    /// the end of the snippet. Placeholders with equal identifiers are
    /// linked, that is typing in one will update others too.
    ///
    const snippetSupport: ?bool = null;
    ///
    /// Client supports commit characters on a completion item.
    ///
    const commitCharactersSupport: ?bool = null;
    ///
    /// Client supports the follow content formats for the documentation
    /// property. The order describes the preferred format of the client.
    ///
    const documentationFormat: ?[]enums.MarkupKind = null;
    ///
    /// Client supports the deprecated property on a completion item.
    ///
    const deprecatedSupport: ?bool = null;
    ///
    /// Client supports the preselect property on a completion item.
    ///
    const preselectSupport: ?bool = null;
    ///
    /// Client supports the tag property on a completion item. Clients
    /// supporting tags have to handle unknown tags gracefully. Clients
    /// especially need to preserve unknown tags when sending a completion
    /// item back to the server in a resolve call.
    ///
    /// @since 3.15.0
    ///
    const tagSupport: ?struct {
        const valueSet: ?[]u64 = null;
    } = null;
    ///
    /// Client supports insert replace edit to control different behavior if
    /// a completion item is inserted in the text or should replace text.
    ///
    /// @since 3.16.0
    ///
    const insertReplaceSupport: ?bool = null;
    ///
    /// Indicates which properties a client can resolve lazily on a
    /// completion item. Before version 3.16.0 only the predefined properties
    /// `documentation` and `details` could be resolved lazily.
    ///
    /// @since 3.16.0
    ///
    const resolveSupport: ?struct {
        const properties: [][]const u8 = undefined;
    } = null;
    ///
    /// The client supports the `insertTextMode` property on
    /// a completion item to override the whitespace handling mode
    /// as defined by the client (see `insertTextMode`).
    ///
    /// @since 3.16.0
    ///
    const insertTextModeSupport: ?struct {
        const valueSet: ?[]enums.InsertTextMode = null;
    } = null;
    ///
    /// The client has support for completion item label
    /// details (see also `CompletionItemLabelDetails`).
    ///
    /// @since 3.17.0
    ///
    const labelDetailsSupport: ?bool = null;
};

pub const CompletionClientCapabilities = struct {
    ///
    /// Whether text document synchronization supports dynamic registration.
    ///
    const dynamicRegistration: ?bool = null;
    ///
    /// The client supports the following `CompletionItem` specific
    /// capabilities.
    ///
    const completionItem: ?CompletionItem = null;

    const completionItemKind: ?struct {
        const valueSet: ?[]enums.CompletionItemKind = null;
    } = null;
    ///
    /// The client supports to send additional context information for a
    /// `textDocument/completion` request.
    ///
    const contextSupport: ?bool = null;
    ///
    /// The client's default when the completion item doesn't provide a
    /// `insertTextMode` property.
    ///
    /// @since 3.17.0
    ///
    const insertTextMode: ?enums.InsertTextMode = null;
    ///
    /// The client supports the following `CompletionList` specific
    /// capabilities.
    ///
    /// @since 3.17.0
    ///
    const completionList: ?struct {
        const itemDefaults: ?[]const u8 = null;
    } = null;
};

pub const TextDocumentClientCapabilities = struct {
    const synchronization: ?TextDocumentSyncClientCapabilities = null;
    ///
    /// Capabilities specific to the `textDocument/completion` request.
    ///
    const completion: ?CompletionClientCapabilities = null;
    ///
    /// Capabilities specific to the `textDocument/hover` request.
    ///
    const hover: ?HoverClientCapabilities = null;
    ///
    /// Capabilities specific to the `textDocument/signatureHelp` request.
    ///
    const signatureHelp: ?SignatureHelpClientCapabilities = null;
    ///
    /// Capabilities specific to the `textDocument/declaration` request.
    ///
    /// @since 3.14.0
    ///
    const declaration: ?base_c.BaseLinkSupport = null;
    ///
    /// Capabilities specific to the `textDocument/definition` request.
    ///
    const definition: ?base_c.BaseLinkSupport = null;
    ///
    /// Capabilities specific to the `textDocument/typeDefinition` request.
    ///
    /// @since 3.6.0
    ///
    const typeDefinition: ?base_c.BaseLinkSupport = null;
    ///
    /// Capabilities specific to the `textDocument/implementation` request.
    ///
    /// @since 3.6.0
    ///
    const implementation: ?base_c.BaseLinkSupport = null;
    ///
    /// Capabilities specific to the `textDocument/references` request.
    ///
    const references: ?base_c.BaseDynamicRegistration = null;
    ///
    /// Capabilities specific to the `textDocument/documentHighlight` request.
    ///
    const documentHighlight: ?base_c.BaseDynamicRegistration = null;
    ///
    /// Capabilities specific to the `textDocument/documentSymbol` request.
    ///
    const documentSymbol: ?DocumentSymbolClientCapabilities = null;
    ///
    /// Capabilities specific to the `textDocument/codeAction` request.
    ///
    const codeAction: ?CodeActionClientCapabilities = null;
    ///
    /// Capabilities specific to the `textDocument/codeLens` request.
    ///
    const codeLens: ?base_c.BaseDynamicRegistration = null;
    ///
    /// Capabilities specific to the `textDocument/documentLink` request.
    ///
    const documentLink: ?DocumentLinkClientCapabilities = null;
    ///
    /// Capabilities specific to the `textDocument/documentColor` and the
    /// `textDocument/colorPresentation` request.
    ///
    /// @since 3.6.0
    ///
    const colorProvider: ?base_c.BaseDynamicRegistration = null;
    ///
    /// Capabilities specific to the `textDocument/formatting` request.
    ///
    const formatting: ?base_c.BaseDynamicRegistration = null;
    ///
    /// Capabilities specific to the `textDocument/rangeFormatting` request.
    ///
    const rangeFormatting: ?base_c.BaseDynamicRegistration = null;
    ///
    /// Capabilities specific to the `textDocument/onTypeFormatting` request.
    ///
    const onTypeFormatting: ?base_c.BaseDynamicRegistration = null;
    ///
    /// Capabilities specific to the `textDocument/rename` request.
    ///
    const rename: ?RenameClientCapabilities = null;
    ///
    /// Capabilities specific to the `textDocument/publishDiagnostics`
    /// notification.
    ///
    const publishDiagnostics: ?PublishDiagnosticsClientCapabilities = null;
    ///
    /// Capabilities specific to the `textDocument/foldingRange` request.
    ///
    /// @since 3.10
    ///
    const foldingRange: ?FoldingRangeClientCapabilities = null;
    ///
    /// Capabilities specific to the `textDocument/selectionRange` request.
    ///
    /// @since 3.15
    ///
    const selectionRange: ?base_c.BaseDynamicRegistration = null;
    ///
    /// Capabilities specific to the `textDocument/linkedEditingRange` request.
    ///
    /// @since 3.16
    ///
    const linkedEditingRange: ?base_c.BaseDynamicRegistration = null;
    ///
    /// Capabilities specific to the various call hierarchy requests.
    ///
    /// @since 3.16
    ///
    const callHierarchy: ?base_c.BaseDynamicRegistration = null;
    ///
    /// Capabilities specific to the `textDocument/semanticTokens` request.
    ///
    /// @since 3.16
    ///
    const semanticTokens: ?SemanticTokensClientCapabilities = null;
    ///
    /// Capabilities specific to the `textDocument/moniker` request.
    ///
    /// @since 3.16
    ///
    const moniker: ?base_c.BaseDynamicRegistration = null;
    ///
    /// Capabilities specific to the various type hierarchy requests.
    ///
    /// @since 3.17.0
    ///
    const typeHierarchy: ?base_c.BaseDynamicRegistration = null;
    ///
    /// Capabilities specific to the `textDocument/inlineValue` request.
    ///
    /// @since 3.17.0
    ///
    const inlineValue: ?base_c.BaseDynamicRegistration = null;
    ///
    /// Capabilities specific to the `textDocument/inlayHint` request.
    ///
    /// @since 3.17.0
    ///
    const inlayHint: ?InlayHintClientCapabilities = null;
    ///
    /// Capabilities specific to the diagnostic pull model.
    ///
    /// @since 3.17.0
    ///
    const diagnostic: ?DiagnosticClientCapabilities = null;
};
