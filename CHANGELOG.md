# CodePiece

Change Logs.

## 1.2 (beta)

### Enhancements

* Add a hashtag of language with tweet.
* remove #CodePiece hashtag from tweet.

## 1.1 (beta)

### Enhancements

* Displays account status in main window.
* Authentication using OAuth2 with GitHub.
* Twitter account for using CodePiece can be selected now.

### Bug Fixes

* Fix a problem that CodePiece cannot be post a tweet if CodePiece isn't be used for a while.

## 1.0 Build 18

* Supports language selection.
* Selected language will save when app terminate and will restore at next launch.
* Hashtag will save when app terminate and will restore at next launch.
* Removed unnecessary completions in text fields.

### Enhancements

## 1.0 Build 17

### Enhancements

* Displays a message by progress HUD view during post processing and authenticating.
* Hashtag string is now trimmed with whitespace characters.
* When configuration is not completed in launch time, welcome window will show. 
* You can see your account using with authorization on screen.

### Bug Fixes

* Fixed a problem that your token is not saved to keychain data store.

## 1.0 Build 8

### Enhancements

* Now displaying a text count which will be post. This count includes ```Code```'s media and code url, ```Tweet & Description``` and ```Hashtag```.

### Bug Fixes

* Fixed a problem that failed to get a Gist capture with Non-Retina only and Retina/Non-Retina mixed environment.

## 1.0 Build 7

### Enhancements

* When post a tweet with a code, CodePiece will attach the captured code image to the tweet.

### Bug Fixes

* When you authenticate with GitHub account and a token already exists, CodePiece delete the token and try to create a new token.
* When you reset an authorization, CodePiece will only remove the authentication informatin in the app.
* You will not press the post button until the posting process is finished.
* Fixed a problem that no controls are displayed on main window.
