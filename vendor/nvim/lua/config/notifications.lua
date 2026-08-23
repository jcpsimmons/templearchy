-- ============================================================================
-- NOTIFICATION CONFIGURATION
-- ============================================================================
-- Custom notification handling to silence specific warnings
-- Silence specific LSP position encoding warnings
local notify_original = vim.notify
vim.notify = function(msg, ...)
    if msg and
        (msg:match 'position_encoding param is required' or
            msg:match 'Defaulting to position encoding of the first client' or
            msg:match 'multiple different client offset_encodings' or msg:match 'jump_to_location is deprecated' or
            msg:match 'vim.lsp.util.jump_to_location is deprecated') then
        return
    end
    return notify_original(msg, ...)
end
