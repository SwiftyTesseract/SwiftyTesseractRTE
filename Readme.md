# SwiftyTesseractRTE
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) 

#### SwiftyTesseractRTE is currently only availble for use on iOS

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
@IBOutlet weak var areaOfInterest: UIView!

override func viewDidLoad() {
  engine = SwiftyTesseractRTE(recognitionLanguage: .english, desiredReliability: .available)
  engine.delegate = self
}

override func viewDidLayoutSubviews() {
  engine.previewLayer.frame = previewView.bounds
  engine.areaOfInterest = areaOfInterest.frame

  previewView.addSublayer(engine.previewLayer)
  previewView.addSublayer(areaOfInterest.layer)
}

```
Conform to the SwiftyTesseractRTEDelegate protocol
```swift
func onRecognitionComplete(_ recognizedString: String) {
    print(recognizedString)
}
```

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

### Additional configuration
1. Download the appropriate language training files from the [tessdata_fast](https://github.com/tesseract-ocr/tessdata_fast) or [tessdata_best](https://github.com/tesseract-ocr/tessdata_best) repository.
2. Place your language training files into a folder on your computer named 'tessdata'
3. Drag the folder into your project. You **must** enure that "Create folder references" is checked or recognition will **not** work.
