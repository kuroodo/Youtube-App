# Youtube-app
A [Flutter](https://flutter.dev/) project I made while learning [Riverpod](https://pub.dev/packages/flutter_riverpod) and studying the [Youtube Data API](https://developers.google.com/youtube/v3)

This project is built using Flutter v3.0. Some dependencies may not be up to date which may lead to some warnings/errors being displayed in the console, but they should not affect the application's function.

This application was built for mobile and was tested on an android device with SDK version 29.




![app](https://user-images.githubusercontent.com/9257713/171057396-269d19a3-c36a-490d-bfb5-a0945068c1e3.gif)




I would appreciate any feedback!

# Running the project

In order to run the project, install at least Flutter version 3.0 and anything else required to run a flutter project.

Create a Youtube Data API v3 key via the [Google Developer Console](https://console.developers.google.com) and store it in the API_KEY field located in lib/utilities/keys.dart

# Future TODO
- Share button
- Better support for upcoming streams
- Pressing on channels to list and watch channel videos
- Add channels to search results

# Notes:
There is no 360 video support

There is an issue with search results and related videos having duplicate results. This may be an issue with the youtube API since I replicated it using the tests on the official docs. I may in the future add a check to avoid listing duplicate results.
	
