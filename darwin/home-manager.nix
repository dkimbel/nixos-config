{ config, pkgs, lib, ... }:

let
  name = "Daniel Kimbel";
  user = "dk";
  email = "dkkimbel@gmail.com";
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
    "obsidian"
  ];

  # Enable home-manager
  home-manager = {
    useGlobalPkgs = true;
    users.${user} = { pkgs, config, osConfig, lib, mkAlias, ... }:{
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
        dockutil
      ];
      home.stateVersion = "21.11";
      programs = {
        fish = {
          enable = true;
          # from https://github.com/LnL7/nix-darwin/issues/122#issuecomment-1659465635
          #  and https://github.com/LnL7/nix-darwin/issues/122#issuecomment-1666623924
          loginShellInit =
            let
              dquote = str: "\"" + str + "\"";
              makeBinPathList = map (path: path + "/bin");
            in ''
              fish_add_path --move --prepend --path ${lib.concatMapStringsSep " " dquote (makeBinPathList osConfig.environment.profiles)}
              set fish_user_paths $fish_user_paths
            '';
        };
        git = {
          enable = true;
          ignores = [ "*.swp" ];
          userName = name;
          userEmail = email;
          lfs = {
            enable = true;
          };
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
          settings = {
            theme = "gruvbox";
          };
        };
        kitty = {
          enable = true;
          font = {
            name = "SF Mono";
            size = 13.5;
          };
          settings = {
            adjust_line_height = "125%";
          };
          shellIntegration.enableFishIntegration = true;
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
    { path = "/Applications/Obsidian.app/"; }
    { path = "/Applications/Bitwarden.app/"; }
  ];
}