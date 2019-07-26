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
    
    var recorder: Recorder!
    var maxLength = 60.0
    var isRecording = false
    private var finishTime = Date()
    
    /// The length of most recent recording.
    var currentRecordingDuration = 0.0
    
    var hasSuccessfulRecording: Bool {
        return currentRecordingDuration > 0
    }
    
    /// When recording, represents the number of seconds left
    var timeRemaining: TimeInterval {
        return finishTime.timeIntervalSinceNow
    }
    
    /// A timer instance used for displaying the time remaining countdown while recording.
    private var timer: Timer?
    
    var saveURL: URL {
        return recorder!.audioFilename
    }
    
    override var buttonType: UIButton.ButtonType {
        return .custom
    }
    
    init(duration: Double, radius: CGFloat, recorder: Recorder) {

        super.init(frame: .zero)
        
        // If the given duration is too short, bound it below by 10 seconds
        self.maxLength = max(duration, MIN_MAX_RECORDING_LENGTH)
        self.recorder = recorder
        self.recorder.resetPlaybackHandler = { [weak self] status in
            self?.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            self?.setImage(#imageLiteral(resourceName: "play"), for: .highlighted)
        }
        
        // Apply layout constraints
        self.widthAnchor.constraint(equalToConstant: radius * 2).isActive = true
        self.heightAnchor.constraint(equalToConstant: radius * 2).isActive = true
        
        // Layer appearance
        self.layer.cornerRadius = radius
        layer.masksToBounds = true
        self.clipsToBounds = true
        
        self.backgroundColor = BLUE_TINT
        self.setImage(#imageLiteral(resourceName: "mic"), for: .normal)
        self.setImage(#imageLiteral(resourceName: "mic"), for: .highlighted)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.addTarget(self,
                       action: #selector(buttonTriggered),
                       for: .touchUpInside)
        
        self.addTarget(self,
                       action: #selector(buttonPressed),
                       for: .touchDown)
        
        self.addTarget(self,
                       action: #selector(buttonLifted),
                       for: [.touchUpInside, .touchUpOutside, .touchDragOutside, .touchDragExit, .touchCancel])
        
        self.setNeedsDisplay()
    }
    
    @objc private func buttonPressed() {
        self.backgroundColor = isRecording ? RECORDING_PRESSED : DARKER_TINT
    }
    
    @objc private func buttonLifted() {
        let animation = {
            self.backgroundColor = self.isRecording ? RECORDING : BLUE_TINT
        }
        
        UIView.transition(with: self,
                          duration: 0.2,
                          options: .transitionCrossDissolve,
                          animations: animation,
                          completion: nil)
    }
    
    @objc private func buttonTriggered() {
        if recorder.audioRecorder.isRecording {
            stopRecording()
        } else if !hasSuccessfulRecording {
            startRecording()
        } else if (recorder.audioPlayer?.isPlaying ?? false) {
            // Already playing back the recording, so stop it.
            recorder.stopPlayingCapture()
        } else {
            // Playback the recording
            if recorder.playCapture() {
                setImage(#imageLiteral(resourceName: "pause"), for: .normal)
                setImage(#imageLiteral(resourceName: "pause"), for: .highlighted)
            }
        }
    }
    
    func startRecording() {
        
        recorder.startRecording { status in
            
            // No access, gives alert message
            if !status {
                self.delegate?.didFailToRecord(self, error: .micAccess)
                return
            }
            
            // Has mic access, continue to record
            
            self.finishTime = Date().addingTimeInterval(self.maxLength)
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
            
            self.setImage(#imageLiteral(resourceName: "stop"), for: .normal)
            self.setImage(#imageLiteral(resourceName: "stop"), for: .highlighted)
            
            self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
                if self.timeRemaining <= 0 {
                    timer.invalidate()
                    self.stopRecording()
                    return
                }
            }
            self.timer?.fire()
        }
    }
    
    func stopRecording() {
        
        UISelectionFeedbackGenerator().selectionChanged()

        recorder.stopRecording() // Saves the file if possible
        isRecording = false
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
        
        let elapsed = Double(maxLength) - finishTime.timeIntervalSinceNow
        
        
        // Error type 1: The recording was too short
        if elapsed < MIN_RECORDING_LENGTH {
            delegate?.didFailToRecord(self, error: .tooShort)
            return
        }
        
        // Error type 2: The audio was wasn't saved.
        do {
            let _ = try Data(contentsOf: recorder.audioFilename)
        } catch {
            delegate?.didFailToRecord(self, error: .fileWrite)
            return
        }
        
        // The recording is successful.
        currentRecordingDuration = elapsed
        self.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        self.setImage(#imageLiteral(resourceName: "play"), for: .highlighted)
        
        // No error occurred, call delegate to handle finished recording.
        delegate?.didFinishRecording(self, duration: elapsed)
    }

    func clearRecording() {
        setImage(#imageLiteral(resourceName: "mic"), for: .normal)
        setImage(#imageLiteral(resourceName: "mic"), for: .highlighted)
        currentRecordingDuration = 0.0
        try? FileManager.default.removeItem(at: saveURL)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
