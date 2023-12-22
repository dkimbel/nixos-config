# Personal macOS nix-darwin config

Originally built from [dustinlyons' excellent template](https://github.com/dustinlyons/nixos-config) (without secrets). I've removed components specific to NixOS, and deleted 'shared' components or relocated them to `darwin`.

At the time of writing, I'm running macOS Sonoma.

## Manual steps

While most of my system and application configuration on macOS is handled by nix-darwin and home-manager, some of it isn't. Setting up a new system involves the following manual steps:
- Configuring Karabiner to map capslock to escape when tapped and control when held, as described [here](https://gist.github.com/tanyuan/55bca522bf50363ae4573d4bdcf06e2e?permalink_comment_id=4271644#macos).
- Setting fish as my user's shell; `users.users.dk.shell = pkgs.fish;` was NOT effective, so I had to run `chsh -s /run/current-system/sw/bin/fish` from the terminal.
- I manually created an ssh key and set it up on GitHub by following [GitHub's instructions](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent).
- Configuring TouchID for sudo, as described in [this blog post](https://sixcolors.com/post/2023/08/in-macos-sonoma-touch-id-for-sudo-can-survive-updates/). That means running `sudo cp /etc/pam.d/sudo_local.template /etc/pam.d/sudo_local`, then uncommenting the relevant line of your new `sudo_local` file.
- Configuring various macOS settings that I can't set directly through any form of `com.apple` setting, and so cannot easily manage with nix-darwin.
  - System Settings > Displays: update scaled resolution to be one larger than the default.
  - System Settings > Accessibility > Display > Redue motion: set to 'true' for a less annoying transition to/from full-screen apps.
  - System Settings > Displays > Automatically adjust brightness: set to 'false' so my screen doesn't automatically dim when the sun is behind me.
  - System Settings > Lock Screen > Turn display off on battery when inactive: set to 'For 3 minutes' (or longer?), so my screen doesn't dim too aggressively while I read.
- I set up my Alfred preferences manually, including changing its main hotkey to command-space (which also requires disabling the default macOS setting that binds command-space to Spotlight).
- I manually ran `touch ~/.hushlogin` to prevent new terminal windows from printing a message about my last login time.
- I manually configured Rectangle through its application UI, especially to start automatically on login.
- I gave various permissions to various applications via macOS prompts or in System Settings.
- I manually chose my wallpaper (no nix-darwin setting for this?), and may have manually configured a few other macOS settings.

## Areas for improvement

Besides eliminating any/all of the 'manual steps' above, there are a few things I'd love to improve:
- Getting rid of a couple of notifications about 'sh' background processes that always show up on boot. The background processes themselves are valuable -- I'd like to keep them, just without notifications.
- For some reason nix-darwin was frequently giving me errors about `/etc/bashrc` when I ran `/bin/build`, so I ended up adding a line to `/bin/build` that deletes `/etc/bashrc`. This is a hack, and requires `sudo`.
- On rare occasion, kitty's dock icon will be a '?' instead of its proper icon.
- On independent rare occasions, kitty will start up without displaying its usual prompt (and maybe not using fish at all?). This may only happen if I open it really quickly after my computer starts?
