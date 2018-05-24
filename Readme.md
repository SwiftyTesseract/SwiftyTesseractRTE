# SwiftyTesseractRTE
![pod-version](https://img.shields.io/cocoapods/v/SwiftyTesseractRTE.svg) ![platforms](https://img.shields.io/badge/Platform-iOS%2010.0%20%2B-lightgrey.svg) ![swift-version](https://img.shields.io/badge/Swift-4.0%20%2F%204.1-orange.svg) [![Build Status](https://travis-ci.org/SwiftyTesseract/SwiftyTesseractRTE.svg?branch=master)](https://travis-ci.org/SwiftyTesseract/SwiftyTesseractRTE)

#### SwiftyTesseractRTE can only currently be used in portrait mode.

<p align="center">
<img alt="SwiftyTesseractRTE-example" src=https://lh3.googleusercontent.com/21owOJe7Kll0JXp2hWr3CKCLvKlgpPcjpWaJpyXzyrsyBYFMY-Dl2wmOth_XWLNa7nCGis6fzuBxAJV0oR9OjagQZTZ2Kfgpl2Pm94SdBMiQEiOaA92i8yDeZYa9ojALX9YIGWgIGlfsF5PNTE02HsKz51i8ca54QWMkwCDeKj9FME63etqqhvrgxLOdwR9X5zwFUoqHumktqNLSOZYL6i6ar4qjNJ3SRWoTastaZGQcCltskrnYXuwDrIbYUcuP8_j9xAA7EmieZf13yMRSQ13qmZ7kT-pTQ578klIqo1cU_rnKyTFDOtuBjtH_6nf_5EpF3euFsC1UFB0pLA7nLcL70qfLvL2qk2jjnA0447xbvHsKR8JqCDbrbiEriD6LaVQhvuAQg0OWgqrDAFTU9ApQz5riq6EFTyVn_92IJC2cjISeZ9kftrHAGP2Kk6W2M7yDIKhy7-4YJq4zpsDKR50nSU0RKkilZX-bSq_MpDPGfa9ptwXR5SYDBVGd2Me3emY2NqqHhwlbXC-VO5keni8q87ISUEsoLJZ_6uQ8JE6AfnJ01VwSx3l9kl4cX2g1G3WzWZ5zWqEuw8G8nfKw_ZtjBnqDDN3cb_xKLHeHNE4WqIcGXCh9ZaZmmcizj1WUoXphRYBZQ3T_aBL9mOz_mEyQNDuvujo=w413-h734-no />
</p>

# About SwiftyTesseractRTE
SwiftyTesseractRTE (SwiftyTesseract Real-Time Engine) is a real-time optical character recognition library built on top of SwiftyTesseract.

# Using SwiftyTesseractRTE in Your Project
## Import the neccessary modules
```swift
import SwiftyTesseract
import SwiftyTesseractRTE
```

Create an instance of SwiftyTesseractRTE and assign it's regionOfInterest property. 
```swift
var realTimeEngine: SwiftyTesseractRTE!

@IBOutlet weak var previewView: UIView!
@IBOutlet weak var regionOfInterest: UIView! // A subview of previewView

override func viewDidLoad() {
  let swiftyTesseract = SwiftyTesseract(language: .english)
  realTimeEngine = SwiftyTesseractRTE(swiftyTesseract: swiftyTesseract, desiredReliability: .verifiable)
  realTimeEngine.delegate = self
}

override func viewDidLayoutSubviews() {
  // Must occur during viewDidLayoutSubviews() - Autolayout constraints are not set in viewDidLoad()
  realTimeEngine.bindPreviewLayer(to: previewView)
  realTimeEngine.regionOfInterest = regionOfInterest.frame

  // Only neccessary if providing a visual cue where the regionOfInterest is to your end user
  previewView.addSublayer(regionOfInterest.layer)
}

```

## Conform to the SwiftyTesseractRTEDelegate protocol
```swift
extension YourViewController: SwiftyTesseractRTEDelegate {

  func onRecognitionComplete(_ recognizedString: String) {
      // Do something with the recognized string
  }

}
```
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
For camera permissions, you will need to add the `Privacy - Camera Usage Description` permission to your `Info.plist` file. SwiftyTesseractRTE will handle requesting permission if it is not already granted.

# A Note about Portrait-Only
SwiftyTesseractRTE is currently only able to utilized in portrait mode, but that does not mean your entire app also has to be portrait mode only. See the example project's AppDelegate (specifically the addition of a `shouldRotate` boolean member variable and the implementation of `application(_:supportedInterfaceOrientationsFor:)`) and ViewController files (specifically the `viewWillAppear()` and `viewWillDisappear()` methods) for an example on how to make a single view controller portrait mode only. 

# Installation
### [CocoaPods](https://guides.cocoapods.org/using/using-cocoapods.html)

**Tested with `pod --version`: `1.3.1`**

```ruby
# Podfile
use_frameworks!

target 'YOUR_TARGET_NAME' do
    pod 'SwiftyTesseractRTE',    '~> 1.0'
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
