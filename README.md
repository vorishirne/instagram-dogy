# instagram-dogy 
## aka dodogy
A dogy themed instagram social network for messaging, posting updates, finding people and coloring the dog world. 

## Code Quality Disclaimer
This repository marks the possibilities in flutter. It can surely influence a person to 
leave the native/legacy code frameworks and add to the flutter state of art community.  

## Features

 * Custom photo feed based on who you follow (using firebase cloud functions)
 * Post high quality videos and photo posts from camera or gallery
   * Like posts
   * Comment on posts
        * View all comments on a post
 * Search for users
 * Notificaitons for likes, comments, follows, etc
 * Animations (heart when liking image) 
 * Improved Caching of Profiles, Images, Etc.
 * Better post creation, add filters to your image
 * Custom Camera Implementation
 * Firebase Security Rules
 * Delete Posts
 * Direct Messaging
 * Stories
 * Profile Pages
   * Follow / Unfollow Users
   * Change image view from grid layout to feed layout
   * Add your own bio
 * Activity Feed showing recent likes / comments of your posts + new followers

## Screenshots
<p>
<img src="https://github.com/vorishirne/instagram-dogy/raw/master/doc/img/activity-feed.jpeg" alt="feed example" width="250">
<img src="https://github.com/vorishirne/instagram-dogy/raw/master/doc/img/following.jpeg" alt="upload photo example" width="250">
<img src="https://github.com/vorishirne/instagram-dogy/raw/master/doc/img/home.jpeg" alt="go to a profile from feed" width="250">
<img src="https://github.com/vorishirne/instagram-dogy/raw/master/doc/img/message-list.jpeg" alt="edit profile example" width="250">
<img src="https://github.com/vorishirne/instagram-dogy/raw/master/doc/img/messages.jpeg" alt="feed example" width="250">
<img src="https://github.com/vorishirne/instagram-dogy/raw/master/doc/img/post-preview.jpeg" alt="upload photo example" width="250">
<img src="https://github.com/vorishirne/instagram-dogy/raw/master/doc/img/profile-edit.jpeg" alt="go to a profile from feed" width="250">
<img src="https://github.com/vorishirne/instagram-dogy/raw/master/doc/img/profile.jpeg" alt="edit profile example" width="250">
<img src="https://github.com/vorishirne/instagram-dogy/raw/master/doc/img/upload-pic.jpeg" alt="feed example" width="250">
<img src="https://github.com/vorishirne/instagram-dogy/raw/master/doc/img/upload-prompt.jpeg" alt="upload photo example" width="250">


</p>

## Dependencies

* [Flutter](https://flutter.dev/)
* [Firestore](https://github.com/flutter/plugins/tree/master/packages/cloud_firestore)
* [Image Picker](https://github.com/flutter/plugins/tree/master/packages/image_picker)
* [Google Sign In](https://github.com/flutter/plugins/tree/master/packages/google_sign_in)
* [Firebase Auth](https://github.com/flutter/plugins/tree/master/packages/firebase_auth)
* [UUID](https://github.com/Daegalus/dart-uuid)
* [Dart Image](https://github.com/brendan-duncan/image)
* [Path Provider](https://github.com/flutter/plugins/tree/master/packages/path_provider)
* [Font Awesome](https://github.com/brianegan/font_awesome_flutter)
* [Dart HTTP](https://github.com/dart-lang/http)
* [Dart Async](https://github.com/dart-lang/async)
* [Flutter Shared Preferences]()
* [Cached Network Image](https://github.com/renefloor/flutter_cached_network_image)

## Getting started

#### 1. [Setup Flutter](https://flutter.dev/docs/get-started/install)

#### 2. Clone the repo

```sh
$ git clone https://github.com/vorishirne/instagram-dogy
$ cd instagram-dogy
```

#### 3. Setup the firebase app

1. You'll need to create a Firebase instance. Follow the instructions at https://console.firebase.google.com.
2. Once your Firebase instance is created, you'll need to enable Google authentication.

* Go to the Firebase Console for your new instance.
* Click "Authentication" in the left-hand menu
* Click the "sign-in method" tab
* Click "Google" and enable it

3. Create Cloud Functions (to make the Feed work)
* Create a new firebase project with `firebase init`
* Copy this project's `functions/lib/index.js` to your firebase project's `functions/index.js`
* Push the function `getFeed` with `firebase deploy --only functions`  In the output, you'll see the getFeed URL, copy that.
* Replace the url in the `_getFeed` function in `feed.dart` with your cloud function url from the previous step.

_You may need to create the neccessary index by running `firebase functions:log` and then clicking the link_

_**If you are getting no errors, but an empty feed** You must post photos or follow users with posts as the getFeed function only returns your own posts & posts from people you follow._

4. Enable the Firebase Database
* Go to the Firebase Console
* Click "Database" in the left-hand menu
* Click the Cloudstore "Create Database" button
* Select "Start in test mode" and "Enable"

5. (skip if not running on Android)

* Create an app within your Firebase instance for Android, with package name com.yourcompany.news
* Run the following command to get your SHA-1 key:

```
keytool -exportcert -list -v \
-alias androiddebugkey -keystore ~/.android/debug.keystore
```

* In the Firebase console, in the settings of your Android app, add your SHA-1 key by clicking "Add Fingerprint".
* Follow instructions to download google-services.json
* place `google-services.json` into `/android/app/`.

6. (skip if not running on iOS)

* Create an app within your Firebase instance for iOS, with your app package name
* Follow instructions to download GoogleService-Info.plist
* Open XCode, right click the Runner folder, select the "Add Files to 'Runner'" menu, and select the GoogleService-Info.plist file to add it to /ios/Runner in XCode
* Open /ios/Runner/Info.plist in a text editor. Locate the CFBundleURLSchemes key. The second item in the array value of this key is specific to the Firebase instance. Replace it with the value for REVERSED_CLIENT_ID from GoogleService-Info.plist

Double check install instructions for both
   - Google Auth Plugin
     - https://pub.dartlang.org/packages/firebase_auth
   - Firestore Plugin
     -  https://pub.dartlang.org/packages/cloud_firestore

# What's Next?
 - [x] Notificaitons for likes, comments, follows, etc
 - [X] Animations (heart when liking image) 
 - [x] Improve Caching of Profiles, Images, Etc.
 - [x] Better post creation, add filters to your image
 - [x] Custom Camera Implementation
 - [x] Firebase Security Rules
 - [x] Delete Posts
 - [x] Direct Messaging
 - [x] Stories
 - [ ] Clean up code
