local function setup()
	local functions = require("functions")

	vim.api.nvim_create_user_command("TeaEnable", function()
		functions.enable()
	end, {})

	vim.api.nvim_create_user_command("TeaDisable", function()
		functions.disable()
	end, {})

	vim.api.nvim_create_user_command("Tea", function()
		functions.tea()
	end, {})

	vim.api.nvim_create_user_command("TeaConnect", function()
		functions.connect()
	end, {})
end

return {
	setup = setup,
}
