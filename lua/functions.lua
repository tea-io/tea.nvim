local M = {}

local id = 0

local function bytes_to_int(b1, b2, b3, b4)
    return bit.bor(bit.lshift(b4, 24), bit.lshift(b3, 16), bit.lshift(b2, 8), b1)
end

local function parse_header(header)
    local b5, b6, b7, b8 = header:byte(0, 4)
    return bytes_to_int(b8, b7, b6, b5)
end

function M.wrap_with_header(msg)
    -- Convert string to bytes
    local payload = {}
    for i = 1, #msg do
        payload[i] = string.byte(msg, i)
    end

    -- Create header (12 bytes)
    local header = {
        -- Size (4 bytes)
        bit.rshift(bit.band(#payload, 0xFF000000), 24),
        bit.rshift(bit.band(#payload, 0x00FF0000), 16),
        bit.rshift(bit.band(#payload, 0x0000FF00), 8),
        bit.band(#payload, 0x000000FF),

        -- ID (4 bytes)
        bit.rshift(bit.band(id, 0xFF000000), 24),
        bit.rshift(bit.band(id, 0x00FF0000), 16),
        bit.rshift(bit.band(id, 0x0000FF00), 8),
        bit.band(id, 0x000000FF),

        -- Type (4 bytes)
        0,
        0,
        0,
        0,
    }
    id = id + 1

    -- Concatenate header and payload
    for i = 1, #payload do
        header[12 + i] = payload[i]
    end

    return string.char(unpack(header))
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

return M
