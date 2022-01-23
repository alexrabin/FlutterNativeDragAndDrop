## 0.0.3
* Must set allowedDropDataTypes or allowedDropFileExtensions (at least one of these attributes must be defined)
* Fixed an issue where some file types wouldn't register from an iCloud folder

## 0.0.2
* Can select certain data types
* Can add custom extensions
* Can update the allowed count, allowed data types, and allowed extensions once NativeDropView is created
* Updated example

Thank you [@getBoolean](https://github.com/getBoolean) for helping with these features!
## 0.0.1+4
* Removed width and height arguments ( Wrap drop view with a container instead)
* Updated read me
## 0.0.1+3
* Added metadata object to DropData
    - Contains file type for string files

## 0.0.1+2

* Added ability to set the amount of items allowed to be dropped in the view
* Updated the example with different examples of allowed number of items in a dropview widget
* Bug fixes
* BREAKING CHANGE: 
    - changed `loadingCallback` to `loading`
    - changed `dataReceivedCallback` to `dataReceived`

## 0.0.1+1

* Added example gif

## 0.0.1

* Support iPadOS 11 and iOS 15 and above
* Only has drop support (can drag data from outside of the app and drop into your flutter application)
* Supports text, urls, images, videos, audio, and pdfs
