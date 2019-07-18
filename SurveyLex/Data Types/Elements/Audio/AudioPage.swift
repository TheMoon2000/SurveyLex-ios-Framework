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
    
    var uploaded: Bool {
        return uploadedFragmentData && uploadedSample
    }
    
    // MARK: Custom instance variables
    
    /// A pointer to the skip button located below the record button.
    var auxiliaryButton: UIButton!
    
    /// The `Audio` instance which the current cell is presenting.
    var audioQuestion: Audio!
    
    /// A pointer to the record button.
    var recordButton: RecordButton!
    
    /// the `UILabel` under the record button.
    var captionMessage: UILabel!
    
    /// The title UI element the audio response question.
    private var titleLabel: UITextView!
    
    /// The sample ID for the recording.
    private var sampleId = UUID().uuidString.lowercased()
    
    /// Produces a formatted string that displays the time limit of the audio question.
    var timeLimitString: String {
        return "Time limit: \(Int(audioQuestion.duration))s"
    }
    
    /// The URL where the audio file will be saved.
    var saveURL: URL!
    
    /// A repeating timer instance that manages the countdown display while the user is recording.
    private var timer: Timer?
    
    /// A non-repeating timer instance that contains the code to display an error message, firing after 3 seconds.
    private var displayErrorMessage: Timer?
    
    /// Whether the fragment data JSON is uploaded.
    var uploadedFragmentData = false
    
    /// Whether the audio WAV file is uploaded.
    var uploadedSample = false
    
    // MARK: UI setup
    
    /// Initialize an audio response cell.
    required init(audioQuestion: Audio) {
        super.init(nibName: nil, bundle: nil)
        view.backgroundColor = .white
        
        // Setup the path to save the audio file
        saveURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent("SurveyLex", isDirectory: true)
        
        try? FileManager.default.createDirectory(at: saveURL, withIntermediateDirectories: true, attributes: nil)
        
        saveURL.appendPathComponent(sampleId + ".wav")
        
        self.audioQuestion = audioQuestion // must be set first
        self.titleLabel = makeTitle()
        self.recordButton = makeRecordButton()
        self.auxiliaryButton = makeAuxiliaryButton()
        self.captionMessage = {
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
            caption.centerYAnchor.constraint(equalTo: auxiliaryButton.centerYAnchor).isActive = true
            
            return caption
        }()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        surveyViewController?.fragmentIndex += 1
        
        if audioQuestion.autoStart && !completed {
            recordButton.startRecording()
        }
    }
    
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
    
    private func makeAuxiliaryButton() -> UIButton {
        let button = UIButton(type: .system)
        button.tintColor = BUTTON_DEEP_BLUE
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        if audioQuestion.isRequired {
            button.isHidden = true
        } else {
            button.setTitle("Skip", for: .normal)
        }
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        button.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        button.topAnchor.constraint(equalTo: recordButton.bottomAnchor,
                                    constant: 20).isActive = true
        button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                       constant: -25).isActive = true
        
        button.addTarget(self, action: #selector(auxiliaryAction), for: .touchUpInside)
        
        return button
    }
    
    @objc private func auxiliaryAction() {
        if auxiliaryButton.title(for: .normal) == "Skip" {
            let _ = audioQuestion.parentView?.flipPageIfNeeded(allCompleted: false)
        } else {
            clearRecording()
        }
    }
    
    // MARK: Recording delegate
    
    func didFinishRecording(_ sender: RecordButton, duration: Double) {
        print("Recording with duration \(round(duration * 10) / 10)s saved to \(sender.saveURL).")
        timer?.invalidate()
        
        auxiliaryButton.setTitle("Clear Recording", for: .normal)
        auxiliaryButton.isHidden = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.auxiliaryButton.isHidden = false
            self.captionMessage.text = ""
        }

        captionMessage.text = "Your audio response was captured."
        
        // This is the only place where the audio question's `completion` property is set to true.
        audioQuestion.completed = true

        // Unlock the next page of the survey.
        audioQuestion.parentView?.reloadDatasource()
    }
    
    /// Clear the current recording.
    func clearRecording() {
        audioQuestion.completed = false
        if audioQuestion.isRequired {
            captionMessage.text = timeLimitString
            auxiliaryButton.isHidden = true
        } else {
            captionMessage.text = ""
            auxiliaryButton.setTitle("Skip", for: .normal)
            auxiliaryButton.isHidden = false
        }
        recordButton.clearRecording()
    }
    
    /// Displays the time remaining message once the recording starts.
    func didBeginRecording(_ sender: RecordButton) {
        let df = DateComponentsFormatter()
        df.allowedUnits = .second
        df.collapsesLargestUnit = false
        df.unitsStyle = .abbreviated
        df.zeroFormattingBehavior = .dropLeading
        timer?.invalidate()
        displayErrorMessage?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            let timeRemaining = ceil(self.recordButton.timeRemaining)
            if timeRemaining <= 0 {
                timer.invalidate()
            } else {
                self.captionMessage.text = df.string(from: timeRemaining)
            }
        }
        timer!.fire() // start the countdown
        auxiliaryButton.isHidden = true // The countdown text replaces the skip button

        
        // Update completion status
        audioQuestion.completed = false
    }
    
    func didFailToRecord(_ sender: RecordButton, error: Recorder.Error) {
        timer?.invalidate()
        auxiliaryButton.isHidden = audioQuestion.isRequired
        if audioQuestion.isRequired {
            captionMessage.text = timeLimitString
        } else {
            captionMessage.text = ""
        }
        
        switch error {
        case .tooShort:
            self.captionMessage.text = "Recording was too short!"
            
            // Update the progress bar in `SurveyViewController` to reflect that the current audio question is not (or no longer) completed
            audioQuestion.completed = false
            
            displayErrorMessage = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { timer in
                if self.audioQuestion.isRequired {
                    self.captionMessage.text = self.timeLimitString
                    self.auxiliaryButton.isHidden = true
                } else {
                    self.captionMessage.text = ""
                    self.auxiliaryButton.isHidden = false
                }
            }
        case .micAccess:
            let alert = UIAlertController(title: "No Mic Access",
                                          message: "Please enable microphone access in Settings.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            audioQuestion.parentView?.present(alert, animated: true, completion: nil)
        case .fileWrite:
            let alert = UIAlertController(title: "No Write Permission",
                                          message: "Internal error.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            audioQuestion.parentView?.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: Upload
    
    func uploadResponse(_ completion: ((Bool) -> ())?) {
        
        if !uploadedFragmentData {
            var responseRequest = URLRequest(url: API_RESPONSE)
            responseRequest.httpMethod = "POST"
            responseRequest.httpBody = try? fragmentData.fragmentJSON.rawData()
            responseRequest.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            
            let responseTask = CUSTOM_SESSION.dataTask(with: responseRequest) {
                data, response, error in
                
                guard error == nil else {
                    print(error!)
                    completion?(false)
                    return
                }
                
                if let msg = String(data: data!, encoding: .utf8) {
                    print(msg)
                    self.uploadedFragmentData = true
                }
            }
            
            responseTask.resume()
        }
        
        if !uploadedSample {
            var sampleRequest = URLRequest(url: API_AUDIO_SAMPLE)
            sampleRequest.httpMethod = "POST"
            sampleRequest.httpBody = try? Data(contentsOf: recordButton.saveURL)
            
        
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
