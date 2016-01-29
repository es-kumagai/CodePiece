# CodePiece

Change Logs.

## 1.4.6 (*)

### Enhancements

* Can chain tweet (reply to myself without @screenname) easily.

## 1.4.5

### Enhancements

* Can now open selecting tweet using browser.

## 1.4.4

### Enhancements

* CodePiece can now replying to other tweets.
* Supports OAuth authentication by Twitter.
* Change shortcut key for `Reload Timeline` to `option+command+R`.
* Assign shortcut key for `Reply To Selection` to `command+R`.
* Prohibit post which only twitter account ntext without a code.

### Fixes

* Fix layout for showing an error message in Twitter Preferences window.

### Beta Only

* Change Product Bundle Identifier for Beta app.

## 1.4.3

### Fixes

* Fixed a problem that failed to get twitter status when 'profile_image_url' or 'profile_image_url_https' is set to null.
* Fixed a problem that failed to receive response when returns unknown language from Gists API.

## 1.4.2

### Enhancements

* CodePiece now support multiple hashtags.

### Fixes

* Tweet & Description count is displayed more accurately.
* CodePiece update Text & Description count when Language popup menu is changed.

## 1.4.1

### Enhancements

* Add `Clear Code And Description` menu item in `Editor` menu.
* Timeline Controller always report using Timeline status field when errors are occurred.
* When twitter credentials verifying, other verification process will not run.

### Bug Fixes

* Cells which posted 24 hours ago is filled by gray background color.

## 1.4

### Enhancements

* CodePiece can now display tweets with current hashtag.
* Add 'Browser' menu includes menu items for open page with default browser.
* Add a feature which open twitter search page with current hashtag.
* Add a feature which open twitter home page.
* Add a feature which open GitHub home page.

## 1.3

### Enhancements

* Release by Mac App Store.
* Support window minimize.
* Add `Editor` menu includes menu items for clear contents in main window.

### Bug Fixes

* Remove Invalid menus.
* Fix a bug that twitter account is not switched when select your twitter accounts on preferences.

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
