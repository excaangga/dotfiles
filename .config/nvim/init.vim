" Initialize vim-plug
call plug#begin(stdpath('config') . '/plugged')

" UI & Themes
Plug 'rebelot/kanagawa.nvim', {'as': 'kanagawa'}
Plug 'nvim-tree/nvim-web-devicons'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

" Navigation and Editing
Plug 'preservim/nerdcommenter'
Plug 'windwp/nvim-autopairs'
Plug 'theprimeagen/harpoon'
Plug 'nvim-telescope/telescope.nvim', {'tag': '0.1.8'}
Plug 'nvim-lua/plenary.nvim'
Plug 'petertriho/nvim-scrollbar'
Plug 'stevearc/oil.nvim'
Plug 'stevearc/aerial.nvim'
Plug 'echasnovski/mini.move'

" Git Integration
Plug 'lewis6991/gitsigns.nvim'
Plug 'tpope/vim-fugitive'

" LSP and Autocompletion
Plug 'neovim/nvim-lspconfig'
Plug 'williamboman/mason.nvim'
Plug 'williamboman/mason-lspconfig.nvim'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-nvim-lua'

" Code manipulation & sessions
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }
Plug 'folke/trouble.nvim'
Plug 'windwp/nvim-ts-autotag'
Plug 'shellRaining/hlchunk.nvim'

" Code teleportation
Plug 'tpope/vim-repeat'
Plug 'ggandor/leap.nvim'
Plug 'chrisgrieser/nvim-spider'

call plug#end()

" Plugin Configurations
lua << EOF
-- Mini.move setup
require('mini.move').setup()

-- Aerial function jumper
require("aerial").setup({
  on_attach = function(bufnr)
    -- Jump forwards/backwards with '{' and '}'
    vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr })
    vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr })
  end,
})
-- You probably also want to set a keymap to toggle aerial
vim.keymap.set("n", "<C-a>", "<cmd>AerialToggle!<CR>")

-- Oil (directory editor)
require('oil').setup()

-- Hlchunk Indentation
require('hlchunk').setup({ 
    chunk = {
        enable = true,
        use_treesitter = true,
    },
    line_num = {
        enable = true,
        use_treesitter = true,
    }
})

-- Leap
require('leap').create_default_mappings()

-- Autopairs
require('nvim-autopairs').setup {}

-- Autotag
require('nvim-ts-autotag').setup {}

-- Treesitter
require('nvim-treesitter.configs').setup {
  highlight = {
    enable = true,
  },
  indent = {
    enable = true
  },
}

-- Scrollbar
require('scrollbar').setup {}

-- Trouble (for diagnostics)
require('trouble').setup {}

-- Harpoon (for navigation)
require('harpoon').setup {}

-- Gitsigns
require('gitsigns').setup {}

-- LSP config
require('mason').setup()
require('mason-lspconfig').setup()

local lspconfig = require('lspconfig')
local mason_lspconfig = require('mason-lspconfig') -- Ensure the servers are installed and configured 
mason_lspconfig.setup_handlers({ 
    function(server_name) lspconfig[server_name].setup {} end,
})

-- Completion setup with nvim-cmp
local cmp = require('cmp')
cmp.setup({
  snippet = {
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'buffer' },
    { name = 'path' },
  })
})

-- Harpoon Settings
local harpoon = require("harpoon")

-- REQUIRED setup
harpoon.setup()

-- Key mappings for Harpoon
vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end)


vim.keymap.set("n", "<C-h>", function() harpoon:list():select(1) end)
vim.keymap.set("n", "<C-j>", function() harpoon:list():select(2) end)
vim.keymap.set("n", "<C-k>", function() harpoon:list():select(3) end)
vim.keymap.set("n", "<C-l>", function() harpoon:list():select(4) end)

-- Toggle previous & next buffers stored within Harpoon list
vim.keymap.set("n", "<C-S-J>", function() harpoon.nav.prev() end)
vim.keymap.set("n", "<C-S-K>", function() harpoon.nav.next() end)

-- Harpoon X Telescope
local harpoon = require('harpoon')
harpoon:setup({})

local conf = require("telescope.config").values

local function toggle_telescope(harpoon_files)
    local finder = function()
        local paths = {}
        for _, item in ipairs(harpoon_files.items) do
            table.insert(paths, item.value)
        end
        return require("telescope.finders").new_table({
            results = paths,
        })
    end

    require("telescope.pickers").new({}, {
        prompt_title = "Harpoon",
        finder = finder(),
        previewer = false,
        sorter = require("telescope.config").values.generic_sorter({}),
        layout_config = {
            height = 0.4,
            width = 0.5,
            prompt_position = "top",
            preview_cutoff = 120,
        },
        attach_mappings = function(prompt_bufnr, map)
            map("i", "<C-d>", function()
                local state = require("telescope.actions.state")
                local selected_entry = state.get_selected_entry()
                local current_picker = state.get_current_picker(prompt_bufnr)

                table.remove(harpoon_files.items, selected_entry.index)
                current_picker:refresh(finder())
            end)
            return true
        end,
    }):find()
end

vim.keymap.set("n", "<C-e>", function() toggle_telescope(harpoon:list()) end,
    { desc = "Open harpoon window" })

vim.keymap.set("n", "<space>fb", function()
    vim.cmd((vim.bo.filetype == 'oil') and 'bd' or 'Oil --float')
end)

-- Nvim Spider
vim.keymap.set(
	{ "n", "o", "x" },
	"w",
	"<cmd>lua require('spider').motion('w')<CR>",
	{ desc = "Spider-w" }
)
vim.keymap.set(
	{ "n", "o", "x" },
	"e",
	"<cmd>lua require('spider').motion('e')<CR>",
	{ desc = "Spider-e" }
)
vim.keymap.set(
	{ "n", "o", "x" },
	"b",
	"<cmd>lua require('spider').motion('b')<CR>",
	{ desc = "Spider-b" }
)

EOF

" General Vim Settings
set showmatch               " show matching
set ignorecase              " case insensitive
set mouse=v                 " middle-click paste with
set hlsearch                " highlight search
set incsearch               " incremental search
set tabstop=4               " number of columns occupied by a tab
set softtabstop=4           " see multiple spaces as tabstops so <BS> does the right thing
set expandtab               " converts tabs to white space
set shiftwidth=4            " width for autoindents
set autoindent              " indent a new line the same amount as the line just typed
set number                  " add line numbers
set relativenumber
set wildmode=longest,list   " get bash-like tab completions
filetype plugin indent on   " allow auto-indenting depending on file type
syntax on                   " syntax highlighting
set mouse=a                 " enable mouse click
set clipboard=unnamedplus   " use system clipboard
filetype plugin on
set cursorline              " highlight current cursorline
set ttyfast                 " Speed up scrolling in Vim
set scrolloff=999           " Center cursor to the middle of the screen
colorscheme kanagawa

" Telescope Keybindings
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>

" Fugitive Keybindings
nnoremap <leader>gc :Git mergetool<CR>
nnoremap <leader>gd :Gvdiffsplit!<CR>
nnoremap gdh :diffget //2<CR>
nnoremap gdl :diffget //3<CR>

" Clear the highlight after search is done
nnoremap <silent><expr> <space>l (&hls && v:hlsearch ? ':nohls' : ':set hls')."\n" <BAR> redraw<CR>

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved
set signcolumn=yes

" Trouble Keybinding
nnoremap <leader>xx <cmd>Trouble diagnostics toggle<cr>

" QoL Keybinding
inoremap jj <Esc>
inoremap <A-h> <C-o>h
inoremap <A-j> <C-o>j
inoremap <A-k> <C-o>k
inoremap <A-l> <C-o>l
