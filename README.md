# yubikeylock

This project tries to detect if a Yubikey is connected to the current machine
every couple of seconds and locks the screen if it was unplugged.

To use this, place the binary somewhere (e.g. `~/.local/bin`) and create a new
LaunchAgent with the following content:

```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC -//Apple Computer//DTD PLIST 1.0//EN http://www.apple.com/DTDs/PropertyList-1.0.dtd >
<plist version="1.0">
  <dict>
    <key>Label</key>
    <string>com.github.zerok.yubikeylock</string>
    <key>ProgramArguments</key>
    <array>
        <string>/Users/zerok/.local/bin/yubikeylock</string>
    </array>
    <key>KeepAlive</key>
    <true />
  </dict>
</plist>
```

Let's store the file as
`~/Library/LaunchAgents/com.github.zerok.yubikeylock.plist` and load it:

```
$ launchctl load -w ~/Library/LaunchAgents/com.github.zerok.yubikeylock.plist
```

## Development

You can either do your development inside XCode or using pretty much anything
else and build the project using the `swift` command-line tool:

```
$ swift build
Compile Swift Module 'yubikeylock' (1 sources)
Linking ./.build/x86_64-apple-macosx10.10/debug/yubikeylock
```
