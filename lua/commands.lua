local function setup()
    local root_patterns = { ".git", ".clang-format", "pyproject.toml", "setup.py" }

    vim.api.nvim_create_user_command("TeaConnect", function()
        local server_address = vim.fn.input("Please enter the server address: ")
        local language_name = vim.fn.input("Please enter the language name: ")

        local root_dir = vim.fs.dirname(vim.fs.find(root_patterns, { upward = true })[1])

        local host, port = server_address:match("([^:]+):([^:]+)")
        local config = {
            host = host,
            port = port,
            name = "Tea " .. language_name .. " LSP Helper",
            root_dir = root_dir,
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
