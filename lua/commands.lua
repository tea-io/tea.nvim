local function setup()
	vim.api.nvim_create_user_command("TeaConnect", function()
		local server_address = vim.fn.input("Please enter the server address: ")
		local language_name = vim.fn.input("Please enter the language name: ")

		local host, port = server_address:match("([^:]+):([^:]+)")
		local config = {
			host = host,
			port = port,
			name = "Tea " .. language_name .. " LSP Helper",
			filetypes = { language_name },
		}

		require("lsp").setup(config)
		require("lsp").start()

		print("\nConnection successfull!")
	end, {})
end

return {
	setup = setup,
}
