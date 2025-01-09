if vim.g.loaded_tea_plugin then
	return
end

vim.g.loaded_tea_plugin = 1

require("lsp").setup({})
require("lsp").start()
