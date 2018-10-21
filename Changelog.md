#### 2.0.0 - TBD
* `SwiftyTesseractRTE` class renamed to `RealTimeEngine`
* `SwiftyTesseractRTEDelegate` removed in favor of `onRecognitionComplete` closure property.
* Added `onRecognitionComplete` parameter of type `((String) -> ())?` to all `RealTimeEngine` initializers
* Removed redundant `crop(_:toBoundsOf:)` method in `AVSampleProcessor` protocol, leaving only `crop(_:toBoundsOf:containedIn:)` as the only cropping method.
* `SwiftyTesseract` dependency updated to use 2.x versions
* Cleaned up and optimized non-public facing implementation details in `RecognitionReliability`, `ImageProcessor`, and `RealTimeEngine`
* Updated for Swift 4.2
* Updated Readme and Documentation

#### 1.1.0 - May 24, 2018
* `AVManager` protocol made public
* Added 2 new cases to `RecognitionReliability` to allow for returning results on 1 and 2 frames
* Fixed issue with internal `ImageProcessor` that was not correctly calculating the area to crop when the aspect ratio of `previewLayer` was less than 1

#### 1.0.4 - May 5, 2018
* Internal `ImageProcessor` struct was redrawing the captured image at a much lower size which was causing image degradation. Instead of redrawing the image at the scale of `regionOfInterest`, `regionOfInterest` is now scaled to the size of the image.

#### 1.0.3 - April 20, 2018
* Fixed a bug where SwiftyTesseractRTE was evalutating the previous frames' OCR results. When the frames all matched, the result returned was not among the evaluated results that may have not had the level of accuracy defined.

* Cleaned up non-user facing code for better maintainability and clarity at internal callsites.

#### 1.0.2 - April 4, 2018
* Documentation fix

#### 1.0.1 - March 31, 2018
* Added Travis support