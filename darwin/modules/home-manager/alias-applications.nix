# Source: https://github.com/nix-community/home-manager/issues/1341#issuecomment-1716147796

{ config, lib, pkgs, ...}:

let mk-alias = inputs.mkAlias.packages.${builtins.currentSystem}.default;
in
{
  home.activation.aliasApplications = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin (
    let
      apps = pkgs.buildEnv {
        name = "home-manager-applications";
        paths = config.home.packages;
        pathsToLink = "/Applications";
      };
      lastAppsFile = "${config.xdg.stateHome}/nix/.apps";
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
}
