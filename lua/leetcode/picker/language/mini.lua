local MiniPick = require("mini.pick")
local LanguagePickerUtil = require("leetcode.picker.language")

-- This function will be called by P.pick("language", question, cb, snippets)
return function(question, cb)
    local picker_items = LanguagePickerUtil.items(question.q.code_snippets)
    local final_items = {}

    for _, item in ipairs(picker_items) do
        table.insert(final_items, {
            text = LanguagePickerUtil.ordinal(item.value),
            value = item.value,
        })
    end

    MiniPick.start({
        source = {
            items = final_items,
            name = "Select a Programming Language",
            choose = function(item) -- item is the chosen one from picker_items
                vim.schedule(function()
                    LanguagePickerUtil.select(item.value.t, question, cb)
                end)
                return false -- Ensure picker doesn't close immediately by default
            end,
        },
        window = {
            prompt_prefix = "> ",
            config = function()
                local width = LanguagePickerUtil.width
                local height = LanguagePickerUtil.height
                local win_height = vim.o.lines
                local win_width = vim.o.columns

                local row = math.floor((win_height - height) / 2)
                local col = math.floor((win_width - width) / 2)

                return {
                    width = width,
                    height = height,
                    row = row,
                    col = col,
                    border = "rounded",
                }
            end,
        },
        options = {
            content_from_bottom = false,
            use_cache = true,
        },
    })
end
