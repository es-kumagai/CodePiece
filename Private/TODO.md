# API Keys

To build the CodePiece, make `APIKeys.plist` file yourself in this folder and write Twitter's API key and GitHub's one. And the file have to include the CodePiece's application bundle.

## Property

Simple way, write API Keys and secrets into `APIKeys.plist` file, using following property keys. Each values type are `String`.

### Twitter

- `TwitterConsumerKey`
- `TwitterConsumerSecret`


### GitHub

- `GitHubClientID`
- `GitHubClientSecret`


## About Callback URL

You must register **callback url** to each API keys.
In the CodePiece, use defferent URL schemes between two build configuration. 

### In Debug

In Debug, CodePieces uses `jp.ez-net.scheme.codepiece-beta.authentication://twitter` for Twitter authentication, and `jp.ez-net.scheme.codepiece-beta.authentication://gist` for GitHub authentication.

### In Release

In Release, CodePieces uses `jp.ez-net.scheme.codepiece.authentication://gist` for Twitter authentication, and `jp.ez-net.scheme.codepiece.authentication://gist` for GitHub authentication