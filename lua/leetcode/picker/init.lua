local log = require("leetcode.logger")
local config = require("leetcode.config")

---@return "fzf" | "telescope" | "mini"
local function resolve_provider()
    ---@type string?
    local provider_name = config.user.picker.provider -- Allow nil

    if provider_name then
        -- Provider is specified
        local require_ok, _ = pcall(require, provider_name)
        if require_ok then
            if provider_name == "fzf-lua" then
                return "fzf"
            elseif provider_name == "mini.pick" then
                return "mini"
            -- Add other specific normalizations if needed
            else
                return provider_name -- e.g., "telescope"
            end
        else
            error(("specified picker provider not found: `%s`"):format(provider_name))
        end
    else
        -- No provider specified, try fallbacks
        local fzf_ok, _ = pcall(require, "fzf-lua")
        if fzf_ok then
            return "fzf"
        end

        local telescope_ok, _ = pcall(require, "telescope")
        if telescope_ok then
            return "telescope"
        end

        local mini_ok, _ = pcall(require, "mini.pick")
        if mini_ok then
            return "mini" -- Change "mini.pick" to "mini"
        end

        error("no supported picker provider found")
    end
end

---@class leet.Picker
local P = {}
P.provider = resolve_provider()

function P.hl_to_ansi(hl_group)
    local color = vim.api.nvim_get_hl(0, { name = hl_group })
    if color and color.fg then
        return string.format(
            "\x1b[38;2;%d;%d;%dm",
            bit.rshift(color.fg, 16),
            bit.band(bit.rshift(color.fg, 8), 0xFF),
            bit.band(color.fg, 0xFF)
        )
    end
    return ""
end

function P.apply_hl(text, hl_group)
    if not hl_group then
        return text
    end
    return P.hl_to_ansi(hl_group) .. text .. "\x1b[0m"
end

function P.normalize(items)
    return vim.tbl_map(function(item)
        return table.concat(
            vim.tbl_map(function(col)
                if type(col) == "table" then
                    return P.apply_hl(col[1], col[2])
                else
                    return col
                end
            end, item.entry),
            " "
        )
    end, items)
end

function P.pick(path, ...)
    local rpath = table.concat({ "leetcode.picker", path, P.provider }, ".")
    return require(rpath)(...)
end

function P.language(...)
    P.pick("language", ...)
end

function P.question(...)
    P.pick("question", ...)
end

function P.tabs()
    local utils = require("leetcode.utils")
    local tabs = utils.question_tabs()

    if vim.tbl_isempty(tabs) then
        return log.warn("No questions opened")
    end

    P.pick("tabs", tabs)
end

function P.hidden_field(text, deli)
    return text:match(("([^%s]+)$"):format(deli))
end

return P
