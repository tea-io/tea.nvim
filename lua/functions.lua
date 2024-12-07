local tea_enabled = 0
local tea_timer_id = nil

function Tea()
    if vim.bo.modified then
        vim.cmd("silent! write!")
    end
    local pos = vim.api.nvim_win_get_cursor(0)
    vim.cmd("silent! edit!")
    vim.api.nvim_win_set_cursor(0, pos)
end

function Enable()
    if tea_enabled == 1 then
        print("Tea plugin is already enabled!")
        return
    end

    tea_enabled = 1
    print("Tea plugin enabled!")
    tea_timer_id = vim.loop.new_timer()
    tea_timer_id:start(3000, 3000, vim.schedule_wrap(M.tea))
end

function Disable()
    if tea_enabled == 0 then
        print("Tea plugin is already disabled!")
        return
    end

    tea_enabled = 0
    print("Tea plugin disabled!")
    if tea_timer_id and not tea_timer_id:is_closing() then
        tea_timer_id:stop()
        tea_timer_id:close()
    end
    tea_timer_id = nil
end

return {
    Enable = Enable,
    Disable = Disable,
    Tea = Tea,
}
