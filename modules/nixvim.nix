{ pkgs, config, inputs, ... }:
{
  home-manager.users.ml = {
    imports = [ inputs.nixvim.homeModules.default ];
    programs.nixvim = {
      enable = true;

      # Set leader key to space
      globals.mapleader = " ";

      # Color scheme
      colorschemes.catppuccin = {
        enable = true;
        settings = {
          flavour = "mocha"; # mocha, macchiato, frappe, latte
          transparent_background = false;
        };
      };

      # Core Neovim options
      opts = {
        # Line numbers
        number = true;
        relativenumber = true;

        # Tabs and indentation
        tabstop = 2;
        shiftwidth = 2;
        expandtab = true;
        autoindent = true;

        # Line wrapping
        wrap = true;

        # Search settings
        ignorecase = true;
        smartcase = true;
        hlsearch = true;
        incsearch = true;

        # Appearance
        termguicolors = true;
        signcolumn = "yes";
        cursorline = true;
        scrolloff = 8;

        # Behavior
        mouse = "a";
        clipboard = "unnamedplus";
        swapfile = false;
        backup = false;
        undofile = true;
        splitright = true;
        splitbelow = true;

        # Performance
        updatetime = 250;
        timeoutlen = 300;
      };

      # Plugin configuration
      plugins = {
        # Web devicons for file icons
        web-devicons.enable = true;

        # File tree
        neo-tree = {
          enable = true;
          settings = {
            close_if_last_window = true;
            window.width = 30;
          };
        };

        # Fuzzy finder
        telescope = {
          enable = true;
          keymaps = {
            "<leader>ff" = {
              action = "find_files";
              options.desc = "[F]ind [F]iles";
            };
            "<leader>fg" = {
              action = "live_grep";
              options.desc = "[F]ind by [G]rep";
            };
            "<leader>fb" = {
              action = "buffers";
              options.desc = "[F]ind [B]uffers";
            };
            "<leader>fh" = {
              action = "help_tags";
              options.desc = "[F]ind [H]elp";
            };
          };
        };

        # Syntax highlighting
        treesitter = {
          enable = true;
          settings = {
            highlight.enable = true;
            indent.enable = true;
          };
        };

        # Statusline
        lualine = {
          enable = true;
          settings = {
            options = {
              icons_enabled = true;
              theme = "catppuccin";
              component_separators = {
                left = "|";
                right = "|";
              };
              section_separators = {
                left = "";
                right = "";
              };
            };
          };
        };

        # LSP
        lsp = {
          enable = true;
          servers = {
            # Nix
            nixd.enable = true;

            clangd.enable = true;
            rust-analyzer.enable = true;
            ltex.enable = true;

            # Lua
            lua_ls.enable = true;

            # Python
            pyright.enable = true;

            # Add more language servers as needed
          };

          keymaps = {
            lspBuf = {
              "gd" = {
                action = "definition";
                desc = "[G]oto [D]efinition";
              };
              "gr" = {
                action = "references";
                desc = "[G]oto [R]eferences";
              };
              "gI" = {
                action = "implementation";
                desc = "[G]oto [I]mplementation";
              };
              "K" = {
                action = "hover";
                desc = "Hover Documentation";
              };
              "<leader>rn" = {
                action = "rename";
                desc = "[R]e[n]ame";
              };
              "<leader>ca" = {
                action = "code_action";
                desc = "[C]ode [A]ction";
              };
            };
          };
        };

        # Autocompletion
        cmp = {
          enable = true;
          autoEnableSources = true;
          settings = {
            mapping = {
              "<C-Space>" = "cmp.mapping.complete()";
              "<C-d>" = "cmp.mapping.scroll_docs(-4)";
              "<C-f>" = "cmp.mapping.scroll_docs(4)";
              "<C-e>" = "cmp.mapping.close()";
              "<CR>" = "cmp.mapping.confirm({ select = true })";
              "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
              "<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
            };
            sources = [
              { name = "nvim_lsp"; }
              { name = "path"; }
              { name = "buffer"; }
            ];
          };
        };

        # Git integration
        gitsigns = {
          enable = true;
          settings = {
            signs = {
              add.text = "+";
              change.text = "~";
              delete.text = "_";
              topdelete.text = "‾";
              changedelete.text = "~";
            };
          };
        };

        # Autopairs
        nvim-autopairs.enable = true;

        # Comment toggling
        comment.enable = true;

        # Indent guides
        indent-blankline = {
          enable = true;
          settings = {
            scope.enabled = true;
          };
        };

        # Which-key for keymap hints
        which-key = {
          enable = true;
          settings = {
            spec = [
              {
                __unkeyed-1 = "<leader>f";
                group = "Find";
              }
              {
                __unkeyed-1 = "<leader>c";
                group = "Code";
              }
              {
                __unkeyed-1 = "<leader>r";
                group = "Rename";
              }
            ];
          };
        };
      };

      # Keymaps
      keymaps = [
        # Better window navigation
        {
          mode = "n";
          key = "<C-h>";
          action = "<C-w>h";
          options.desc = "Move to left window";
        }
        {
          mode = "n";
          key = "<C-j>";
          action = "<C-w>j";
          options.desc = "Move to below window";
        }
        {
          mode = "n";
          key = "<C-k>";
          action = "<C-w>k";
          options.desc = "Move to above window";
        }
        {
          mode = "n";
          key = "<C-l>";
          action = "<C-w>l";
          options.desc = "Move to right window";
        }

        # File tree toggle
        {
          mode = "n";
          key = "<leader>e";
          action = "<cmd>Neotree toggle<CR>";
          options.desc = "Toggle file [E]xplorer";
        }

        # Clear search highlighting
        {
          mode = "n";
          key = "<Esc>";
          action = "<cmd>nohlsearch<CR>";
          options.desc = "Clear search highlight";
        }

        # Better indenting
        {
          mode = "v";
          key = "<";
          action = "<gv";
          options.desc = "Indent left";
        }
        {
          mode = "v";
          key = ">";
          action = ">gv";
          options.desc = "Indent right";
        }

        # Move lines up/down
        {
          mode = "n";
          key = "<A-j>";
          action = ":m .+1<CR>==";
          options.desc = "Move line down";
        }
        {
          mode = "n";
          key = "<A-k>";
          action = ":m .-2<CR>==";
          options.desc = "Move line up";
        }

        # Save file
        {
          mode = "n";
          key = "<leader>w";
          action = "<cmd>w<CR>";
          options.desc = "[W]rite file";
        }

        # Quit
        {
          mode = "n";
          key = "<leader>q";
          action = "<cmd>q<CR>";
          options.desc = "[Q]uit";
        }
      ];

      # Additional Lua configuration
      extraConfigLua = ''
        -- Additional custom configuration can go here
        vim.opt.fillchars = { eob = " " }

        -- Set completeopt for better completion experience
        vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }
      '';
    };
  };
}
