//
//  ViewController.swift
//  Voice Capture Utility
//
//  Created by Jia Rui Shan on 2019/5/6.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class RecordViewController: UIViewController {
    
    private var button: RecordButton!
    private var segmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Tab bar setup
        title = "Record Demo"
        
        // View setup
        button = makeButton()
        segmentedControl = makeSegmentedControl()
    }
    
    private func makeButton() -> RecordButton {
        let button = RecordButton(duration: 15, saveName: "recording.m4a", radius: 75)
        button.tintColor = BUTTON_TINT
        view.addSubview(button)
        button.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        button.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: -30).isActive = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(recordingError), name: NSNotification.Name(rawValue: "No mic permission"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didStartRecording(_:)), name: NSNotification.Name(rawValue: "Started recording"), object: button)
        NotificationCenter.default.addObserver(self, selector: #selector(didStopRecording(_:)), name: NSNotification.Name(rawValue: "Stopped recording"), object: button)
        
        return button
    }
    
    private func makeSegmentedControl() -> UISegmentedControl {
        let control = UISegmentedControl(items: ["15", "30", "60"])
        control.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(control)
        control.tintColor = BUTTON_DEEP_BLUE
        control.selectedSegmentIndex = 0
        
        control.widthAnchor.constraint(equalToConstant: 180).isActive = true
        control.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        control.topAnchor.constraint(equalTo: self.button.bottomAnchor, constant: 25).isActive = true
        control.addTarget(self, action: #selector(changeDuration(_:)), for: .valueChanged)
        
        return control
    }
    
    @objc private func changeDuration(_ sender: UISegmentedControl) {
        button.duration = CGFloat(Int(sender.titleForSegment(at: sender.selectedSegmentIndex)!)!)
    }
    
    @objc private func didStartRecording(_ sender: RecordButton) {
        segmentedControl.isEnabled = false
    }
    
    @objc private func didStopRecording(_ sendder: RecordButton) {
        segmentedControl.isEnabled = true
    }
    
    @objc internal func recordingError(_ sender: RecordButton) {
        let alert = UIAlertController(title: "No Mic Access",
                                      message: "Please enable microphone access in Settings",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        button.stopRecording()
    }

    
}

