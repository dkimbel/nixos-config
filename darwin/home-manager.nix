{ pkgs, mkAlias, ... }:

let
  name = "Daniel Kimbel";
  user = "dk";
  email = "dk@danielkimbel.com";
in
{
  imports = [
    ./dock
  ];

  users.users.${user} = {
    name = "${user}";
    home = "/Users/${user}";
    isHidden = false;
    # this had no effect; instead manually ran:
    #   chsh -s /run/current-system/sw/bin/fish
    # shell = pkgs.fish;
  };

  homebrew.enable = true;
  homebrew.casks = [
    "alfred"
    "appcleaner"
    "bitwarden"
    "firefox"
    "font-sf-mono"
    "font-symbols-only-nerd-font"
    "obsidian"
  ];

  # Enable home-manager
  home-manager = {
    useGlobalPkgs = true;
    users.${user} = { pkgs, config, osConfig, lib, ... }:{
      # Source: https://github.com/nix-community/home-manager/issues/1341#issuecomment-1716147796
      home.activation.aliasApplications = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin (
        let
          apps = pkgs.buildEnv {
            name = "home-manager-applications";
            paths = config.home.packages;
            pathsToLink = "/Applications";
          };
          lastAppsFile = "${config.xdg.stateHome}/nix/.apps";
          mk-alias = mkAlias.packages.aarch64-darwin.default;
        in
          lib.hm.dag.entryAfter ["writeBoundary"] ''
            last_apps=$(cat "${lastAppsFile}" 2>/dev/null || echo "")
            next_apps=$(readlink -f ${apps}/Applications/* | sort)
    
            if [ "$last_apps" != "$next_apps" ]; then
              echo "Apps have changed. Updating macOS aliases..."
    
              apps_path="$HOME/Applications/NixApps"
              mkdir -p "$apps_path"
    
              ${pkgs.fd}/bin/fd \
                -t l -d 1 . ${apps}/Applications \
                -x "${mk-alias}/bin/mkalias" \
                -L {} "$apps_path/{/}"
    
              echo "$next_apps" > "${lastAppsFile}"
            fi
          ''
      );
      home.enableNixpkgsReleaseCheck = false;
      home.packages = with pkgs; [
        clang-tools_17 # includes C language server
        discord
        dockutil
        hyperfine
        lldb_17
        llvmPackages_17.clang-manpages
        llvmPackages_17.libcxxClang
        llvmPackages_17.lldb-manpages
        marksman # markdown language server
        nil # nix language server
        python311
        python311Packages.python-lsp-server
        rectangle
        rust-analyzer
        rust-bin.stable.latest.default
        taplo # toml language server
        zig
        zls # zig language server
      ];
      home.stateVersion = "21.11";
      programs = {
        fish = {
          enable = true;
          loginShellInit =
            let
              dquote = str: "\"" + str + "\"";
              makeBinPathList = map (path: path + "/bin");
            in ''
              # From https://github.com/LnL7/nix-darwin/issues/122#issuecomment-1659465635
              #  and https://github.com/LnL7/nix-darwin/issues/122#issuecomment-1666623924
              fish_add_path --move --prepend --path ${lib.concatMapStringsSep " " dquote (makeBinPathList osConfig.environment.profiles)}
              set fish_user_paths $fish_user_paths

              set fish_greeting

              # This lets me use Apple's builtin ssh agent to store my ssh key's password, while separately
              # having the openssh package give me a more up-to-date `ssh` command. Original source of the idea:
              # https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent
              command /usr/bin/ssh-add --apple-use-keychain ~/.ssh/id_ed25519 > /dev/null 2>&1

              abbr --add cl cc -Wall -Wextra -Werror -std=gnu17 -pedantic

              function add_newline_before_all_prompts_except_first --on-event fish_prompt
                # we don't even check the value; if this variable exists, its value is effectively 'true'
                if set -q already_prompted_this_session
                  echo
                else
                  set -g already_prompted_this_session "true"
                end
              end

              # Alias for helix that first strips kitty's padding, then adds it back after helix closes
              # Source/inspiration: https://www.reddit.com/r/vim/comments/ofe72k/comment/h4cptfq
              function hx
                # only issue commands to Kitty if we're actually running from within a Kitty terminal
                if test -n "$KITTY_WINDOW_ID"
                  kitty @ set-spacing padding=0
                end
                "${pkgs.helix}/bin/hx" $argv
                if test -n "$KITTY_WINDOW_ID"
                  kitty @ set-spacing padding=default
                end
              end
            '';
          plugins = [
            { name = "autopair"; src = pkgs.fishPlugins.autopair.src; }
            { name = "plugin-git"; src = pkgs.fishPlugins.plugin-git.src; }
            { name = "z"; src = pkgs.fishPlugins.z.src; }
          ];
        };

        git = {
          enable = true;
          ignores = [ "*.swp" ];
          userName = name;
          userEmail = email;
          extraConfig = {
            init.defaultBranch = "main";
            core = { 
              editor = "hx";
              autocrlf = "input";
            };
          };
        };

        helix = {
          defaultEditor = true;
          enable = true;
          settings = pkgs.lib.importTOML ../config/helix/config.toml;
          languages = pkgs.lib.importTOML ../config/helix/languages.toml;
          themes = {
            material_deep_ocean_patched = {
              "inherits" = "material_deep_ocean";
              # use brighter colors for comments and for selection, to improve contrast/visibility
              "comment" = "gray";
              "ui.selection" = { "bg" = "#2a2e46"; };
            };
            kanagawa_patched = {
              "inherits" = "kanagawa";
              "comment" = "#7a7870";
            };
          };
        };

        kitty = {
          enable = true;
          extraConfig = ''
            # Source of font patches:
            # https://www.reddit.com/r/neovim/comments/vmizpo/comment/ie208xn
            # https://github.com/kyza-2k/.dotfiles/blob/master/.config/kitty/symbols.conf
            # "Nerd Fonts - Pomicons"
            symbol_map  U+E000-U+E00D Symbols Nerd Font
            # "Nerd Fonts - Powerline"
            symbol_map U+e0a0-U+e0a2,U+e0b0-U+e0b3 Symbols Nerd Font
            # "Nerd Fonts - Powerline Extra"
            symbol_map U+e0a3-U+e0a3,U+e0b4-U+e0c8,U+e0cc-U+e0d2,U+e0d4-U+e0d4 Symbols Nerd Font
            # "Nerd Fonts - Symbols original"
            symbol_map U+e5fa-U+e62b Symbols Nerd Font
            # "Nerd Fonts - Devicons"
            symbol_map U+e700-U+e7c5 Symbols Nerd Font
            # "Nerd Fonts - Font awesome"
            symbol_map U+f000-U+f2e0 Symbols Nerd Font
            # "Nerd Fonts - Font awesome extension"
            symbol_map U+e200-U+e2a9 Symbols Nerd Font
            # "Nerd Fonts - Octicons"
            symbol_map U+f400-U+f4a8,U+2665-U+2665,U+26A1-U+26A1,U+f27c-U+f27c Symbols Nerd Font
            symbol_map U+f44a Symbols Nerd Font
            # "Nerd Fonts - Font Linux"
            symbol_map U+F300-U+F313 Symbols Nerd Font
            #  Nerd Fonts - Font Power Symbols"
            symbol_map U+23fb-U+23fe,U+2b58-U+2b58 Symbols Nerd Font
            #  "Nerd Fonts - Material Design Icons"
            symbol_map U+f500-U+fd46 Symbols Nerd Font
            # "Nerd Fonts - Weather Icons"
            symbol_map U+e300-U+e3eb Symbols Nerd Font
            # Misc Code Point Fixes
            symbol_map U+21B5,U+25B8,U+2605,U+2630,U+2632,U+2714,U+E0A3,U+E615,U+E62B Symbols Nerd Font
          '';
          font = {
            name = "SF Mono";
            size = 13.5;
          };
          keybindings = {
            "cmd+t" = "new_tab_with_cwd";
            "cmd+1" = "goto_tab 1";
            "cmd+2" = "goto_tab 2";
            "cmd+3" = "goto_tab 3";
            "cmd+4" = "goto_tab 4";
            "cmd+5" = "goto_tab 5";
            "cmd+6" = "goto_tab 6";
            "cmd+7" = "goto_tab 7";
            "cmd+8" = "goto_tab 8";
            "cmd+9" = "goto_tab 9";
            "cmd+shift+right" = "move_tab_forward";
            "cmd+shift+left" = "move_tab_backward";
          };
          settings = {
            adjust_line_height = "125%";
            allow_remote_control = "true";
            confirm_os_window_close = 0;
            macos_option_as_alt = "yes";
            tab_bar_style = "powerline";
            tab_powerline_style = "slanted";
            window_padding_width = "14 20 20";
          };
          shellIntegration.enableFishIntegration = true;
          theme = "Kaolin Aurora";
        };

        starship = {
          enable = true;
          enableFishIntegration = true;
          settings = pkgs.lib.importTOML ../config/starship.toml;
        };

        ssh = {
          enable = true;
          extraConfig = ''
            Host github.com
              AddKeysToAgent yes
              IdentityFile ~/.ssh/id_ed25519
          '';
        };
      };
    };
  };

  # Fully declarative dock using the latest from Nix Store
  local.dock.enable = true;
  local.dock.entries = [
    { path = "/System/Applications/Music.app/"; }
    { path = "/Applications/Firefox.app/"; }
    { path = "${pkgs.kitty}/Applications/kitty.app/"; }
    { path = "${pkgs.discord}/Applications/Discord.app/"; }
    { path = "/Applications/Obsidian.app/"; }
    { path = "/Applications/Bitwarden.app/"; }
  ];
}
