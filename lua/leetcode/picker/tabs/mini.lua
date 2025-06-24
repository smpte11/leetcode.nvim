local MiniPick = require("mini.pick")
local Picker = require("leetcode.picker") -- For Picker.normalize
local TabsPickerUtil = require("leetcode.picker.tabs")
local log = require("leetcode.logger")

-- This function will be called by P.pick("tabs", tabs_data)
return function(tabs_data)
    local item_reflect = {}
    local final_items = {}
    local picker_items = TabsPickerUtil.items(tabs_data)

    for _, item in ipairs(picker_items) do
        item_reflect[item.value.question.q.frontend_id] = item.value
        table.insert(final_items, {
            text = TabsPickerUtil.ordinal(item.value.question.q),
            id = item.value.question.q.frontend_id,
        })
    end

    MiniPick.start({
        source = {
            items = final_items,
            name = "Select a Tab",
            choose = function(item) -- item is the chosen one from picker_items
                vim.schedule(function()
                    TabsPickerUtil.select(item_reflect[item.id])
                end)
                return false -- Ensure picker doesn't close immediately by default
            end,
        },
        options = {
            content_from_bottom = false,
        },
        window = {
            prompt_prefix = "> ",
            config = function()
                local width = TabsPickerUtil.width
                local height = TabsPickerUtil.height
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
