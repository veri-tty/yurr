{ config, lib, pkgs, ... }:
let
  cfg = config.modules.dev;

in
{
  config = lib.mkIf cfg.enable {

    home-manager.users.ml = { config, lib, ... }: {
      # Generate OpenCode configuration file via activation script (to inject secrets)
      home.activation.generateOpencodeConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        CONFIG_DIR="$HOME/.config/opencode"
        CONFIG_FILE="$CONFIG_DIR/opencode.json"
        EXA_KEY_FILE="$HOME/.secrets/exa-api-key"
        
        mkdir -p "$CONFIG_DIR"
        
        # Read Exa API key if available
        if [ -f "$EXA_KEY_FILE" ]; then
          EXA_KEY="$(cat "$EXA_KEY_FILE" | tr -d '\n')"
        else
          EXA_KEY="YOUR_EXA_API_KEY"
          echo "Warning: Exa API key not found at $EXA_KEY_FILE" >&2
          echo "Create it with: echo 'your-api-key' > $EXA_KEY_FILE" >&2
        fi
        
        # Generate the config with the API key
        cat > "$CONFIG_FILE" << EOF
{
  "\$schema": "https://opencode.ai/config.json",
  "mcp": {
    "chrome-devtools": {
      "type": "local",
      "command": ["npx", "-y", "chrome-devtools-mcp@latest"],
      "enabled": true
    },
    "context7": {
      "type": "remote",
      "url": "https://mcp.context7.com/mcp",
      "enabled": true
    },
    "exa": {
      "type": "local",
      "command": ["npx", "-y", "exa-mcp-server"],
      "environment": {
        "EXA_API_KEY": "$EXA_KEY"
      },
      "enabled": true
    }
  }
}
EOF
      '';

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
        - Use Context7 for documentation lookup when not sure of the usage of a software
        - Use Exa for web search, code examples, and documentation lookup

        ## Pentesting Resources
        For pentesting assignments and cybersecurity knowledge, reference these sites:
        - https://www.hacktricks.wiki/ - Comprehensive pentesting methodology and techniques
        - https://book.hacktricks.wiki/ - HackTricks Book for in-depth guides
        - https://gtfobins.github.io/ - Unix binaries for privilege escalation
        - https://lolbas-project.github.io/ - Windows Living Off The Land binaries
        - https://www.revshells.com/ - Reverse shell generator
        - https://payloads.online/ - Payload generation resources
      '';
    };
  };
}
