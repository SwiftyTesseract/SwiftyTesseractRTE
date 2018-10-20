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
  
  var engine: RealTimeEngine!
  var excludeLayer: CAShapeLayer!
  var flashlightButton: UIBarButtonItem!
  var recognitionButton: UIButton!
  var recognitionTitleLabel: UILabel!
  var recognitionLabel: UILabel!
  
  @IBOutlet weak var informationLabel: UILabel!
  @IBOutlet weak var previewView: UIView!
  @IBOutlet weak var regionOfInterest: UIView!
  @IBOutlet weak var regionOfInterestWidth: NSLayoutConstraint!
  @IBOutlet weak var regionOfInterestHeight: NSLayoutConstraint!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // MARK: - UI Setup
    let navigationBar = navigationController?.navigationBar
    let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    
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
    recognitionButton.setTitleColor(view.tintColor, for: .normal)
    recognitionButton.setTitle("Start Recognition", for: .normal)
    recognitionButton.addTarget(self, action: #selector(recognitionButtonTapped(_:)), for: .touchUpInside)
    
    recognitionTitleLabel = UILabel()
    recognitionTitleLabel.text = "Recognition Text:"
    recognitionTitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
    recognitionTitleLabel.textColor = .white
    
    recognitionLabel = UILabel()
    recognitionLabel.textAlignment = .center
    recognitionLabel.numberOfLines = 20
    recognitionLabel.textColor = .white
    recognitionLabel.text = "Let's Do This!"
    
    let stackView = UIStackView(arrangedSubviews: [recognitionButton, recognitionTitleLabel, recognitionLabel])
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
    
    let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
    
    regionOfInterest.addGestureRecognizer(panGesture)
    regionOfInterest.layer.borderWidth = 1.0
    regionOfInterest.layer.borderColor = UIColor.blue.cgColor
    regionOfInterest.backgroundColor = .clear
    
    excludeLayer = CAShapeLayer()
    excludeLayer.fillRule = .evenOdd
    excludeLayer.fillColor = UIColor.black.cgColor
    excludeLayer.opacity = 0.7
    
    // RealTimeEngine Setup
    
    let swiftyTesseract = SwiftyTesseract(language: .english)
    engine = RealTimeEngine(swiftyTesseract: swiftyTesseract, desiredReliability: .verifiable) { [weak self] recognizedString in
      AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
      DispatchQueue.main.async { [weak self] in
        self?.recognitionLabel.text = recognizedString
      }
      self?.recognitionIsRunning = false
    }
    
    engine.recognitionIsActive = false
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
