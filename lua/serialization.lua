local function header_serialize(size, id, type)
	local function to_big_endian(value)
		return string.char(
			math.floor(value / 2 ^ 24) % 256,
			math.floor(value / 2 ^ 16) % 256,
			math.floor(value / 2 ^ 8) % 256,
			value % 256
		)
	end

	local buf = to_big_endian(size) .. to_big_endian(id) .. to_big_endian(type)
	return buf
end

local function deserialize(buffer)
	local function from_big_endian(byte1, byte2, byte3, byte4)
		return (byte1 * 2 ^ 24) + (byte2 * 2 ^ 16) + (byte3 * 2 ^ 8) + byte4
	end

	local size = from_big_endian(buffer:byte(1), buffer:byte(2), buffer:byte(3), buffer:byte(4))
	local id = from_big_endian(buffer:byte(5), buffer:byte(6), buffer:byte(7), buffer:byte(8))
	local type = from_big_endian(buffer:byte(9), buffer:byte(10), buffer:byte(11), buffer:byte(12))

	return size, id, type
end

return {
	header_serialize = header_serialize,
	header_deserialize = deserialize,
}
