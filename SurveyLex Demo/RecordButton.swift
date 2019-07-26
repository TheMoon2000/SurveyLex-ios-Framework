//
//  RecordButton.swift
//  Voice Capture Utility
//
//  Created by Jia Rui Shan on 2019/5/6.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class RecordButton: UIButton {
        
    let parentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    private var saveLocation: URL!
    private var recorder: Recorder!
    var duration: CGFloat = 0
    let shapeLayer = CAShapeLayer()
    private var startTime = 0
    private var timer: Timer?
    
    override var buttonType: UIButton.ButtonType {
        return .custom
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func tintColorDidChange() {
        self.layer.borderColor = tintColor.cgColor
    }
    
    init(duration: Int, saveName: String, radius: CGFloat) {
        super.init(frame: .zero)
        
        self.duration = CGFloat(duration)
        self.recorder = Recorder()
        self.saveLocation = parentDirectory.appendingPathComponent(saveName)
        recorder.audioFilename = self.saveLocation
        
        
        // Apply layout constraints
        self.widthAnchor.constraint(equalToConstant: radius * 2).isActive = true
        self.heightAnchor.constraint(equalToConstant: radius * 2).isActive = true
        
        // Layer appearance
        self.layer.borderColor = UIColor.gray.cgColor
        self.layer.borderWidth = 1.5
        self.layer.cornerRadius = radius
        layer.masksToBounds = true
        self.clipsToBounds = true
        self.setTitle("Record", for: .normal)
        self.setTitleColor(.gray, for: .normal)
        self.titleLabel?.font = .systemFont(ofSize: 18)
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.addTarget(self,
                       action: #selector(record),
                       for: .touchUpInside)
        
        
        self.addTarget(self,
                       action: #selector(buttonPressed),
                       for: .touchDown)
        
        self.addTarget(self,
                       action: #selector(buttonLifted),
                       for: [.touchUpInside,
                             .touchUpOutside,
                             .touchCancel,
                             .touchDragExit,
                             .touchDragOutside])
        
        self.setNeedsDisplay()
    }
    
    @objc private func buttonPressed() {
        self.setTitleColor(UIColor(white: 0.93, alpha: 1), for: .normal)
        self.layer.borderColor = BUTTON_LIGHT_TINT.cgColor
    }
    
    @objc private func buttonLifted() {
        let animation = {
            self.setTitleColor(.gray, for: .normal)
            self.layer.borderColor = self.tintColor.cgColor
        }
        
        UIView.transition(with: self,
                          duration: 0.2,
                          options: .transitionCrossDissolve,
                          animations: animation,
                          completion: nil)
    }
    
    func stopRecording() {
        recorder.stopRecording()
        timer?.invalidate()
        setTitle("Record", for: .normal)
        shapeLayer.removeAllAnimations()
        shapeLayer.removeFromSuperlayer()
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Stopped recording"), object: self)
    }

    @objc private func record() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        if recorder.audioRecorder.isRecording {
            stopRecording()
        } else {
            let progress = UIBezierPath(arcCenter: CGPoint(x: bounds.maxX / 2,
                                                           y: bounds.maxY / 2),
                                        radius: self.frame.width / 2,
                                        startAngle: .pi * 1.5,
                                        endAngle: -.pi * 0.5,
                                        clockwise: false)
            
            let addAnimation = {
                self.shapeLayer.path = progress.cgPath
                self.shapeLayer.strokeColor = BUTTON_DEEP_BLUE.cgColor
                self.shapeLayer.lineWidth = 10
                self.shapeLayer.fillColor = UIColor.clear.cgColor
                self.layer.addSublayer(self.shapeLayer)
                self.shapeLayer.strokeEnd = 0.0
                
                let animation = CABasicAnimation(keyPath: "strokeEnd")
                animation.fromValue = 1.0
                animation.toValue = 0.0
                animation.duration = CFTimeInterval(self.duration)
                animation.isRemovedOnCompletion = true
                self.shapeLayer.add(animation, forKey: "drawCircleAnimation")
            }
            
            recorder.startRecording { status in
                
                // No access, gives alert message
                if !status {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "No mic permission"), object: self)
                    return
                }
                
                // Has mic access, continue to record
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Started recording"), object: self)
                
                addAnimation()
                let finishTime = Date().addingTimeInterval(Double(self.duration))
                self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
                    if (Date().timeIntervalSince(finishTime) > 0 || self.shapeLayer.animation(forKey: "drawCircleAnimation") == nil) {
                        timer.invalidate()
                        self.stopRecording()
                        return;
                    }
                }
                self.timer?.fire()
            }
        }
    }

}
