# How to build CodePiece

To build **CodePiece** ...

## Install a Support Tool

You need to install `XcodeGenerateConstants` tool in the next steps.

```bash
cd /tmp
git clone https://github.com/EZ-NET/XcodeGenerateConstants.git

cd XcodeGenerateConstants
sudo make install
```

By doing this, the `XcodeGenerateConstants` tool is installed to `/usr/local/bin` directory.

> This tool is used for generate Swift Files defined a struct type from Property List Files in `~/Library/XcodeGenerateConstants` directory.

## Define keys and secrets

### for GitHub Application

You need to create a file named `CodePieceClientInfo.plist` in `~/Library/XcodeGenerateConstants` directory.

The contents of the `CodePieceClientInfo.plist` file are as follows.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>id</key>
	<string></string>
	<key>secret</key>
	<string></string>
</dict>
</plist>
```

Value for `id` key is a *Client ID* of **GitHub** Application and value for `secret` key is a *Client Secret* of the *Client ID*.


## Install pods

To install some pods from **CocoaPods**, you need to execute ```pod install``` at **CodePiece** Project Root Directory.
