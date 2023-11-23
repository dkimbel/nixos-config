# Personal macOS nix-darwin config

Originally built from [dustinlyons' excellent template](https://github.com/dustinlyons/nixos-config) (without secrets). I've removed components specific to NixOS, and deleted 'shared' components or relocated them to `darwin`.

At the time of writing, I'm running macOS Sonoma.

## Manual steps

While most of my system and application configuration on macOS is handled by nix-darwin and home-manager, some of it isn't. Setting up a new system involves the following manual steps:
- Configuring Karabiner to map capslock to escape when tapped and control when held, as described [here](https://gist.github.com/tanyuan/55bca522bf50363ae4573d4bdcf06e2e?permalink_comment_id=4271644#macos)
- Setting fish as my user's shell; `users.users.dk.shell = pkgs.fish;` was NOT effective, so I had to run `chsh -s /run/current-system/sw/bin/fish` from the terminal.
- I manually created an ssh key and set it up on GitHub by following [GitHub's instructions](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent). This involved using my Mac's builtin `ssh-add` instead of the `openssh` package; only the Mac builtin has support for easy keychain management of my ssh key's password.
- Configuring my laptop's display scaling/resolution in System Settings > Displays, to be one setting larger than the default. This doesn't appear to be possible to configure with any `com.apple` settings in the terminal, so I can't manage it with nix-darwin.
- I set up my Alfred preferences locally, including changing its main hotkey to command-space (and so disabling the default macOS setting that binds command-space to Spotlight).
- I gave various permissions to various applications via macOS prompts or in System Settings.

## Areas for improvement

Besides eliminating any/all of the 'manual steps' above, there are a few things I'd love to improve:
- Getting rid of a couple of notifications about 'sh' background processes, which always show up on boot. (The background processes themselves are valuable -- I'd like to keep them, just without notifications.)
- For some reason nix-darwin was frequently giving me errors about `/etc/bashrc` when I ran `/bin/build`, so I ended up adding a line to `/bin/build` that deletes `/etc/bashrc`. This is a hack, and requires `sudo` and therefore my password -- fairly inconvenient.
- I'd like to find a way to use the `openssh` package for a presumably more up-to-date and secure `ssh` command. Just, I want to do that without losing the convenience of the builtin macOS ssh agent that stores my ssh key's password in my keychain.
