# How to build CodePiece

## Define keys and secrets

Add a `CodePieceClientInfo.swift` file to the CodePiece project. Then save the file with the following contents. Keys and secrets are replace your own.

```swift
// ID and Secret For GitHub Application.
struct CodePieceClientInfo : GitHubClientInfoType {

	let id = "********"
	let secret = "********"
}
```

## Install pods

Execute ```pod install``` in project root directory by Terminal.
