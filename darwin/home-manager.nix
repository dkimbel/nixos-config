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
  homebrew.casks = pkgs.callPackage ./casks.nix {};

  # Enable home-manager
  home-manager = {
    useGlobalPkgs = true;
    users.${user} = { pkgs, config, osConfig, lib, inputs, ... }:{
      imports = [
        ./modules/home-manager/alias-applications.nix
      ];
      home.enableNixpkgsReleaseCheck = false;
      home.packages = with pkgs; [
        dockutil
        karabiner-elements
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
              editor = "helix";
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
            size = 12;
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
