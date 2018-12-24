# OpenTube

This is an open source client for YouTube that requires no Google account and offers many
YouTube Red features that Google has left out of the official app.

It uses YouTube’s RSS feeds to act as subscriptions that are saved locally on the device.

## Features
* Background playback
* Download videos
* No Ads
* PIP on supported iPad models
* Hide videos from your subscription feed
* Mark videos as watched and unwatched

## Screenshots

Check the Media directory for screen shots.


## Building the project

This project is meant to be built locally and installed on a device via XCode. 
To get started clone or download this project and run `bash setup.sh` this will create a bundle ID
which is needed to run the app on the simulator and a real device. You can also call this script with
`bash setup.sh com.custom.identifier` filling in whatever you want to have that be your bundle ID.

You can then edit the file at `OpenTube/Application/Config/local.xcconfig` to add your Development Team
or set that up in Xcode via `General -> Project -> Signing -> Team`.

To get the required third party dependencies you'll need [Cocoapods](https://cocoapods.org/). You can install many ways, but one way is
via gem with the command `gem install cocoapods`. Once you have Cocoapods, run the command `pod install`.

Now open up Xcode via the file `OpenTube.xcworkspace`, build and run the app.

## FAQ

### Why is 720p the highest resolution?

YouTube offers videos up to 4k on supported channels, but they use a protocol called DASH. What this means, 
is that videos and audio are not stored in the same file, instead the client must grab the two files and sync up the media.

This is all very doable, but due to time restrictions I have I don't want to do that just now. I also encountered an issue
where an AVAsset pointing to a 1080p+ stream cannot stream the media. Instead it must download the whole file
then play it. I don't kow why this happens, but it isn't very useful when you need to download a 200MB file just to start streaming it.

### Why not release this on the store?

This is app is mostly an example on how to create a YouTube client without the Google restrictions.
Becaue this app bypasses a lot of the restrictions Google places on the use of YouTube (background playback, downloading videos)
putting this app on the store would result in a near instant take down from Google.

### Why did you create this?

I had seen a lot of suggestions on how to use YouTube without going through official means. Using platforms
like Hooktube and an RSS converter that would convert YouTube RSS links into the Hooktube equivalent. That
works fine on desktop, but iOS was missing out. I also don't appreciate how Google hides their "Pro" features
like background playback behind a paywall especially when it's system level API's that they're blocking.

### I get an error when running about "Failed to get bundle ID"

Please run the setup script and follow the instructions to generate a bundle identifier. You'll need to close and reopen Xcode after doing this for the changes to take effect.

### How do I add a channel to my feed?

On the browse tab, use the YouTube web interface to navigate to a channel. Once there you'll see a subscribe or unsubscribe
button in the top right. Tapping that will subscribe to the channel and add it to your feed.

### How do I contribute?

Open up a PR and let me know what the changes are for.

### I encountered a bug or have feedback about the app.

Open up an issue so I can investigate the problem
