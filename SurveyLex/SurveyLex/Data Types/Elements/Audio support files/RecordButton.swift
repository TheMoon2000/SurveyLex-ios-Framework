//
//  RecordButton.swift
//  Voice Capture Utility
//
//  Created by Jia Rui Shan on 2019/5/6.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class RecordButton: UIButton {
    
    var delegate: RecordingDelegate?
    
    internal var recorder: Recorder!
    internal var duration: CGFloat = 0
    private let shapeLayer = CAShapeLayer()
    private var finishTime = Date()
    
    /// When recording, represents the number of seconds left
    var timeRemaining: TimeInterval {
        return finishTime.timeIntervalSinceNow
    }
    private var timer: Timer?
    
    var saveURL: URL {
        return recorder!.audioFilename
    }
    
    override var buttonType: UIButton.ButtonType {
        return .custom
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func tintColorDidChange() {
        self.layer.borderColor = tintColor.cgColor
    }
    
    init(duration: Double, radius: CGFloat, recorder: Recorder) {

        super.init(frame: .zero)
        
        // If the given duration is too short, bound it below by 10 seconds
        self.duration = max(CGFloat(duration), 10.0)
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
                       for: [.touchUpInside, .touchUpOutside, .touchDragOutside])
        
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
    
    private func stopRecording(interrupted: Bool) {
        
        recorder.stopRecording() // Saves the file if possible
        setTitle("Record", for: .normal)
        shapeLayer.removeAllAnimations()
        shapeLayer.removeFromSuperlayer()
        timer?.invalidate()
        
        if interrupted {
            delegate?.didFailToRecord(self, error: .interrupted)
            return
        }
        
        let elapsed = Double(duration) - finishTime.timeIntervalSinceNow

        do {
            let _ = try Data(contentsOf: recorder.audioFilename)
            delegate?.didFinishRecording(self, duration: elapsed)
        } catch {
            delegate?.didFailToRecord(self, error: .fileWrite)
        }
        
    }

    @objc private func record() {
        if recorder.audioRecorder.isRecording {
            stopRecording(interrupted: false)
        } else {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            let progress = UIBezierPath(arcCenter: CGPoint(x: bounds.maxX / 2,
                                                           y: bounds.maxY / 2),
                                        radius: self.frame.width / 2 - 3,
                                        startAngle: .pi * 1.5,
                                        endAngle: -.pi * 0.5,
                                        clockwise: false)
            
            let addAnimation = {
                self.shapeLayer.path = progress.cgPath
                self.shapeLayer.strokeColor = RECORD_TINT.cgColor
                self.shapeLayer.lineWidth = 4
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
                    self.delegate?.didFailToRecord(self, error: .micAccess)
                    return
                }
                
                // Has mic access, continue to record
                
                self.finishTime = Date().addingTimeInterval(Double(self.duration))
                self.delegate?.didBeginRecording(self)
                
                addAnimation()
                
                self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
                    if (self.shapeLayer.animation(forKey: "drawCircleAnimation") == nil) { // User interrupted recording
                        timer.invalidate()
                        self.stopRecording(interrupted: true)
                        return;
                    } else if self.timeRemaining <= 0 {
                        timer.invalidate()
                        self.stopRecording(interrupted: false)
                        return
                    }
                    self.setTitle("Stop", for: .normal)
                }
                self.timer?.fire()
            }
        }
    }

}
