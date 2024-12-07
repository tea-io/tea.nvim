if vim.g.loaded_tea_plugin then
  return
end

vim.g.loaded_tea_plugin = 1

local commands = require("commands")

commands.Setup()

