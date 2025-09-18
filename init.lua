		-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Set leader keys
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"


local projectfile = vim.fn.getcwd() .. "/project.godot"
if vim.fn.filereadable(projectfile) == 1 then
	vim.fn.serverstart(vim.fn.stdpath("config") .. "/godothost")
end



-- Setup lazy.nvim with pluginsss








require("lazy").setup({
  spec = {
    -- Rose Pine theme
    {
      "rose-pine/neovim",
      name = "rose-pine",
      config = function()
        require("rose-pine").setup({
          styles = { italic = false } -- Disable italics
        })
        vim.cmd("colorscheme rose-pine")
      end
    },

    -- Telescope
    {
      "nvim-telescope/telescope.nvim",
      tag = "0.1.8", -- or branch = "0.1.x"
      dependencies = { "nvim-lua/plenary.nvim" },
      config = function()
        local telescope = require("telescope")
        telescope.setup({
          defaults = {
            mappings = {
              i = {
                ["<C-u>"] = false,
                ["<C-d>"] = false,
              },
            },
          },
        })
      end
    },

    -- Tree-sitter
    {
      "nvim-treesitter/nvim-treesitter",
      build = ":TSUpdate",
      config = function ()
        local configs = require("nvim-treesitter.configs")

        configs.setup({
          ensure_installed = { "gdscript", "godot_resource", "gdshader", "c", "cpp", "lua", "vim", "vimdoc", "query", "elixir", "heex", "javascript", "html" },
	  auto_install = true;
          highlight = { enable = true },
          indent = { enable = false },
        })
      end
    },
    {"habamax/vim-godot", event = "VimEnter"},

    -- Neo-tree
    {
      "nvim-neo-tree/neo-tree.nvim",
      branch = "v3.x",
      dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
        "MunifTanjim/nui.nvim",
        -- {"3rd/image.nvim", opts = {}}, -- Optional image support in preview window
      },
      config = function()
        require("neo-tree").setup({
          close_if_last_window = true, -- Close Neotree when it's the last window
          popup_border_style = "rounded",
          enable_git_status = true,
          enable_diagnostics = true,
          window = {
            mappings = {
              ["<CR>"] = function(state)
                local node = state.tree:get_node()
                if node.type == "file" then
                  require("neo-tree.sources.manager").close_all()
                  vim.cmd("tabnew " .. vim.fn.fnameescape(node.path))
                end
              end,
              ["t"] = function(state)
                local node = state.tree:get_node()
                if node.type == "file" then
                  require("neo-tree.sources.manager").close_all()
                  vim.cmd("tabnew " .. vim.fn.fnameescape(node.path))
                end
              end,
            },
          }
        })
      end
    },

    -- Lualine (correctly placed inside `spec`)
    {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("lualine").setup({
      options = {
        theme = "auto",
        icons_enabled = true,
        section_separators = { left = "", right = "" },
        component_separators = { left = "", right = "" },
      },
      sections = {
        lualine_c = {"filename"},  -- Keep showing the filename in the center
      lualine_x = {
  function()
    local fmt = vim.bo.fileformat
    local icons = { unix = "🌸", dos = "", mac = "" } -- Change as needed
    return icons[fmt] or fmt  -- No more surprise penguins
  end,
  function() return " " .. os.date("%H:%M:%S") end, -- Time stays as is
  "encoding", 
  "filetype"
}
},
    })
  end
},
	-- Mason
{
      "williamboman/mason.nvim",
      dependencies = {
        "williamboman/mason-lspconfig.nvim",
        "neovim/nvim-lspconfig",
      },
      config = function()
        require("mason").setup({
          ui = {
            border = "rounded"
          }
        })
        require("mason-lspconfig").setup({
          ensure_installed = { "lua_ls", "clangd",  "zls"}, -- Add LSPs you want
          automatic_installation = true,
        })

        -- Setup LSP servers
        local lspconfig = require("lspconfig")
        
        -- Setup capabilities for autocompletion
        local capabilities = require("cmp_nvim_lsp").default_capabilities()
        
        -- Setup GDScript LSP
        lspconfig.gdscript.setup({
          capabilities = capabilities,
        })

        -- Configure LSPs
        lspconfig.lua_ls.setup({
          capabilities = capabilities,
          settings = {
            Lua = {
              runtime = {
                version = 'LuaJIT'
              },
              workspace = {
                library = {
                  [vim.fn.expand("$VIMRUNTIME/lua")] = true,
                  [vim.fn.stdpath("config") .. "/lua"] = true,
                },
                userThirdParty = {os.getenv("HOME") .. "/.local/share/LuaAddons"},
                checkThirdParty = "Apply",
              },
              diagnostics = {
                globals = {'love'},
                disable = {'lowercase-global', 'trailing-space', 'empty-line'}
              },
              completion = {
                callSnippet = "Replace"
              }
            }
          }
        })
        lspconfig.clangd.setup({})
	lspconfig.zls.setup({
  cmd = { "/Users/markbabin/CODE/zls/zig-out/bin/zls" }, -- 👈 your custom ZLS path
})



        -- Keybindings for LSP actions
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, { noremap = true, silent = true })
        vim.keymap.set("n", "K", vim.lsp.buf.hover, { noremap = true, silent = true })
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { noremap = true, silent = true })
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { noremap = true, silent = true })



      end
    },
    {
  "hrsh7th/nvim-cmp",
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "L3MON4D3/LuaSnip",
    "saadparwaiz1/cmp_luasnip",
  },
  config = function()
    local cmp = require("cmp")
    local luasnip = require("luasnip")
    cmp.setup({
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      mapping = cmp.mapping.preset.insert({
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          else
            fallback()
          end
        end, { "i", "s" }),
      }),
      sources = {
        { name = "nvim_lsp" },  -- clangd will supply C++ completions
        { name = "luasnip" },
        { name = "buffer" },
        { name = "path" },
      },
      completion = {
        autocomplete = { require("cmp.types").cmp.TriggerEvent.TextChanged },
      },
    })
  end,
},
 	-- Autopairs
{
--  "windwp/nvim-autopairs",
 -- config = function()
  --  require("nvim-autopairs").setup()
--  end
},


       -- Smear Cursor 
    {
      "sphamba/smear-cursor.nvim",
      opts = {
        smear_between_buffers = true,
        smear_between_neighbor_lines = true,
        scroll_buffer_space = true,
        legacy_computing_symbols_support = false,
        smear_insert_mode = true,
        cursor_color = "#df9563",
      },
      config = function()
        require("smear_cursor").setup({
         smear_between_buffers = true,
         smear_between_neighbor_lines = true,
         scroll_buffer_space = true,
         legacy_computing_symbols_support = false,
         smear_insert_mode = true,
         cursor_color = "#df9563",
       })
      end
    },

    -- Dashboard
    {
  'nvimdev/dashboard-nvim',
  event = 'VimEnter',
  config = function()
  require('dashboard').setup {
  theme = 'hyper',
  config = {
    header = {
      " ███╗   ██╗██╗   ██╗██╗███╗   ███╗",
      " ████╗  ██║██║   ██║██║████╗ ████║",
      " ██╔██╗ ██║██║   ██║██║██╔████╔██║",
      " ██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║",
      " ██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║",
      " ╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝",
      "        Welcome to NeoVim!        ",
      "           Glod ne pita!          "-- Change this line
    },
  }
}

  end,
  dependencies = { {'nvim-tree/nvim-web-devicons'}}
},
{
	'akinsho/toggleterm.nvim',
	 version = "*",
	 opts = {
      open_mapping = [[<c-\>]],  -- Customize your key mappings here
      -- Add other configuration options as needed
    }

 },

  -- VeryLazy
    {
  "folke/noice.nvim",
  event = "VeryLazy",
  opts = {
    -- add any options here
  },
  dependencies = {
    -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
    "MunifTanjim/nui.nvim",
    -- OPTIONAL:
    --   `nvim-notify` is only needed, if you want to use the notification view.
    --   If not available, we use `mini` as the fallback
    "rcarriga/nvim-notify",
    }
},
  },

  install = { colorscheme = { "rose-pine" } },
  checker = { enabled = true }, -- Automatically check for updates
})

-- Keybindings for Telescope
vim.keymap.set("n", "<leader>ff", ":Telescope find_files<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>fg", ":Telescope live_grep<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>fb", ":Telescope buffers<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>fh", ":Telescope help_tags<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>n", ":Neotree filesystem reveal left<CR>", { noremap = true, silent = true })
					-- Open a new tab with <leader>t
vim.keymap.set("n", "<leader>t", ":tabnew<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<S-Left>", ":tabprevious<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<S-Right>", ":tabnext<CR>", { noremap = true, silent = true })

vim.keymap.set("n", "<leader>l", "<Cmd>ToggleTerm direction=float<CR>", { noremap = true, silent = true })




-- Clipboard fix (ensures system clipboard works)
vim.opt.clipboard = "unnamedplus"
vim.api.nvim_create_autocmd("BufEnter", {
  callback = function()
    vim.opt.number = true
  end,
})
vim.o.swapfile = false

vim.diagnostic.config({
    virtual_text = false,  -- Disables inline error messages
})
vim.o.signcolumn = "yes" -- Keep sign column visible, prevent UI shifts

vim.diagnostic.config({
    virtual_text = false,  -- No inline error messages
    signs = true,          -- Keep error/warning signs in the gutter
    underline = true,      -- Keep underlines for errors and warnings
    update_in_insert = false, -- Avoid real-time error messages while typing
})
vim.o.updatetime = 1000
-- Automatically show diagnostics in a floating window on CursorHold
vim.api.nvim_create_autocmd("CursorHold", {
    callback = function()
        vim.diagnostic.open_float(nil, {
            focusable = false,
            border = "rounded",
            source = "always",  -- Show where the error comes from (LSP, linter, etc.)
            prefix = " ",      -- Optional: Fancy warning icon
        })
    end,
})
-- ShaDa configuration to fix recent files and prevent tmp file issues
vim.opt.shada = "'1000,<50,s10,h,rA:,rB:,r/tmp/"
vim.opt.shadafile = vim.fn.stdpath("state") .. "/shada/main.shada"

-- Ensure ShaDa directory exists and has proper permissions
local shada_dir = vim.fn.stdpath("state") .. "/shada"
if vim.fn.isdirectory(shada_dir) == 0 then
    vim.fn.mkdir(shada_dir, "p", 0700)
end

-- Clean up any existing temporary files on startup
vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        local tmp_files = vim.fn.glob(shada_dir .. "/main.shada.tmp.*", true, true)
        for _, file in ipairs(tmp_files) do
            vim.fn.delete(file)
        end
    end,
})


 vim.cmd("highlight Normal guibg=#000000")

