//
//  RecordButton.swift
//  Voice Capture Utility
//
//  Created by Jia Rui Shan on 2019/5/6.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

let BUTTON_LIGHT_TINT = UIColor(red: 0.75, green: 0.89, blue: 1, alpha: 1)
let BUTTON_DEEP_BLUE = UIColor(red: 0.49, green: 0.7, blue: 0.94, alpha: 1)
let BUTTON_TINT = UIColor(red: 0.7, green: 0.85, blue: 1, alpha: 1)
let RECORD_TINT = UIColor(red: 1, green: 0.6, blue: 0.6, alpha: 1)

class RecordButton: UIButton {
    
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
    
    init(duration: Int, radius: CGFloat, recorder: Recorder) {
        super.init(frame: .zero)
        
        self.duration = CGFloat(duration)
        self.recorder = recorder
        
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
        self.titleLabel?.font = .systemFont(ofSize: 17)
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.addTarget(self,
                       action: #selector(record),
                       for: .touchUpInside)
        
        self.addTarget(self,
                       action: #selector(buttonPressed),
                       for: .touchDown)
        
        self.addTarget(self,
                       action: #selector(buttonLifted),
                       for: [.touchUpInside, .touchUpOutside])
        
        self.setNeedsDisplay()
    }
    
    @objc private func buttonPressed() {
        self.setTitleColor(UIColor(white: 0.91, alpha: 1), for: .normal)
        self.layer.borderColor = BUTTON_LIGHT_TINT.cgColor
    }
    
    @objc private func buttonLifted() {
        let animation = {
            self.setTitleColor(.gray, for: .normal)
            self.layer.borderColor = self.tintColor.cgColor
        }
        
        UIView.transition(with: self,
                          duration: 0.18,
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
        print("Recording saved to \(recorder.audioFilename.path).")

//        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Stopped recording"), object: self)
    }

    @objc private func record() {
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
                self.shapeLayer.strokeColor = RECORD_TINT.cgColor
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
//                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "No mic permission"), object: self)
                    return
                }
                
                // Has mic access, continue to record
                
//                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Started recording"), object: self)
                
                addAnimation()
                let finishTime = Date().addingTimeInterval(Double(self.duration))
                self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
                    if (Date().timeIntervalSince(finishTime) > 0 || self.shapeLayer.animation(forKey: "drawCircleAnimation") == nil) { // User interrupted recording
                        timer.invalidate()
                        self.record()
                        return;
                    }
                    let remaining = finishTime.timeIntervalSince(Date())
//                    self.setTitle(String(Int(remaining)), for: .normal)
                    self.setTitle("Stop", for: .normal)
                }
                self.timer?.fire()
            }
        }
    }

}
