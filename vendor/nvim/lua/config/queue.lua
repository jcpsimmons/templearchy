-- File-backed templearchy queue. Same files as host `nix run .#q` and guest `q`.
local M = {}

local function queue_dir()
  local env = os.getenv("TEMPLEARCHY_QUEUE")
  if env and vim.fn.isdirectory(env) == 1 then
    return env
  end
  if vim.fn.isdirectory("/mnt/host/queue") == 1 then
    return "/mnt/host/queue"
  end
  local share = vim.fn.expand("~/templearchy-share/queue")
  if vim.fn.isdirectory(share) == 1 then
    return share
  end
  local fallback = vim.fn.expand("~/.local/share/templearchy/queue")
  vim.fn.mkdir(fallback, "p")
  return fallback
end

local function files()
  local list = vim.fn.glob(queue_dir() .. "/*.txt", false, true)
  table.sort(list)
  return list
end

function M.list()
  local list = files()
  if #list == 0 then
    vim.notify("queue empty", vim.log.levels.INFO)
    return
  end
  for _, path in ipairs(list) do
    local body = table.concat(vim.fn.readfile(path), " ")
    print(vim.fn.fnamemodify(path, ":t:r") .. "  " .. body)
  end
end

function M.next()
  local list = files()
  if #list == 0 then
    vim.notify("queue empty", vim.log.levels.WARN)
    return
  end
  local path = list[1]
  vim.cmd("enew")
  vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.fn.readfile(path))
  vim.fn.delete(path)
  vim.notify("opened " .. vim.fn.fnamemodify(path, ":t:r"), vim.log.levels.INFO)
end

function M.add(text)
  if text == nil or text == "" then
    vim.notify("Qadd <text>", vim.log.levels.ERROR)
    return
  end
  local dir = queue_dir()
  vim.fn.mkdir(dir, "p")
  local list = files()
  local n = 1
  if #list > 0 then
    n = tonumber(vim.fn.fnamemodify(list[#list], ":t:r"), 10) + 1
  end
  local path = string.format("%s/%04d.txt", dir, n)
  vim.fn.writefile(vim.split(text, "\n", { plain = true }), path)
  vim.notify("queued " .. vim.fn.fnamemodify(path, ":t:r"), vim.log.levels.INFO)
end

vim.api.nvim_create_user_command("Qlist", M.list, {})
vim.api.nvim_create_user_command("Qnext", M.next, {})
vim.api.nvim_create_user_command("Qadd", function(opts)
  M.add(opts.args)
end, { nargs = "+" })

vim.keymap.set("n", "<leader>Qn", M.next, { desc = "Queue next prompt into a buffer" })
vim.keymap.set("n", "<leader>Ql", M.list, { desc = "List queued prompts" })

return M
