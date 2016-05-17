# How to build CodePiece

To build **CodePiece** project ...

## Define keys and secrets

To build the CodePiece project, you need to create `CodePieceClientInfo.plist` file to `~/Library/XcodeGenerateConstants` directory.

### How to make CodePieceClientInfo.plist

If you have not created it, you can do it easily to using `SetupCodePieceClientInfo.sh` script.

```sh
sh Tools/SetupCodePieceClientInfo.sh
```

When you execute the script, the script will install [EZ-NET/XcodeGenerateConstants](https://github.com/EZ-NET/XcodeGenerateConstants.git) tool to `/usr/local/bin` directory, and generate `CodePieceClientInfo.plist` in `~/Library/XcodeGenerateConstants` directory.

The contents of the `CodePieceClientInfo.plist` file are as follows.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>GitHubClientID</key>
	<string></string>
	<key>GitHubClientSecret</key>
	<string></string>
	<key>TwitterConsumerKey</key>
	<string></string>
	<key>TwitterConsumerSecret</key>
	<string></string>
</dict>
</plist>
```

#### Setup for GitHub

Create your Client ID and Client Secret for Github.

[https://github.com/settings/applications/new](https://github.com/settings/applications/new)

Value for `GitHubClientID ` key is a *Client ID* of **GitHub** Application and value for `GitHubClientSecret ` key is a *Client Secret* of the *Client ID*.

#### Setup for Twitter

Create your Consumer Key and Consumer Secret for Twitter.

[https://apps.twitter.com/app/new](https://apps.twitter.com/app/new)

Value for `TwitterConsumerKey ` key is a *Consumer Key* of **Twitter** Application and value for `TwitterConsumerSecret ` key is a *Consumer Secret* of the *Client ID*.

## Install pods

To install some pods from **CocoaPods**, you need to execute ```pod install``` at **CodePiece** Project Root Directory.
