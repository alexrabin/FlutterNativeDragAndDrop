## 0.0.4
* Android Support! Requires Android 7.0 or higher
## 0.0.3+4
* Fixed an issue where images would register as the text or url data type instead of the image data type
* Fixed an issue where text and urls would regsiter as the file data type when `DropDataType.file` was only specified
## 0.0.3+3
* Fixed an issue where the flutter app would crash if `allowedDropFileExtensions` wasn't defined

## 0.0.3+2
* Added boolean `NativeDropView.receiveNonAllowedItems` to allow non-allowed items to be dropped if at least one item in the dropping session was allowed
* Fixed a bug where files such as PDF would be categorized as DropDataType.pdf even if only DropDataType.file was allowed
* Fixed a bug where documents (such as .numbers) dropped from iCloud would not be accepted
* Refactor iOS Swift code for readability

Thank you @getBoolean

## 0.0.3+1
* Files from iCloud no longer need to be added directly to allowedDropFileExtensions when dataType == DropDataType.file 
* Updated Readme

Thank you [@getBoolean](https://github.com/getBoolean) for solving this issue
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
