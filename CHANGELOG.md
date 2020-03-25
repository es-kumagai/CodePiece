# CodePiece

Change Logs.

## 2.1.6

### Updates

* Timeline view now can be selected using keyboard shortcuts.
* Adjust capture image size.

## 2.1.5

### Updates

* Optimize displaying icon in Timeline view.

## 2.1.4

### Updates

* Decode '&amp;' in Timeline view.
* Skip updating a timeline while other update process running.
* Make drawing icon stable a little bit in Timeline view.

## 2.1.3

### Updates

* Show related tweets only users who talked about the current hashtags from yesterday.

## 2.1.2

### Fixes

* Fix a problem truncating last line when sending to Xcode.

## 2.1.1

### Updates

* Adjust capture image width.
* Move the app's window to front when calling by URL scheme.

### Fixes

* Fix a problem the app crush when selecting last line in Xcode and send it to the app using Xcode Source Editor Extension.
* Fix a problem that selected code was truncated if the code includes a '&' character.

## 2.1.0

### Enhancement

* Supports Xcode Source Editor Extension to send code from Xcode.

## 2.0.9

### Updates

* There are many related user about hashtags, adopted users recently tweets in Related tweets view.
* Related tweets's update interval become bigger when the view is disappeared.

### Fixes

* Fix a problem the app cannot detect the changes of internet connectivity.

## 2.0.8

### Fixes

* Fix a problem the app crashed when open twitter with selecting status after once moved out to other Timeline view.

## 2.0.7

### Updates

* Decode '&lt;' and '&gt;' in Timeline view.

## 2.0.6

### Enhancement

* Count length of entering description having URL more correctly.
* Escape URL with '%' in description when non ASCII characters are detected.

### Fixes

* Fix a problem that truncated tweet unexpectedly when the tweet is long.

## 2.0.5

### Enhancement

* It can open in Twitter that tweets related to current hashtags from menu bar.

### Fixes

* Fix a problem that the CodePiece crash when try to open selecting tweet in Twitter from menu bar.

## 2.0.4

### Enhancement

* It is able to show that tweets posted by users who talk about specified hashtags in Timeline view.
* Add URL scheme named "codepiece://open" that is used to open CodePiece with specifying custom hashtags and language and code.

## 2.0.3

### Enhancement

* Timelines now continue refreshing in background.
* Mentions can be shown in Timeline view.

## 2.0.2

### Enhancement

* Switch showing tweets between having hashtags and posted user own in Timeline view.

### Updates

* Change the save method of GitHub authorization information. (Needs re-authorization.)

## 2.0.1

### Fixes

* Applying entities more precisely in Timeline View.
* Save application state when terminating.

## 2.0.0

### Enhancements

* Supports darkmode.

### Fixes

* Restore hashtag when the app crashed.
* Fix a problem that some tweet could not be show in timeline.

### Updates

* Make features of Twitter authentication more stable.
* Rewrite with Swift 5.1

## 1.4.12

### Enhancements

* Supports code types Simple text and Kotlin.

### Fixes

* Fix a problem might failed to get gist capture.
* Fix a problem that might not be able to authenticate when move other preference window during entering a Twitter PIN code.

## 1.4.11

### Fixes

* Display code text with simple text format. So you can see the code if you paste some codes with white text color.

## 1.4.10

### Fixes

* Refine error message more readable.

## 1.4.9

### Enhancements

* Can see selected language and hashtags easily in watermark text field.

## 1.4.8

### Enhancements

* Count the number of tweet text count more accurately.
* Can open link directly from timeline view.

## 1.4.7

### Enhancements

* Capture codes with Line number.

## 1.4.6

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
