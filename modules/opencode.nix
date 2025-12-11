{ config, lib, pkgs, ... }:
let
  cfg = config.modules.dev;

  # Hexstrike installation script
  hexstrikeInstallScript = pkgs.writeShellScriptBin "hexstrike-install" ''
    set -e
    HEXSTRIKE_DIR="$HOME/.local/share/hexstrike-ai"
    
    if [ -d "$HEXSTRIKE_DIR" ]; then
      echo "Hexstrike already installed at $HEXSTRIKE_DIR"
      echo "Updating..."
      cd "$HEXSTRIKE_DIR"
      ${pkgs.git}/bin/git pull
    else
      echo "Cloning Hexstrike AI..."
      ${pkgs.git}/bin/git clone https://github.com/0x4m4/hexstrike-ai.git "$HEXSTRIKE_DIR"
      cd "$HEXSTRIKE_DIR"
    fi

    echo "Setting up Python virtual environment..."
    ${pkgs.python3}/bin/python3 -m venv "$HEXSTRIKE_DIR/venv"
    source "$HEXSTRIKE_DIR/venv/bin/activate"
    
    echo "Installing Python dependencies..."
    pip install -r requirements.txt
    
    echo ""
    echo "Hexstrike AI installed successfully!"
    echo "Start the server with: hexstrike-server"
  '';

  # Hexstrike server start script
  hexstrikeServerScript = pkgs.writeShellScriptBin "hexstrike-server" ''
    HEXSTRIKE_DIR="$HOME/.local/share/hexstrike-ai"
    
    if [ ! -d "$HEXSTRIKE_DIR" ]; then
      echo "Hexstrike not installed. Run 'hexstrike-install' first."
      exit 1
    fi
    
    cd "$HEXSTRIKE_DIR"
    source venv/bin/activate
    echo "Starting Hexstrike AI MCP Server on port 8888..."
    exec python3 hexstrike_server.py --port 8888 "$@"
  '';

  # Wrapper script that loads API key from file and runs perplexity-mcp
  perplexityMcpWrapper = pkgs.writeShellScriptBin "perplexity-mcp-wrapper" ''
    KEY_FILE="$HOME/.secrets/perplexity-api-key"
    if [ ! -f "$KEY_FILE" ]; then
      echo "Error: Perplexity API key not found at $KEY_FILE" >&2
      echo "Create the file with your API key: echo 'your-api-key' > $KEY_FILE" >&2
      exit 1
    fi
    export PERPLEXITY_API_KEY="$(cat "$KEY_FILE" | tr -d '\n')"
    exec ${pkgs.nodejs}/bin/npx -y perplexity-mcp "$@"
  '';

  # OpenCode MCP configuration - defined inside home-manager context
  mkOpencodeConfig = homeDir: {
    "$schema" = "https://opencode.ai/config.json";
    mcp = {
      # Chrome DevTools MCP - browser automation and debugging
      chrome-devtools = {
        type = "local";
        command = [ "npx" "-y" "chrome-devtools-mcp@latest" ];
        enabled = true;
      };

      # Context7 - Up-to-date documentation for LLMs
      context7 = {
        type = "remote";
        url = "https://mcp.context7.com/mcp";
        enabled = true;
      };

      # Perplexity MCP - AI-powered search and research
      perplexity = {
        type = "local";
        command = [ "perplexity-mcp-wrapper" ];
        enabled = true;
      };

      # Hexstrike AI - Cybersecurity automation MCP
      hexstrike = {
        type = "local";
        command = [ 
          "${homeDir}/.local/share/hexstrike-ai/venv/bin/python3"
          "${homeDir}/.local/share/hexstrike-ai/hexstrike_mcp.py"
          "--server"
          "http://localhost:8888"
        ];
        environment = {
          HEXSTRIKE_SERVER = "http://localhost:8888";
        };
        enabled = true;
      };
    };
  };

in
{
  config = lib.mkIf cfg.enable {
    # Add helper scripts for Hexstrike and Perplexity MCP
    environment.systemPackages = [
      hexstrikeInstallScript
      hexstrikeServerScript
      perplexityMcpWrapper
    ];

    home-manager.users.ml = { config, ... }: {
      # Generate OpenCode configuration file
      xdg.configFile."opencode/opencode.json".text = builtins.toJSON (mkOpencodeConfig config.home.homeDirectory);

      # Global system prompt / instructions for OpenCode
      xdg.configFile."opencode/AGENTS.md".text = ''
        # Global Instructions

        ## General Guidelines
        - Be concise and direct in responses
        - Prefer editing existing files over creating new ones
        - Always explain significant changes before making them

        ## Code Style
        - Follow existing project conventions
        - Use descriptive variable and function names
        - Add comments for complex logic
        ## MCP Servers 
        - Use Hexstrike when it comes to Pentesting/Cysec Stuff
        - Use Chrome Devtools when needing to look at Stuff you cant understand without a browser
        - Use Perplextiy for complex searches and reasoning, only if direly necessary
        - Use Context7 for documentation lookup when not sure of the usage of a software
      '';
    };
  };
}
