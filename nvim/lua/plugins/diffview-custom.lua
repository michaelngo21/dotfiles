-- Inspired by https://github.com/richardgill/nix/blob/bdd30a0/modules/home-manager/dot-files/nvim/lua/plugins/git-diff_diffview.lua
return {
  "sindrets/diffview.nvim",
  event = "User AstroGitFile", -- Optional: Load when Git is detected (Astro specific)
  version = "*",
  config = function()
    -- 1. DEFINE WATCHER LOGIC INSIDE CONFIG
    local uv = vim.uv or vim.loop
    local debounce_timer = nil

    local debounce = function(fn, delay)
      return function(...)
        local args = { ... }
        if debounce_timer then
          debounce_timer:close()
        end
        debounce_timer = vim.defer_fn(function()
          debounce_timer = nil
          fn(unpack(args))
        end, delay)
      end
    end

    -- 2. SETUP WATCHER
    local function setup_watcher()
      local path = vim.fn.getcwd() -- Watch current working dir
      local fs_event = uv.new_fs_event()
      if not fs_event then
        return
      end

      local function update_view()
        -- Safely try to update diffview
        pcall(function()
          local lib = require("diffview.lib")
          local view = lib.get_current_view()
          if view then
            view:update_files()
          end
        end)
      end

      local on_change = debounce(function(err, filename, events)
        if err then
          return
        end
        -- Check if file is ignored by git
        local is_ignored = false
        if filename then
          local filepath = path .. "/" .. filename
          -- Simple git check
          local check = vim.fn.system("git check-ignore -q " .. vim.fn.shellescape(filepath))
          is_ignored = (vim.v.shell_error == 0)
        end

        -- Update if NOT ignored or if inside .git folder
        if (filename and filename:match("^%.git")) or not is_ignored then
          vim.schedule(update_view)
        end
      end, 100)

      fs_event:start(path, {}, on_change)
    end

    -- 3. START WATCHER
    setup_watcher()

    -- 4. AUTOCOMMANDS
    vim.api.nvim_create_autocmd("FocusGained", {
      callback = function()
        pcall(function()
          require("diffview.lib").get_current_view():update_files()
        end)
      end,
    })

    vim.api.nvim_create_autocmd("User", {
      pattern = "DiffviewViewLeave",
      callback = function()
        vim.cmd("DiffviewClose")
      end,
    })

    -- 5. RUN ACTUAL SETUP
    require("diffview").setup({
      default_args = { DiffviewOpen = { "--imply-local" } },
      keymaps = {
        view = { { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } } },
        file_panel = { { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } } },
        file_history_panel = { { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } } },
      },
    })
  end,
}
