# SwiftyTesseractRTE
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) ![platforms](https://img.shields.io/badge/Platform-iOS-lightgrey.svg)

#### SwiftyTesseractRTE can only currently be used in portrait mode.

# About SwiftyTesseractRTE
SwiftyTesseractRTE (SwiftyTesseract Real-Time Engine) is a real-time optical character recognition library built on top of SwiftyTesseract.

# Using SwiftyTesseractRTE in Your Project
Import the neccessary modules
```swift
import SwiftyTesseract
import SwiftyTesseractRTE
```

Create an instance of SwiftyTesseractRTE and assign it's previewLayer and areaOfInterest properties
```swift
private var engine: SwiftyTesseractRTE!

@IBOutlet weak var previewView: UIView!
@IBOutlet weak var regionOfInterest: UIView! // A subview of previewView

override func viewDidLoad() {
  let swiftyTesseract = SwiftyTesseract(language: .english)
  engine = SwiftyTesseractRTE(swiftyTesseract: swiftyTesseract, desiredReliability: .verifiable)
  engine.delegate = self
}

override func viewDidLayoutSubviews() {
  // Must occur during viewDidLayoutSubview()
  engine.bindViewToPreviewLayer(previewView)
  engine.regionOfInterest = regionOfInterest.frame

  // Only neccessary if providing a visual cue to where the area of interest is
  previewView.addSublayer(areaOfInterest.layer)
}

```
Conform to the SwiftyTesseractRTEDelegate protocol
```swift
func onRecognitionComplete(_ recognizedString: String) {
    print(recognizedString)
}
```

## A Note about Portrait-Only
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

### [Carthage](https://github.com/Carthage/Carthage)

**Tested with `carthage version`: `0.28.0`**

Add this to `Cartfile`

```
github "SwiftyTesseract/SwiftyTesseractRTE" ~> 1.0
```

```bash
$ carthage update
```


## Setting Up SwiftyTesseract for Use in SwiftyTesseractRTE
See SwiftyTesseract's [Additional Configuration](https://github.com/Steven0351/SwiftyTesseract/blob/master/Readme.md#additional-configuration) section on properly setting up SwiftyTesseract to be properly utilized in your project.
