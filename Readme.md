# SwiftyTesseractRTE
![pod-version](https://img.shields.io/cocoapods/v/SwiftyTesseractRTE.svg) ![platforms](https://img.shields.io/badge/Platform-iOS%2010.0%20%2B-lightgrey.svg) ![swift-version](https://img.shields.io/badge/Swift-4.2-orange.svg) [![Build Status](https://travis-ci.org/SwiftyTesseract/SwiftyTesseractRTE.svg?branch=master)](https://travis-ci.org/SwiftyTesseract/SwiftyTesseractRTE)

#### SwiftyTesseractRTE can only currently be used in portrait mode.

<p align="center">
<img alt="SwiftyTesseractRTE-example" src=https://goo.gl/5rZU6V width="200px" />
</p>

# About SwiftyTesseractRTE
SwiftyTesseractRTE (SwiftyTesseract Real-Time Engine) is a real-time optical character recognition library built on top of SwiftyTesseract.

|Swift Version|SwiftyTesseractRTE Version|
|:-------------|--------------------------:|
|4.0|1.x.x|
|4.1|1.x.x|
|4.2|2.x.x|

# Using SwiftyTesseractRTE in Your Project
## Import the neccessary modules
```swift
import SwiftyTesseract
import SwiftyTesseractRTE
```

Create an instance of RealTimeEngine and assign it's regionOfInterest property. 
```swift
var realTimeEngine: RealTimeEngine!

@IBOutlet weak var previewView: UIView!
@IBOutlet weak var regionOfInterest: UIView! // A subview of previewView

override func viewDidLoad() {
  let swiftyTesseract = SwiftyTesseract(language: .english)
  realTimeEngine = RealTimeEngine(swiftyTesseract: swiftyTesseract, desiredReliability: .verifiable) { recognizedString in
    // Do something with the recognized string
  }
}

override func viewDidLayoutSubviews() {
  // Must occur during viewDidLayoutSubviews() - Autolayout constraints are not set in viewDidLoad()
  realTimeEngine.bindPreviewLayer(to: previewView)
  realTimeEngine.regionOfInterest = regionOfInterest.frame

  // Only neccessary if providing a visual cue where the regionOfInterest is to your end user
  previewView.addSublayer(regionOfInterest.layer)
}

```

# Optical Character Recognition and Camera Preview
SwiftyTesseractRTE allows for showing the camera preview without constantly attempting to recognize text. This allows you to let your end user to line up the text to be scanned before starting the scan. The `recognitionIsActive` property is set to `true` by default, so to prevent a scan from starting immediately, set `recognitionIsActive` to false after instantiating `RealTimeEngine` and before calling `startPreview()`. Calling `stopPreview()` also prevents recognition from being attempted because there are no inbound camera frames to be scanned.

## Starting and Stopping Recognition
```swift
// Starts optical character recognition
realTimeEngine.recognitionIsActive = true

// Stops optical character recognition
realTimeEngine.recognitionIsActive = false
```

## Starting and Stopping Camera Preview
```swift
// Starts camera preview
realTimeEngine.startPreview()

// Stops camera preview
realTimeEngine.stopPreview()
```

## Camera Permissions
For camera permissions, you will need to add the `Privacy - Camera Usage Description` permission to your `Info.plist` file. If you are using the default SwiftyTesseractRTE `AVManager` implementation, permission will be requested at the time the camera preview is being generated. If a custom implementation of `AVManager` is provided, then it will be up to the developer to implement the permission request. For most use cases, the default `AVManager` implementation is preferred and a custom implementation should only be provided if access to `CMSampleBuffer`s are needed from the camera at the same time that SwiftyTesseractRTE is being run for OCR.

## RealTimeEngine `onRecognitionComplete` closure property
Starting in SwiftyTesseractRTE 2.0, the SwiftyTesseractRTEDelegate protocol has been replaced in favor of a closure property called `onRecognitionComplete` with a type of `((String) -> ())?`. This can be assigned in a few ways:
### Trailing Closure on Instantiation
```swift
RealTimeEngine(swiftyTesseract: swiftyTesseract, desiredReliability: .verifiable) { recognizedString in
    // Do something with the recognized string
}
```
### Passing a Function Parameter
```swift
RealTimeEngine(swiftyTesseract: swiftyTesseract, desiredReliability: .verifiable, onRecognitionComplete: aFunction)
```
### Property Injection
```swift
let realTimeEngine = RealTimeEngine(swiftyTesseract: swiftyTesseract, desiredReliability: .verifiable)
// Anonymous closure
realTimeEngine.onRecognitionComplete = { recognizedString in 
  // Do something with the recognized string
}
// Named closure
realTimeEngine.onRecognitionComplete = aFunction
```

# A Note about Portrait-Only
SwiftyTesseractRTE is currently only able to utilized in portrait mode, but that does not mean your entire app also has to be portrait mode only. See the example project's AppDelegate (specifically the addition of a `shouldRotate` boolean member variable and the implementation of `application(_:supportedInterfaceOrientationsFor:)`) and ViewController files (specifically the `viewWillAppear()` and `viewWillDisappear()` methods) for an example on how to make a single view controller portrait mode only. 

# Installation
### [CocoaPods](https://guides.cocoapods.org/using/using-cocoapods.html)

**Tested with `pod --version`: `1.3.1`**

```ruby
# Podfile
use_frameworks!

target 'YOUR_TARGET_NAME' do
    pod 'SwiftyTesseractRTE',    '~> 2.0'
end
```

Replace `YOUR_TARGET_NAME` and then, in the `Podfile` directory, type:

```bash
$ pod install
```

## Setting Up SwiftyTesseract for Use in SwiftyTesseractRTE
See SwiftyTesseract's [Additional Configuration](https://github.com/SwiftyTesseract/SwiftyTesseract/blob/master/Readme.md#additional-configuration) section on properly setting up SwiftyTesseract to be utilized in your project.

## Documentation
Official documentation for SwiftyTesseractRTE can be found [here](https://swiftytesseract.github.io/SwiftyTesseractRTE/)

# Contributions Welcome
Contributions are always welcome! Please refer to [Contributing to SwiftyTesseractRTE](https://github.com/SwiftyTesseract/SwiftyTesseractRTE/blob/master/Contributions.md) for the full guidelines on creating issues and opening pull requests to the project.
