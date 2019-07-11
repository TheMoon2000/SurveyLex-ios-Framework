//
//  AudioPage.swift
//  SurveyLex
//
//  Created by Jia Rui Shan on 2019/7/11.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class AudioPage: UIViewController, SurveyPage, RecordingDelegate {

    // MARK: Protocol requirements
    
    var fragmentData: Fragment!
    
    var surveyViewController: SurveyViewController?
    
    var completed: Bool {
        return audioQuestion.completed
    }
    
    var unlocked: Bool {
        return completed || !audioQuestion.isRequired
    }
    
    // MARK: Custom instance variables
    
    /// A pointer to the skip button located below the record button.
    var skipButton: UIButton!
    
    /// The `Audio` instance which the current cell is presenting.
    var audioQuestion: Audio!
    
    /// A pointer to the record button.
    var recordButton: RecordButton!
    
    /// the `UILabel` under the record button.
    var finishMessage: UILabel!
    
    /// The title UI element the audio response question.
    private var titleLabel: UITextView!
    
    /// The URL where the audio file will be saved.
    var saveURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("tmp.m4a") {
        didSet {
            recordButton.recorder = Recorder(fileURL: saveURL)
        }
    }
    
    // MARK: UI setup
    
    /// Initialize an audio response cell.
    required init(audioQuestion: Audio) {
        super.init(nibName: nil, bundle: nil)
        view.backgroundColor = .white
        
        self.audioQuestion = audioQuestion // must be set first
        self.titleLabel = makeTitle()
        self.recordButton = makeRecordButton()
        self.skipButton = makeSkipButton()
        self.finishMessage = makeFinishMessage()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        print("audio question appeared")
        
        surveyViewController?.fragmentIndex += 1
        
        if audioQuestion.autoStart && !completed {
            recordButton.startRecording()
        }
    }
    
    /// UI setup (1).
    private func makeTitle() -> UITextView {
        let label = UITextView()
        label.text = audioQuestion.prompt
        label.format(as: .title)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        label.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor,
                                    constant: SIDE_PADDING).isActive = true
        label.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor,
                                     constant: -SIDE_PADDING).isActive = true
        label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                   constant: 35).isActive = true
        return label
    }
    
    /// UI setup (2).
    private func makeRecordButton() -> RecordButton {
        let recorder = Recorder(fileURL: saveURL)
        let button = RecordButton(duration: audioQuestion!.duration,
                                  radius: 50,
                                  recorder: recorder)
        button.tintColor = BUTTON_TINT
        button.delegate = self
        view.addSubview(button)
        button.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        return button
    }
    
    /// UI setup (3).
    private func makeSkipButton() -> UIButton {
        let skip = UIButton(type: .system)
        skip.tintColor = BUTTON_DEEP_BLUE
        skip.titleLabel?.font = .systemFont(ofSize: 16.8, weight: .medium)
        skip.setTitle("Skip", for: .normal)
        skip.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(skip)
        skip.widthAnchor.constraint(equalTo: recordButton.widthAnchor,
                                    constant: -5).isActive = true
        skip.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        skip.topAnchor.constraint(equalTo: recordButton.bottomAnchor,
                                  constant: 20).isActive = true
        skip.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                     constant: -20).isActive = true
        skip.isHidden = audioQuestion.isRequired
        skip.addTarget(self, action: #selector(flip), for: .touchUpInside)
        
        return skip
    }
    
    @objc private func flip() {
        let _ = audioQuestion.parentView?.flipPageIfNeeded(allCompleted: false)
    }
    
    /// UI setup (4).
    private func makeFinishMessage() -> UILabel {
        let caption = UILabel()
        caption.textColor = UIColor(white: 0.35, alpha: 1)
        caption.font = .systemFont(ofSize: 16.5)
        caption.textAlignment = .center
        if audioQuestion.isRequired {
            caption.text = timeLimitString
        }
        caption.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(caption)
        
        caption.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        caption.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor,
                                       constant: -20).isActive = true
        caption.centerYAnchor.constraint(equalTo: skipButton.centerYAnchor).isActive = true
        
        return caption
    }
    
    /// Produces a formatted string that displays the time limit of the audio question.
    var timeLimitString: String {
        return "Time limit: \(Int(audioQuestion.duration))s"
    }
    
    // MARK: Recording delegate
    
    /// Because we reset `finishMessage.text` after a two-second delay, we need to make sure that we abort the process if the user has started to record again. If set to `true`, it means that we do not reset `finishMessage.text` to "Recording was too short" after the 2 seconds are over.
    var shouldCancelCaptionReset = false
    
    func didFinishRecording(_ sender: RecordButton, duration: Double) {
        print("Recording with duration \(round(duration * 10) / 10)s saved to \(sender.saveURL).")
        timer?.invalidate()
        if duration >= min(7.0, Double(sender.duration)) {
            
            // We treat duration ≥ 7 arbitrarily as a successful recording.
            
            skipButton.isHidden = true
            finishMessage.text = "Your audio response was captured."
            
            // This is the only place where the audio question's `completion` property is set to true.
            audioQuestion.completed = true
            
            // Flip the page if the next page exists.
            // audioQuestion.parentView?.flipPageIfNeeded()
            
        } else if duration >= 2 {
            
            // If the user records something between 2 and 7 seconds
            
            self.finishMessage.text = "Recording was too short!"
            
            // Update the progress bar in `SurveyViewController` to reflect that the current audio question is not (or no longer) completed
            audioQuestion.completed = false
            
            // Default to false, which means that we do reset the caption
            shouldCancelCaptionReset = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                if !self.shouldCancelCaptionReset {
                    if self.audioQuestion.isRequired {
                        self.finishMessage.text = self.timeLimitString
                        self.skipButton.isHidden = true
                    } else {
                        self.finishMessage.text = ""
                        self.skipButton.isHidden = false
                    }
                }
            }
        } else {
            
            // Called when the duration is shorter than 2 seconds
            audioQuestion.completed = false
            if audioQuestion.isRequired {
                finishMessage.text = timeLimitString
                skipButton.isHidden = true
            } else {
                finishMessage.text = ""
                skipButton.isHidden = false
            }
        }
        
        audioQuestion.parentView?.reloadDatasource()
    }
    
    /// A local instance variable that manages the countdown timer
    private var timer: Timer?
    
    func didBeginRecording(_ sender: RecordButton) {
        let df = DateComponentsFormatter()
        df.allowedUnits = [.minute, .second]
        df.collapsesLargestUnit = false
        df.unitsStyle = .abbreviated
        df.zeroFormattingBehavior = .dropLeading
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            let timeRemaining = ceil(self.recordButton.timeRemaining)
            if timeRemaining <= 0 {
                timer.invalidate()
            } else {
                self.finishMessage.text = df.string(from: timeRemaining)
            }
        }
        timer!.fire() // start the countdown
        skipButton.isHidden = true // The countdown text replaces the skip button
        
        // Since we restarted recording, the previous 2-second delayed reset should be invalidated.
        shouldCancelCaptionReset = true
        
        // Update completion status
        audioQuestion.completed = false
    }
    
    /// Error handling is implemented in Audio.swift, so we reset the UI and then delegate the error to the Audio instance for more actions
    func didFailToRecord(_ sender: RecordButton, error: Recorder.Error) {
        timer?.invalidate()
        skipButton.isHidden = audioQuestion.isRequired
        if audioQuestion.isRequired {
            finishMessage.text = timeLimitString
        } else {
            finishMessage.text = ""
        }
        audioQuestion.didFailToRecord(sender, error: error)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
