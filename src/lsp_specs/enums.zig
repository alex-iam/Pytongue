pub const MessageMethod = enum {
    initialize,
    initialized,
    shutdown,
    exit,
};
pub const TraceValue = enum {
    off,
    messages,
    verbose,
};
pub const ResourceOperationKind = enum {
    create,
    rename,
    delete,
};
pub const FailureHandlingKind = enum {
    abort,
    transactional,
    textOnlyTransactional,
    undo,
};

// TODO: default supported symbols are File and Array
pub const SymbolKind = enum { File, Module, Namespace, Package, Class, Method, Property, Field, Constructor, Enum, Interface, Function, Variable, Constant, String, Number, Boolean, Array, Object, Key, Null, EnumMember, Struct, Event, Operator, TypeParameter };

pub const MarkupKind = enum {
    plaintext,
    markdown,
};
pub const InsertTextMode = enum {
    asIs,
    adjustIndentation,
};
pub const CompletionItemKind = enum {
    Text,
    Method,
    Function,
    Constructor,
    Field,
    Variable,
    Class,
    Interface,
    Module,
    Property,
    Unit,
    Value,
    Enum,
    Keyword,
    Snippet,
    Color,
    File,
    Reference,
    Folder,
    EnumMember,
    Constant,
    Struct,
    Event,
    Operator,
    TypeParameter,
};
// TODO validation
pub const CodeActionKind = [_][]const u8{ "", "quickfix", "refactor", "refactor.extract", "refactor.inline", "refactor.rewrite", "source", "source.organizeImports", "source.fixAll" };

pub const DiagnosticTag = enum {
    ///
    /// Unused or unnecessary code.
    ///
    /// Clients are allowed to render diagnostics with this tag faded out
    /// instead of having an error squiggle.
    ///
    Unnecessary,
    ///
    /// Deprecated or obsolete code.
    ///
    /// Clients are allowed to rendered diagnostics with this tag strike through.
    ///
    Deprecated,
};
pub const FoldingRangeKind = enum {
    ///
    /// Folding range for a comment
    ///
    comment,
    ///
    /// Folding range for a imports or includes
    ///
    imports,
    ///
    /// Folding range for a region (e.g. `#region`)
    ///
    region,
};
