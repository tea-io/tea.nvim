function Setup()
  local functions = require("functions")

  vim.api.nvim_create_user_command("TeaEnable", function()
    functions.Enable()
  end, {})

  vim.api.nvim_create_user_command("TeaDisable", function()
    functions.Disable()
  end, {})

  vim.api.nvim_create_user_command("Tea", function()
    functions.Tea()
  end, {})
end

return {
    Setup = Setup,
}
