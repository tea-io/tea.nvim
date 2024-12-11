local serial = require("serialization")
local tea_enabled = 0
local tea_timer_id = nil
local socket = vim.uv.new_tcp()

local function connect()
	socket:connect("127.0.0.1", 5212, function(err)
		if err then
			print("Connect error: " .. err)
			return
		end
	end)
end

local function tea()
	if socket:is_closing() then
		connect()
	end
	local current_file = vim.api.nvim_buf_get_name(0)
	local obj = { path = current_file }
	local json_obj = vim.json.encode(obj)
	local header = serial.header_serialize(#json_obj, 1, 67)
	socket:try_write(header)
	socket:try_write(json_obj)
	if vim.bo.modified then
		vim.cmd("silent! write!")
	end
	local pos = vim.api.nvim_win_get_cursor(0)
	vim.cmd("silent! edit!")
	vim.api.nvim_win_set_cursor(0, pos)
	socket:try_write(serial.header_serialize(#json_obj, 1, 68))
	socket:try_write(json_obj)
end

local function enable()
	if tea_enabled == 1 then
		print("Tea plugin is already enabled!")
		return
	end
	if socket:is_closing() then
		connect()
	end
	tea_enabled = 1
	tea()
	print("Tea plugin enabled!")
	tea_timer_id = vim.loop.new_timer()
	tea_timer_id:start(3000, 3000, vim.schedule_wrap(tea))
end

local function disable()
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
	enable = enable,
	disable = disable,
	tea = tea,
	connect = connect,
}
