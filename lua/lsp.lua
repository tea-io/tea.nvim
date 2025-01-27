local common = require("functions")

local M = {}

function M.setup(opts)
    local config = {
        host = opts.host or "0.0.0.0",
        port = opts.port or 5211,
        name = opts.name or "Tea LSP Extension",
        root_dir = opts.root_dir or vim.fn.getcwd(),
        filetypes = opts.filetypes or { "cpp" },
    }

    vim.notify("Tea LSP server is starting..." .. vim.inspect(config), vim.log.levels.INFO)

    local uv = vim.loop
    local client = uv.new_tcp()
    client:connect(config.host, config.port, function(err)
        if err then
            print("Error connecting to Tea LSP server: " .. err)
            return
        end
        print("Connected to Tea LSP server")
    end)

    local stopped = false
    local id = 1
    local rpc_client = {
        is_closing = function()
            return stopped
        end,
        terminate = function()
            stopped = true
        end,
        notify = function(method, params)
            if stopped then
                return
            end
            local msg = vim.fn.json_encode({
                jsonrpc = "2.0",
                method = method,
                params = params,
            })
            local wrapped_msg = common.wrap_with_header(msg, config.filetypes[1])
            client:write(wrapped_msg)
        end,
        request = function(method, params, callback)
            if stopped then
                return
            end
            local msg = vim.fn.json_encode({
                jsonrpc = "2.0",
                id = id,
                method = method,
                params = params,
            })
            id = id + 1

            local wrapped_msg = common.wrap_with_header(msg, config.filetypes[1])
            client:write(wrapped_msg)

            client:read_start(common.read_with_header(function(resp_body)
                vim.schedule(function()
                    local decoded_json = ""
                    if pcall(function() decoded_json = vim.fn.json_decode(resp_body) end) then
                        vim.inspect(resp_body)
                    end

                    if decoded_json["error"] then
                        callback(decoded_json["error"], nil)
                        return
                    end
                    if decoded_json["result"] then
                        callback(nil, decoded_json["result"])
                        return
                    end
                end)
            end))
        end,
    }

    function M.start()
        local function cmd(_)
            return rpc_client
        end

        vim.lsp.start({
            name = config.name,
            cmd = cmd,
            filetypes = config.filetypes,
            root_dir = config.root_dir,
        })
    end
end

return M
