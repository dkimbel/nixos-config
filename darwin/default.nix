{ config, pkgs, lib, nixpkgs, ... }:

let user = "dk"; in

{
  imports = [
    ./home-manager.nix
    ./cachix
  ];

  nixpkgs = {
    config = {
      allowUnfree = true;
      allowBroken = true;
      allowInsecure = false;
      allowUnsupportedSystem = true;
    };
  };

  programs.fish.enable = true;
  environment = {
    shells = [ pkgs.fish ];
    systemPackages = with pkgs; [
      binutils  # provides objdump
      coreutils
      fd
      file
      fzf
      gnumake
      killall
      openssh
      ripgrep
      tree
      unzip
      wget
      zip
    ];
  };

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  services.karabiner-elements.enable = true;

  # Setup user, packages, programs
  nix = {
    package = pkgs.nixUnstable;
    # This shouldn't be strictly necessary, but it lets `nix-info -m` output my "nixpkgs" properly
    # and also makes it possible to use the nix-index package. Source;
    # https://github.com/nix-community/nix-index/issues/167#issuecomment-989849343
    nixPath = [ "nixpkgs=${nixpkgs}" ];
    settings.trusted-users = [ "@admin" "${user}" ];

    gc = {
      user = "root";
      automatic = true;
      interval = { Weekday = 0; Hour = 2; Minute = 0; };
      options = "--delete-older-than 30d";
    };

    # Turn this on to make command line easier
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  # Enable fonts dir
  fonts.fontDir.enable = true;

  networking = {
    computerName = "Higher Order";
    hostName = "higher-order";
  };

  system = {
    stateVersion = 4;
    # Turn off NIX_PATH warnings now that we're using flakes
    checks.verifyNixPath = false;

    # Source: https://medium.com/@zmre/nix-darwin-quick-tip-activate-your-preferences-f69942a93236
    # Lets new settings kick in without a reboot
    activationScripts.postUserActivation.text = ''
      /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
    '';

    defaults = {
      CustomUserPreferences = {
        "com.apple.TextEdit" = {
          NSAutomaticCapitalizationEnabled = false;
          NSAutomaticDashSubstitutionEnabled = false;
          NSAutomaticPeriodSubstitutionEnabled = false;
          NSAutomaticQuoteSubstitutionEnabled = false;
          NSAutomaticSpellingCorrectionEnabled = false;
          NSAutomaticTextCompletionEnabled = false;
          NSShowAppCentricOpenPanelInsteadOfUntitledFile = false;
          RichText = false;
        };
        "com.apple.WindowManager" = {
          EnableStandardClickToShowDesktop = 0;
        };
      };

      LaunchServices = {
        LSQuarantine = false;
      };

      NSGlobalDomain = {
        _HIHideMenuBar = true;

        AppleInterfaceStyle = "Dark";
        ApplePressAndHoldEnabled = false;
        AppleShowAllExtensions = true;

        # 120, 94, 68, 35, 25, 15
        InitialKeyRepeat = 15;

        # 120, 90, 60, 30, 12, 6, 2
        KeyRepeat = 2;

        "com.apple.mouse.tapBehavior" = 1;
        "com.apple.sound.beep.volume" = 0.0;
        "com.apple.sound.beep.feedback" = 0;
        "com.apple.trackpad.scaling" = 2.66;
      };

      dock = {
        autohide = true;
        show-recents = false;
        launchanim = true;
        mineffect = "scale";
        orientation = "bottom";
        tilesize = 64;
      };

      finder = {
        _FXShowPosixPathInTitle = false;
      };

      trackpad = {
        Clicking = true;
        TrackpadThreeFingerDrag = true;
      };
    };
  };
}
