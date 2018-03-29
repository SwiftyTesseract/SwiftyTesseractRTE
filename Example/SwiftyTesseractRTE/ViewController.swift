//
//  ViewController.swift
//  SwiftyTesseractRTE
//
//  Created by Steven0351 on 03/26/2018.
//  Copyright (c) 2018 Steven0351. All rights reserved.
//

import UIKit
import AVFoundation
import AudioToolbox
import SwiftyTesseract
import SwiftyTesseractRTE

class ViewController: UIViewController {

  var recognitionIsRunning = false {
    didSet {
      let recognitionButtonText = recognitionIsRunning ? "Stop Running" : "Start Recognition"
      DispatchQueue.main.async { [weak self] in
        self?.recognitionButton.setTitle(recognitionButtonText, for: .normal)
      }
      engine.recognitionIsActive = recognitionIsRunning
    }
  }
  
  var engine: SwiftyTesseractRTE!
  var excludeLayer: CAShapeLayer!
  
  @IBOutlet weak var informationLabel: UILabel!
  @IBOutlet weak var previewView: UIView!
  @IBOutlet weak var regionOfInterest: UIView!
  @IBOutlet weak var flashLightButton: UIButton!
  @IBOutlet weak var recognitionButton: UIButton!
  @IBOutlet weak var recognitionTextView: UITextView!
  @IBOutlet weak var regionOfInterestWidth: NSLayoutConstraint!
  @IBOutlet weak var regionOfInterestHeight: NSLayoutConstraint!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let swiftyTesseract = SwiftyTesseract(language: .english)
    engine = SwiftyTesseractRTE(swiftyTesseract: swiftyTesseract, desiredReliability: .verifiable)
    engine.recognitionIsActive = false
    engine.delegate = self
    
    let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
    
    regionOfInterest.addGestureRecognizer(panGesture)
    regionOfInterest.layer.borderWidth = 1.0
    regionOfInterest.layer.borderColor = UIColor.blue.cgColor
    regionOfInterest.backgroundColor = .clear
    
    recognitionButton.setTitle("Start Recognition", for: .normal)
    
    excludeLayer = CAShapeLayer()
    excludeLayer.fillRule = kCAFillRuleEvenOdd
    excludeLayer.fillColor = UIColor.black.cgColor
    excludeLayer.opacity = 0.7
    
    engine.startPreview()
  }
  
  override func viewDidLayoutSubviews() {
    engine.bindPreviewLayer(to: previewView)
    engine.regionOfInterest = regionOfInterest.frame
    previewView.layer.addSublayer(regionOfInterest.layer)
    fillOpaqueAroundAreaOfInterest(parentView: previewView, areaOfInterest: regionOfInterest)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
    appDelegate.shouldRotate = false
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
    appDelegate.shouldRotate = true
  }
  
  private func fillOpaqueAroundAreaOfInterest(parentView: UIView, areaOfInterest: UIView) {
    let parentViewBounds = parentView.bounds
    let areaOfInterestFrame = areaOfInterest.frame
    
    let path = UIBezierPath(rect: parentViewBounds)
    let areaOfInterestPath = UIBezierPath(rect: areaOfInterestFrame)
    path.append(areaOfInterestPath)
    path.usesEvenOddFillRule = true
    
    excludeLayer.path = path.cgPath
    parentView.layer.addSublayer(excludeLayer)
  }
  
  @objc func handlePan(_ sender: UIPanGestureRecognizer) {
    let translate = sender.translation(in: regionOfInterest)
    
    UIView.animate(withDuration: 0) {
      self.regionOfInterestWidth.constant += translate.x
      self.regionOfInterestHeight.constant += translate.y
    }
    
    sender.setTranslation(.zero, in: regionOfInterest)
    viewDidLayoutSubviews()
    informationLabel.isHidden = true
  }
  
  
  @IBAction func recognitionButtonTapped(_ sender: Any) {
    recognitionIsRunning.toggle()
  }
  
  @IBAction func flashLightButtonTapped(_ sender: Any) {
    guard let device = AVCaptureDevice.default(for: .video) else { return }
    if device.hasTorch {
      do {
        try device.lockForConfiguration()
        device.torchMode = device.torchMode == .off ? .on : .off
        device.unlockForConfiguration()
      } catch let e {
        print("Error: \(e.localizedDescription)")
      }
    }
    let flashlightImage = device.torchMode == .off ? UIImage(named: "flashlightOff") : UIImage(named: "flashlightOn")
    flashLightButton.setImage(flashlightImage, for: .normal)
  }
}

extension ViewController: SwiftyTesseractRTEDelegate {
  func onRecognitionComplete(_ recognizedString: String) {
    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    DispatchQueue.main.async { [weak self] in
      self?.recognitionTextView.text = recognizedString
    }
    recognitionIsRunning = false
  }
}

extension Bool {
  mutating func toggle() {
    self = !self
  }
}

