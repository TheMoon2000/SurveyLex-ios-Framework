//
//  AudioPage.swift
//  SurveyLex
//
//  Created by Jia Rui Shan on 2019/7/11.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

/// A view controller that displays an audio question page in a SurveyLex survey.
class AudioPage: UIViewController, SurveyPage, RecordingDelegate {

    // MARK: - Protocol requirements
    
    var fragmentData: Fragment!
    
    var surveyViewController: SurveyViewController?
    
    var completed: Bool {
        return audioQuestion.completed
    }
    
    var unlocked: Bool {
        return completed || !audioQuestion.isRequired
    }
    
    // Shortcut reference for the shared navigation menu
    var navigationMenu: FragmentMenu {
        return surveyViewController!.navigationMenu
    }
    
    /// An audio question allows swiping unless a recording is in progress.
    var fixScreen: Bool {
        return recordButton.isRecording
    }
    
    // MARK: - Custom instance variables
    
    // MARK: UI elements
    
    /// The container scroll view where every other UI element resides in.
    var canvas: UIScrollView!
    
    /// A pointer to the skip button located below the record button.
    var auxiliaryButton: UIButton!
    
    /// The title UI element the audio response question.
    private var titleLabel: UITextView!
    
    /// A pointer to the record button.
    var recordButton: RecordButton!
    
    /// the `UILabel` under the record button.
    var captionMessage: UILabel!
    
    /// A stack view that contains the caption message and the auxiliary button.
    var captionStackView: UIStackView!
    
    
    // MARK: Audio information
    
    /// The `Audio` instance which the current cell is presenting.
    var audioQuestion: Audio!
    
    /// Produces a formatted string that displays the time limit of the audio question.
    var timeLimitString: String {
        return "Time limit: \(Int(audioQuestion.duration))s"
    }
    
    /// The URL where the audio file will be saved.
    var saveURL: URL!
    
    /// A repeating timer instance that manages the countdown display while the user is recording.
    private var timer: Timer?
    
    /// A non-repeating timer instance that contains the code to clear an error message, firing after 3 seconds.
    private var resetCaptionDisplay: Timer?
    
    /// The ID of the most recently uploaded audio file, returned by the server.
    private var sampleId = ""
    
    /// The date attribute used when encoding the fragment response JSON data.
    private var recordedDate = Date()
    
    // MARK: Upload handling
    
    /// Whether the fragment data JSON is uploaded.
    private var uploadedFragmentData = false {
        didSet {
            fragmentData.uploaded = uploadedFragmentData && uploadedSample
        }
    }
    
    
    /// Whether the audio WAV file is uploaded.
    private var uploadedSample = false {
        didSet {
            fragmentData.uploaded = uploadedFragmentData && uploadedSample
        }
    }
    
    // MARK: - Other variables

    
    /// It is unfortunate that the bottom inset that works in one orientation doesn't work in another, so we must adjust the inset on orientation change.
    var bottomOffset: CGFloat {
        return UIDevice.current.orientation.isLandscape ? 0 : self.view.frame.height - self.view.safeAreaLayoutGuide.layoutFrame.maxY
    }
    
    // MARK: - UI setup
    
    /// Initialize an audio response cell.
    required init(audioQuestion: Audio) {
        super.init(nibName: nil, bundle: nil)
        
        self.audioQuestion = audioQuestion
        fragmentData = audioQuestion.fragment
        
        // Setup the path to save the audio file
        // First create intermediate folders
        try? FileManager.default.createDirectory(at: AUDIO_CACHE_DIR, withIntermediateDirectories: true, attributes: nil)
        
        saveURL = AUDIO_CACHE_DIR.appendingPathComponent(fragmentData.id + ".wav")
    }
    
    @objc func resignedActive(_ notification: Notification) {
        if recordButton.isRecording {
            recordButton.stopRecording()
            clearRecording()
            timer?.invalidate()
            let alert = UIAlertController(title: "Recording Interrupted!", message: "Please do not leave this app in the middle of a recording, as audio capture does not work in background mode.", preferredStyle: .alert)
            alert.view.tintColor = theme.dark
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            surveyViewController?.present(alert, animated: true, completion: nil)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Update the page number in the navigation bar. We need to minus 1 here because the `order` property indexes fragments and questions from 1 instead of 0.
        surveyViewController?.fragmentIndex = audioQuestion.order.fragment - 1
        
        
        // Update navigation menu display
        self.navigationMenu.nextButton.isEnabled = self.unlocked
        
        if !recordButton.isRecording {
            UIView.transition(with: navigationMenu,
                              duration: 0.3,
                              options: .curveEaseInOut,
                              animations: {
                                self.navigationMenu.alpha = 1.0
                                self.canvas.contentInset.bottom = self.navigationMenu.height + self.bottomOffset
                              },
                              completion: nil)
        }
        
        navigationMenu.enableUserInteractions(true)
        
        // Handle auto-start
        if audioQuestion.autoStart && !audioQuestion.visited {
            audioQuestion.visited = true
            recordButton.startRecording()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // Every time the user exits the audio question, an attempt to upload the current audio response is made.
        
        if surveyViewController!.survey.mode == .submission {
            uploadResponse()
        }
    }
    
    /// The method that is called by the auxiliary button.
    @objc private func auxiliaryAction() {
        if auxiliaryButton.title(for: .normal)! == "Skip" {
            
            // The response fragment data needs to be reuploaded because the user now chooses to skip the audio question.
            uploadedFragmentData = false
            
            audioQuestion.skipped = true
            
            // Flip the page.
            let _ = surveyViewController?.flipPageIfNeeded(allCompleted: false)
        
        } else {
            let roundedLength = round(recordButton.currentRecordingDuration * 10) / 10
            let alert = UIAlertController(title: "Clear recording?", message: "You are about to delete your previous recording (\(roundedLength) seconds). This cannot be undone.", preferredStyle: .actionSheet)
            alert.view.tintColor = theme.dark
            alert.addAction(UIAlertAction(title: "Clear", style: .destructive, handler: { alert in self.clearRecording() }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            surveyViewController?.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - View controller setup

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup resign active detection
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(resignedActive(_:)),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil)
        
        // UI
        view.backgroundColor = .white
        
        self.canvas = {
            let scrollView = UIScrollView()
            scrollView.showsHorizontalScrollIndicator = false
            scrollView.scrollIndicatorInsets.bottom = self.navigationMenu.height
            scrollView.contentInset.bottom = self.navigationMenu.height + bottomOffset
            scrollView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(scrollView)
            
            scrollView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
            scrollView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
                                    
            return scrollView
        }()
        
        self.titleLabel = {
            let label = UITextView()
            label.text = audioQuestion.prompt
            label.format(as: .title, theme: theme)
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            
            canvas.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor,
                                        constant: SIDE_PADDING).isActive = true
            label.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor,
                                         constant: -SIDE_PADDING).isActive = true
            label.topAnchor.constraint(equalTo: canvas.topAnchor,
                                       constant: 35).isActive = true
            // This constraint makes sure that the record button is always at the bottom even if the question prompt does not fill the top half of the screen.
            label.heightAnchor.constraint(greaterThanOrEqualTo: canvas.heightAnchor, constant: -280 - navigationMenu.height).isActive = true
            return label
        }()
        
        self.recordButton = {
            let recorder = Recorder(fileURL: saveURL)
            let button: RecordButton
            
            // Load from cache if possible
            if audioQuestion.recordButton != nil {
                button = audioQuestion.recordButton!
            } else {
                button = RecordButton(radius: 50,
                                      recorder: recorder,
                                      theme: theme)
                button.maxLength = audioQuestion.duration
                button.tintColor = self.theme.medium
                audioQuestion.recordButton = button
            }
            
            button.delegate = self
            canvas.addSubview(button)
            button.centerXAnchor.constraint(equalTo: canvas.centerXAnchor).isActive = true
            button.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 60).isActive = true
            
            return button
        }()

        self.auxiliaryButton = {
            let button = UIButton(type: .system)
            button.tintColor = theme.dark
            button.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
            if recordButton.hasSuccessfulRecording {
                button.setTitle("Clear Recording", for: .normal)
                button.isHidden = false
            } else if audioQuestion.isRequired {
                button.isHidden = true
            } else {
                button.setTitle("Skip", for: .normal)
                uploadedSample = true
            }
            button.translatesAutoresizingMaskIntoConstraints = false
            button.addTarget(self, action: #selector(auxiliaryAction), for: .touchUpInside)
            
            return button
        }()
        
        self.captionMessage = {
            let caption = UILabel()
            caption.textColor = UIColor(white: 0.35, alpha: 1)
            caption.font = .systemFont(ofSize: 16.5)
            caption.textAlignment = .center
            if recordButton.hasSuccessfulRecording {
                caption.isHidden = true
            } else {
                caption.text = timeLimitString
            }
            caption.translatesAutoresizingMaskIntoConstraints = false
            return caption
        }()
        
        captionStackView = {
            let stack = UIStackView(arrangedSubviews: [captionMessage, auxiliaryButton])
            stack.alignment = .center
            stack.axis = .horizontal
            stack.spacing = 10
            stack.translatesAutoresizingMaskIntoConstraints = false
            canvas.addSubview(stack)
            
            stack.centerXAnchor.constraint(equalTo: canvas.centerXAnchor).isActive = true
            stack.topAnchor.constraint(equalTo: recordButton.bottomAnchor, constant: 20).isActive = true
            stack.heightAnchor.constraint(equalToConstant: 40).isActive = true
            
            stack.bottomAnchor.constraint(equalTo: canvas.bottomAnchor, constant: -30).isActive = true
            
            return stack
        }()
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    // MARK: - Recording delegate
    
    func didFinishRecording(_ sender: RecordButton, duration: Double) {
        debugMessage("Recording with duration \(round(duration * 10) / 10)s saved to \(sender.saveURL).")
        
        // Stop the timer.
        timer?.invalidate()
        
        // Record the date of this most recent recording.
        recordedDate = Date()
        
        // Update the view to inform the user that this question is now completed.
        captionMessage.isHidden = false
        captionMessage.text = "Your audio response was captured."
        auxiliaryButton.isHidden = true
        self.auxiliaryButton.setTitle("Clear Recording", for: .normal)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.auxiliaryButton.isHidden = false
            self.captionMessage.isHidden = true
        }
        
        // This is the only place where the audio question's `completion` property is set to true.
        audioQuestion.completed = true

        // Unlock the next page of the survey.
        surveyViewController?.reloadDatasource()
        
        // A new audio sample was recorded, so it needs to be uploaded.
        uploadedSample = false
        
        // The fragment data needs to change too because the sampleId is different and so is the `skip` status.
        uploadedFragmentData = false
        
        // A new recording is created, so the question is not skipped.
        audioQuestion.skipped = false
        
        // The user can proceed to the next question.
        navigationMenu.nextButton.isEnabled = true
        
        resetNavigationMenu()
        
        // The user can now close the survey
        surveyViewController?.navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    /// Clear the current recording.
    func clearRecording() {
        audioQuestion.completed = false
        captionMessage.isHidden = false
        captionMessage.text = timeLimitString

        // The user can only see the skip button if this question is optional.
        auxiliaryButton.setTitle("Skip", for: .normal)
        auxiliaryButton.isHidden = audioQuestion.isRequired
        
        // The user can only flip to the next question (on the next page) if this current audio question is optional.
        navigationMenu.nextButton.isEnabled = !audioQuestion.isRequired

        recordButton.clearRecording()
        
        if !audioQuestion.isRequired {
            // An audio question can only be skipped if it's not required. At this moment, the question is left blank and isn't required, so we should treat the question as skipped.
            audioQuestion.skipped = true
        }
        
        // The user's response on the current question needs to be updated.
        uploadedFragmentData = false
        
        // Since there is no sample to upload, it doesn't require any additional upload task.
        uploadedSample = true
    }
    
    /// Displays the time remaining message once the recording starts.
    func didBeginRecording(_ sender: RecordButton) {
        
        let df = DateComponentsFormatter()
        df.allowedUnits = .second
        df.collapsesLargestUnit = false
        df.unitsStyle = .abbreviated
        df.zeroFormattingBehavior = .dropLeading
        
        timer?.invalidate()
        resetCaptionDisplay?.invalidate()
        
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
        
        // Prevent user from swiping to other pages during a recording.
        surveyViewController?.reloadDatasource()
        
        UIView.transition(
            with: view,
            duration: 0.2,
            options: .curveEaseInOut,
            animations: {
                self.navigationMenu.alpha = 0.0
                self.navigationMenu.isUserInteractionEnabled = false
                self.canvas.contentInset.bottom = 0
                self.canvas.scrollIndicatorInsets.bottom = 0
            },
            completion: nil
        )
        
        // Forbid the user from closing the survey while recording.
        surveyViewController?.navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    func didFailToRecord(_ sender: RecordButton, error: Recorder.Error) {
        timer?.invalidate()
        auxiliaryButton.isHidden = audioQuestion.isRequired
        
        captionMessage.isHidden = false
        captionMessage.text = timeLimitString
        
        // Update navigation menu next button.
        navigationMenu.nextButton.isEnabled = !audioQuestion.isRequired

        resetNavigationMenu()
        surveyViewController?.reloadDatasource()
        
        // The user can now close the survey
        surveyViewController?.navigationItem.rightBarButtonItem?.isEnabled = true
        
        switch error {
        case .tooShort:
            self.captionMessage.text = "Recording was too short!"
            auxiliaryButton.isHidden = true
            
            //  Update the progress bar in `SurveyViewController` to reflect that the current audio question is not (or no longer) completed
            audioQuestion.completed = false
            
            resetCaptionDisplay = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { timer in
                self.captionMessage.text = self.timeLimitString
                self.auxiliaryButton.isHidden = self.audioQuestion.isRequired
            }
        case .micAccess:
            let alert = UIAlertController(title: "No Mic Access",
                                          message: "Please enable microphone access in Settings.",
                                          preferredStyle: .alert)
            alert.view.tintColor = theme.dark
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            audioQuestion.parentView?.present(alert, animated: true, completion: nil)
        case .fileWrite:
            let alert = UIAlertController(title: "No Write Permission",
                                          message: "Internal error.",
                                          preferredStyle: .alert)
            alert.view.tintColor = theme.dark
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            audioQuestion.parentView?.present(alert, animated: true, completion: nil)
        }
    }
    
    private func resetNavigationMenu() {
        
        // The height of the visible frame of the canvas after the navigation menu shows up.
        let visibleCanvasHeight = canvas.safeAreaLayoutGuide.layoutFrame.height - navigationMenu.height
        
        let offsetHeight = min(
            navigationMenu.height,
            max(0, canvas.contentSize.height - visibleCanvasHeight)
        )
        
        // Adjust scroll view inset.
        UIView.transition(
            with: view,
            duration: 0.2,
            options: .curveEaseInOut,
            animations: {
                self.navigationMenu.alpha = 1.0
                self.navigationMenu.isUserInteractionEnabled = true
                self.canvas.contentInset.bottom = self.navigationMenu.height + self.bottomOffset
                self.canvas.scrollIndicatorInsets.bottom = self.navigationMenu.height
                self.canvas.contentOffset.y += offsetHeight
            },
            completion: nil
        )
    }
    
    // MARK: - Upload
    
    func uploadResponse() {
        
        fragmentData.needsReupload = false
        
        // If no changes were made (i.e. both the audio sample and the fragment response are unchanged), there is no need to re-upload anything.
        if fragmentData.uploaded { return }
        
        // If the user chooses to skip the question, then we only need to upload the fragment response to indicate this status. No file upload is needed.
        if audioQuestion.skipped {
            uploadFragmentData()
            return
        }
        
        // Otherwise, we first need to upload the audio sample, then get the sample ID back from the server and include it in the fragment response.
        guard let audioData = try? Data(contentsOf: saveURL) else {
            debugMessage("Audio file at \(saveURL.path) no longer exists! Terminating upload request...")
            return
        }
        
        let boundary = "----SurveyLex-Framework-Boundary-String"
        let prefix = "--\(boundary)\r\n"
        
        var sampleRequest = URLRequest(url: API_AUDIO_SAMPLE)
        sampleRequest.httpMethod = "POST"
        sampleRequest.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        
        // Begin building multipart data
        
        var body = Data()
        body.append(string: prefix)
        body.append(string: "Content-Disposition: form-data; name=\"sample\"; filename=\"temp-file.wav\"\r\n")
        body.append(string: "Content-Type: audio/wav\r\n\r\n")
        body.append(audioData)
        body.append(string: "\r\n")
        
        let parts: [(name: String, content: String)] = [
            ("length", String(recordButton.currentRecordingDuration)),
            ("surveyId", fragmentData.parent.surveyId),
            ("sessionId", fragmentData.parent.sessionID),
            ("responseId", fragmentData.responseId),
            ("createdDate", ISO8601DateFormatter().string(from: recordedDate))
        ]
        
        for part in parts {
            body.append(string: prefix)
            body.append(string: "Content-Disposition: form-data; name=\"\(part.name)\"\r\n\r\n")
            body.append(string: part.content + "\r\n")
        }
        
        body.append(string: "--\(boundary)--")
        
        // End building multipart data

        
        sampleRequest.httpBody = body
        
        let task = CUSTOM_SESSION.dataTask(with: sampleRequest) {
            data, response, error in
            
            guard error == nil else {
                debugMessage("Audio fragment (index=\(self.pageIndex)) upload failed with error: \(error!)")
                self.uploadFailed()
                return
            }
            
            if let sampleId = try? JSON(data: data!).dictionary?["sampleId"]?.string {
                self.uploadedSample = true
                self.sampleId = sampleId
                DispatchQueue.main.async {
                    self.uploadFragmentData(sampleId: sampleId)
                }
            } else {
                debugMessage("Cannot get 'sampleId' from the collector API! The collector API must have updated since this file was written.")
                self.uploadFailed()
            }
            
        }
        
        task.resume()
    }
    
    func uploadFragmentData(sampleId: String? = nil) {
        
        if uploadedFragmentData { return }
            
        var data: [String : Any] = ["skipped" : audioQuestion.skipped]
        if sampleId != nil {
            data["sampleId"] = sampleId!
        }
        
        var responseJSON = fragmentData.fragmentJSON
        responseJSON.dictionaryObject?["data"] = data
        
        var responseRequest = URLRequest(url: API_RESPONSE)
        responseRequest.httpMethod = "POST"
        responseRequest.httpBody = try? responseJSON.rawData()
        responseRequest.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        let task = CUSTOM_SESSION.dataTask(with: responseRequest) {
            data, response, error in
            
            guard error == nil else {
                self.uploadFailed()
                return
            }
            
            // The current response JSON has expired since a new audio file was recorded.
            if sampleId != nil && sampleId! != self.sampleId { return }
            
            if (try? JSON(data: data!).dictionary?["status"]?.int ?? 0) == 200 {
                // Successful.
                self.uploadedFragmentData = true
                self.uploadCompleted()
            } else {
                debugMessage("Server did not return status code 200 for audio fragment response!")
                self.uploadFailed()
            }
        }
        
        task.resume()
        
    }
    
    // MARK: -
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        if recordButton.isRecording { return }
        
        coordinator.animate(
            alongsideTransition: {context in
                self.canvas.contentInset.bottom = self.navigationMenu.height + self.bottomOffset
            },
            completion: nil)
    }

}
