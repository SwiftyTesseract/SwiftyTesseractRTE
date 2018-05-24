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
  var flashlightButton: UIBarButtonItem!
  var recognitionButton: UIButton!
  var recognitionTitleLabel: UILabel!
  var recognitionLabel: UILabel!
  var imageView: UIImageView!
  
  @IBOutlet weak var informationLabel: UILabel!
  @IBOutlet weak var previewView: UIView!
  @IBOutlet weak var regionOfInterest: UIView!
  @IBOutlet weak var regionOfInterestWidth: NSLayoutConstraint!
  @IBOutlet weak var regionOfInterestHeight: NSLayoutConstraint!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let navigationBar = navigationController?.navigationBar
    let textAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
    
    if #available(iOS 11.0, *) {
      navigationBar?.prefersLargeTitles = true
      navigationBar?.largeTitleTextAttributes = textAttributes
    }
    
    navigationBar?.titleTextAttributes = textAttributes
    navigationBar?.isTranslucent = false
    navigationBar?.barTintColor = .black
    navigationItem.title = "SwiftyTesseractRTE"
    
    flashlightButton = UIBarButtonItem(title: "Flashlight On", style: .plain, target: self, action: #selector(flashLightButtonTapped(_:)))
    navigationItem.rightBarButtonItem = flashlightButton
    
    recognitionButton = UIButton()
    recognitionButton.setTitleColor(self.view.tintColor, for: .normal)
    recognitionButton.setTitle("Start Recognition", for: .normal)
    recognitionButton.addTarget(self, action: #selector(recognitionButtonTapped(_:)), for: .touchUpInside)
    
    recognitionTitleLabel = UILabel()
    recognitionTitleLabel.text = "Recognition Text:"
    recognitionTitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
    recognitionTitleLabel.textColor = .white
    
    recognitionLabel = UILabel()
    recognitionLabel.textColor = .white
    recognitionLabel.text = "Let's Do This!"
    recognitionLabel.lineBreakMode = .byWordWrapping
    
    imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
    
    let stackView = UIStackView(arrangedSubviews: [recognitionButton, recognitionTitleLabel, recognitionLabel, imageView])
    stackView.axis = .vertical
    stackView.alignment = .center
    stackView.distribution = .fill
    stackView.spacing = 8.0
    stackView.translatesAutoresizingMaskIntoConstraints = false
    
    view.addSubview(stackView)
    stackView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
    stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    stackView.topAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    stackView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor).isActive = true
//    stackView.heightAnchor.constraint(greaterThanOrEqualToConstant: 50).isActive = true
    
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
  
  @objc func recognitionButtonTapped(_ sender: Any) {
    recognitionIsRunning.toggle()
  }
  
  @objc func flashLightButtonTapped(_ sender: Any) {
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
    let flashlightButtonTitle = device.torchMode == .off ? "Flashlight On" : "Flashlight Off"
    flashlightButton.title = flashlightButtonTitle
  }
}

extension ViewController: SwiftyTesseractRTEDelegate {
  func inspectImage(_ image: UIImage) {
    DispatchQueue.main.async { [weak self] in
      self?.imageView.image = image
    }
  }
  
  func onRecognitionComplete(_ recognizedString: String) {
//    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    DispatchQueue.main.async { [weak self] in
      self?.recognitionLabel.text = recognizedString
      print(recognizedString)
    }
//    recognitionIsRunning = false
  }
  
  
  
}

extension Bool {
  mutating func toggle() {
    self = !self
  }
}

