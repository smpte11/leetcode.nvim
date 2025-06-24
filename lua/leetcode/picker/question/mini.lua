local MiniPick = require("mini.pick")
local Picker = require("leetcode.picker")
local QuestionPickerUtil = require("leetcode.picker.question")

return function(questions, opts) -- opts might be passed from P.pick("question", ...)
    opts = opts or {}
    local final_items = {}

    -- Prepare items using the utility from leetcode.picker.question
    -- This returns tables like { entry = { ... }, value = question_data }
    local picker_items = QuestionPickerUtil.items(questions, opts.filter) -- 'questions' is used here

    for _, item in ipairs(picker_items) do
        table.insert(final_items, {
            text = QuestionPickerUtil.ordinal(item.value),
            value = item.value,
        })
    end

    MiniPick.start({
        source = {
            items = final_items,
            name = "Select a Question",
            choose = function(item)
                vim.schedule(function()
                    QuestionPickerUtil.select(item.value)
                end)
                return false
            end,
        },
        options = {
            content_from_bottom = false,
            use_cache = true, -- Let's enable cache, might be useful
        },
        window = {
            prompt_prefix = "> ",
            config = function(_source_name, _n_matches, _n_total, _n_marked)
                local width = QuestionPickerUtil.width
                local height = QuestionPickerUtil.height
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
    })
end
