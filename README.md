# new-mac

The 'new-mac.sh' script is designed to be run before Homebrew or XCode tools are installed. 
Just download the file, run it from anywhere and it should Just Work™ as long as your name is Evan Bunnage and you have access to all my repos 🙂 

It's also written to be run again and again safely* (*at your own risk).


## Post install

### Apps not in Homebrew 

- [Alttab](https://alt-tab-macos.netlify.app)
- [Tailscale](https://login.tailscale.com/admin/machines)
- [AlDente](https://apphousekitchen.com)
- [Signal](https://signal.org/download/macos/)
- [Zotero](https://www.zotero.org)
- [Blender](https://www.blender.org/download/)
- [Affinity](https://store.serif.com/en-us/update/universal-licence/)
- [HomeRow](https://www.homerow.app)

### System settings
1. Add the Colemak layout to OS keyboard, change caps lock modifier key
1. Change the spring-loading speed in Accessibility > Preferences > Mouse & Trackpad
1. Ensure Ethernet priority is above Wifi in system settings
1. Fix Spotlight search results:

<img src="docs/images/spotlight_settings.png" alt="Spotlight settings" width="400">

### nvim configs
1. Install Mason packages with `:Mason`
1. `cd ~/.local/share/nvim/lazy/friendly-snippets/ && gh pr checkout 507` to fix zls snippet (until 507 is merged)

### App configs
1. Configure BetterDisplay. With the Innocn 32 M2V you need to set the Color profile to 10 bit and
enable Configuration Protection
1. Setup HomeRow. Use super key + N, and super key + J for scroll. May need to switch based on
OS scroll direction

### Misc
1. Test `zig` command, will need to grant permissions in Security & Privacy
1. Download Zoom & co, set screen sharing permissions






