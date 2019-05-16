//
//  AudioResponseCell.swift
//  SurveyLex
//
//  Created by Jia Rui Shan on 2019/5/15.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class AudioResponseCell: UITableViewCell, RecordingDelegate {
    var skipButton: UIButton!
    var audioQuestion: Audio!
    var recordButton: RecordButton!
    var finishMessage: UILabel!
    private var titleLabel: UILabel!
    
    var title = "Audio question" {
        didSet {
            titleLabel.attributedText = TextFormatter.formatted(title, type: .title)
        }
    }
    var saveURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("tmp.m4a") {
        didSet {
            recordButton.recorder = Recorder(fileURL: saveURL)
        }
    }
    
    /// Initialize a audio response table cell view
    required init(audioQuestion: Audio) {
        super.init(style: .default, reuseIdentifier: nil)
        self.backgroundColor = .white

        self.audioQuestion = audioQuestion // must be set first
        self.titleLabel = makeLabel()
        self.recordButton = makeRecordButton()
        self.skipButton = makeSkipButton()
        self.finishMessage = makeFinishMessage()
        
        // 60 is the constant height of the navigation bar & status bar
        self.heightAnchor.constraint(greaterThanOrEqualToConstant: UIScreen.main.bounds.height - 60 - UIApplication.shared.keyWindow!.safeAreaInsets.bottom).isActive = true
    }
    
    
    private func makeLabel() -> UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .medium)
        label.text = "[Replace me]"
        label.numberOfLines = 100
        label.adjustsFontSizeToFitWidth = true
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        label.leftAnchor.constraint(equalTo: leftAnchor,
                                    constant: 30).isActive = true
        label.rightAnchor.constraint(equalTo: rightAnchor,
                                     constant: -30).isActive = true
        label.topAnchor.constraint(equalTo: topAnchor,
                                   constant: 40).isActive = true
        return label
    }
    
    private func makeRecordButton() -> RecordButton {
        let recorder = Recorder(fileURL: saveURL)
        let button = RecordButton(duration: audioQuestion!.duration,
                                  radius: 55,
                                  recorder: recorder)
        button.tintColor = BUTTON_TINT
        button.delegate = self
        self.addSubview(button)
        button.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        button.topAnchor.constraint(greaterThanOrEqualTo: titleLabel.bottomAnchor, constant: 120).isActive = true
        return button
    }
    
    private func makeSkipButton() -> UIButton {
        let skip = UIButton(type: .system)
        skip.tintColor = BUTTON_DEEP_BLUE
        skip.titleLabel?.font = .systemFont(ofSize: 16.8, weight: .medium)
        skip.setTitle("Skip", for: .normal)
        skip.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(skip)
        skip.widthAnchor.constraint(equalTo: recordButton.widthAnchor,
                                    constant: -5).isActive = true
        skip.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        skip.topAnchor.constraint(equalTo: recordButton.bottomAnchor,
                                  constant: 20).isActive = true
        skip.bottomAnchor.constraint(equalTo: bottomAnchor,
                                     constant: -45).isActive = true
        skip.isHidden = audioQuestion.isRequired
        skip.addTarget(audioQuestion, action: #selector(audioQuestion.flipPage), for: .touchUpInside)
        
        return skip
    }
    
    private func makeFinishMessage() -> UILabel {
        let caption = UILabel()
        caption.textColor = UIColor(white: 0.35, alpha: 1)
        caption.font = .systemFont(ofSize: 16.5)
        caption.textAlignment = .center
        if audioQuestion.isRequired {
            caption.text = timeLimitString
        }
        caption.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(caption)
        
        caption.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        caption.rightAnchor.constraint(equalTo: rightAnchor,
                                       constant: -20).isActive = true
        caption.centerYAnchor.constraint(equalTo: skipButton.centerYAnchor).isActive = true
        
        return caption
    }
    
    var timeLimitString: String {
        return "Time limit: \(Int(audioQuestion.duration))s"
    }

    // Delegate methods for recorder
    
    var shouldCancelCaptionReset = false
    
    func didFinishRecording(_ sender: RecordButton, duration: Double) {
        print("Recording with duration \(round(duration * 10) / 10)s saved to \(sender.saveURL).")
        timer?.invalidate()
        recordButton.setTitle("Record", for: .normal)
        if duration >= min(7.0, Double(sender.duration)) {
            skipButton.isHidden = true
            finishMessage.text = "Your audio response was captured."
            audioQuestion.completed = true
            audioQuestion.parentView?.nextPage()
            recordButton.setTitle("Again", for: .normal)
        } else if duration >= 1.5 {
            self.finishMessage.text = "Recording was too short!"
            recordButton.setTitle("Record", for: .normal)
            audioQuestion.completed = false
            audioQuestion.parentView?.updateCompletionRate(false)
            shouldCancelCaptionReset = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                if !self.shouldCancelCaptionReset {
                    self.skipButton.isHidden = self.audioQuestion.isRequired
                    if self.audioQuestion.isRequired {
                        self.finishMessage.text = "Time limit: \(self.timeLimitString)s"
                    }
                    self.finishMessage.text = ""
                }
            }
        } else {
            recordButton.setTitle("Record", for: .normal)
            audioQuestion.completed = false
            audioQuestion.parentView?.updateCompletionRate(false)
            skipButton.isHidden = audioQuestion.isRequired
            finishMessage.text = ""
            if audioQuestion.isRequired {
                finishMessage.text = "Time limit: \(timeLimitString))s"
            }
        }
    }
    
    var timer: Timer?
    
    func didBeginRecording(_ sender: RecordButton) {
        let df = DateComponentsFormatter()
        df.allowedUnits = [.minute, .second]
        df.collapsesLargestUnit = false
        df.unitsStyle = .abbreviated
        df.zeroFormattingBehavior = .dropLeading
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            let timeRemaining = ceil(self.recordButton.timeRemaining)
            if timeRemaining <= 0 {
                timer.invalidate()
            } else {
                self.finishMessage.text = df.string(from: timeRemaining)
            }
        }
        timer!.fire()
        skipButton.isHidden = true
        shouldCancelCaptionReset = true
    }
    
    /// Error handling is implemented in Audio.swift, so we delegate the error to it
    func didFailToRecord(_ sender: RecordButton, error: Recorder.Error) {
        audioQuestion.didFailToRecord(sender, error: error)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
