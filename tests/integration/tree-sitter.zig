pub const TreeSitter = @cImport({
    @cInclude("tree_sitter/api.h");
});

pub extern "c" fn tree_sitter_python() *TreeSitter.TSLanguage;
