//
//  RecordButton.swift
//  Voice Capture Utility
//
//  Created by Jia Rui Shan on 2019/5/6.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

/// A special subclass of `UIButton` that records audio.
class RecordButton: UIButton {
    
    var delegate: RecordingDelegate?
    
    internal var recorder: Recorder!
    internal var duration: CGFloat = 0
    private let shapeLayer = CAShapeLayer()
    private var finishTime = Date()
    private var isRecording = false
    
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
    
    init(duration: Double, radius: CGFloat, recorder: Recorder) {

        super.init(frame: .zero)
        
        // If the given duration is too short, bound it below by 10 seconds
        self.duration = max(CGFloat(duration), 10.0)
        self.recorder = recorder
        
        // Apply layout constraints
        self.widthAnchor.constraint(equalToConstant: radius * 2).isActive = true
        self.heightAnchor.constraint(equalToConstant: radius * 2).isActive = true
        
        // Layer appearance
        self.layer.cornerRadius = radius
        layer.masksToBounds = true
        self.clipsToBounds = true
        
        /*
        self.setTitle("Record", for: .normal)
        self.setTitleColor(.gray, for: .normal)
        self.titleLabel?.font = .systemFont(ofSize: 17)
         */
        
        self.backgroundColor = BLUE_TINT
        self.setImage(#imageLiteral(resourceName: "mic"), for: .normal)
        self.setImage(#imageLiteral(resourceName: "mic"), for: .highlighted)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.addTarget(self,
                       action: #selector(record),
                       for: .touchUpInside)
        
        self.addTarget(self,
                       action: #selector(buttonPressed),
                       for: .touchDown)
        
        self.addTarget(self,
                       action: #selector(buttonLifted),
                       for: [.touchUpOutside, .touchDragOutside, .touchDragExit, .touchCancel])
        
        self.setNeedsDisplay()
    }
    
    @objc private func buttonPressed() {
        self.backgroundColor = isRecording ? RECORDING_PRESSED : DARKER_TINT
    }
    
    @objc private func buttonLifted() {
        let animation = {
            self.backgroundColor = self.isRecording ? RECORDING_PRESSED : BLUE_TINT
        }
        
        UIView.transition(with: self,
                          duration: 0.2,
                          options: .transitionCrossDissolve,
                          animations: animation,
                          completion: nil)
    }
    
    private func stopRecording(interrupted: Bool) {
        
        recorder.stopRecording() // Saves the file if possible
        isRecording = false
        shapeLayer.removeAllAnimations()
        shapeLayer.removeFromSuperlayer()
        timer?.invalidate()
        self.setImage(#imageLiteral(resourceName: "mic"), for: .normal)
        self.setImage(#imageLiteral(resourceName: "mic"), for: .highlighted)
        
        UIView.transition(with: self,
                          duration: 0.2,
                          options: .curveEaseInOut,
                          animations: {
                            self.layer.cornerRadius = self.frame.width / 2
                            self.backgroundColor = BLUE_TINT
                            },
                          completion: nil)
        
        
        if interrupted {
            delegate?.didFailToRecord(self, error: .interrupted)
            return
        }
        
        let elapsed = Double(duration) - finishTime.timeIntervalSinceNow

        do {
            let _ = try Data(contentsOf: recorder.audioFilename)
        } catch {
            delegate?.didFailToRecord(self, error: .fileWrite)
        }
        
        delegate?.didFinishRecording(self, duration: elapsed)
    }

    @objc private func record() {
        if recorder.audioRecorder.isRecording {
            stopRecording(interrupted: false)
        } else {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            
            recorder.startRecording { status in
                
                // No access, gives alert message
                if !status {
                    self.delegate?.didFailToRecord(self, error: .micAccess)
                    return
                }
                
                // Has mic access, continue to record
                
                self.finishTime = Date().addingTimeInterval(Double(self.duration))
                self.delegate?.didBeginRecording(self)
                
                let animation = {
                    self.layer.cornerRadius = 8
                    self.backgroundColor = RECORDING
                }
                
                UIView.transition(with: self,
                                  duration: 0.2,
                                  options: .curveEaseInOut,
                                  animations: animation,
                                  completion: nil)
                
                self.isRecording = true
                
                self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
                    if false { // User interrupted recording
                        timer.invalidate()
                        self.stopRecording(interrupted: true)
                        return;
                    } else if self.timeRemaining <= 0 {
                        timer.invalidate()
                        self.stopRecording(interrupted: false)
                        return
                    }
                    self.setImage(#imageLiteral(resourceName: "stop"), for: .normal)
                    self.setImage(#imageLiteral(resourceName: "stop"), for: .highlighted)
                }
                self.timer?.fire()
            }
        }
    }
    
    func startRecording() {
        record()
    }

}
