local M = {}
local bit = require("bit")
local ffi = require("ffi")

local id = 0

local language_name_to_id = {
	c = 10,
	cpp = 11,
	latex = 300,
}

local function bytes_to_int(b1, b2, b3, b4)
	return bit.bor(bit.lshift(b4, 24), bit.lshift(b3, 16), bit.lshift(b2, 8), b1)
end

local function parse_header(header)
	local b5, b6, b7, b8 = header:byte(0, 4)
	return bytes_to_int(b8, b7, b6, b5)
end

function M.wrap_with_header(msg, language_name)
	local msg_len = #msg
	local language_id = language_name_to_id[language_name]

	-- Allocate buffer for header (12 bytes) + message
	local buf = ffi.new("uint8_t[?]", 12 + msg_len)

	-- Write size (4 bytes)
	buf[0] = bit.rshift(bit.band(msg_len, 0xFF000000), 24)
	buf[1] = bit.rshift(bit.band(msg_len, 0x00FF0000), 16)
	buf[2] = bit.rshift(bit.band(msg_len, 0x0000FF00), 8)
	buf[3] = bit.band(msg_len, 0x000000FF)

	-- Write ID (4 bytes)
	buf[4] = bit.rshift(bit.band(id, 0xFF000000), 24)
	buf[5] = bit.rshift(bit.band(id, 0x00FF0000), 16)
	buf[6] = bit.rshift(bit.band(id, 0x0000FF00), 8)
	buf[7] = bit.band(id, 0x000000FF)

	-- Write language ID (4 bytes)
	buf[8] = bit.rshift(bit.band(language_id, 0xFF000000), 24)
	buf[9] = bit.rshift(bit.band(language_id, 0x00FF0000), 16)
	buf[10] = bit.rshift(bit.band(language_id, 0x0000FF00), 8)
	buf[11] = bit.band(language_id, 0x000000FF)

	-- Copy message
	ffi.copy(buf + 12, msg, msg_len)

	id = id + 1
	return ffi.string(buf, 12 + msg_len)
end

function M.read_with_header(callback)
	local buffer = ""
	local expected_size = nil

	local function process_buffer()
		if expected_size == nil and #buffer >= 12 then
			local header = buffer:sub(1, 12)
			expected_size = parse_header(header)
			buffer = buffer:sub(13)
		end

		if expected_size and #buffer >= expected_size then
			local payload = buffer:sub(1, expected_size)
			buffer = buffer:sub(expected_size + 1)
			expected_size = nil
			callback(payload)
			process_buffer()
		end
	end

	return function(err, chunk)
		if err then
			vim.notify("Error reading from socket: " .. vim.inspect(err), vim.log.levels.ERROR)
			return
		end
		if chunk then
			buffer = buffer .. chunk
			process_buffer()
		end
	end
end

function M.find_fuse_tea_fs()
	local handle = io.popen("findmnt -l -n -o TARGET --types fuse.tea-fs")
	if not handle then
		print("findmnt error")
		return nil
	end

	local target = handle:read("*l")

	if target then
		return target
	end
	handle:close()

	print("tea-fs mount not found")
	return nil
end

return M
