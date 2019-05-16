//
//  Audio.swift
//  SurveyLex
//
//  Created by Jia Rui Shan on 2019/5/10.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

class Audio: Question, CustomStringConvertible {
    
    let prompt: String
    let fragment: Fragment
    var isRequired = true
    var completed = false
    var duration = 30.0 // Length of the audio response
    var fragmentId = "default"
    var parentView: SurveyViewController?
    private var lengthOfMostRecentRecording = 0.0
    
    required init(json: JSON, fragment: Fragment) {
        let dictionary = json.dictionaryValue
        
        guard let prompt = dictionary["prompt"]?.string else {
            print(json)
            preconditionFailure("Malformed text question")
        }
        
        if let isRequired = dictionary["isRequired"]?.boolValue {
            self.isRequired = isRequired
        }
        
        self.prompt = prompt
        self.fragment = fragment
    }
    
    var type: ResponseType {
        return .audio
    }
    
    var description: String {
        return "Audio question: <\(prompt)>"
    }
    
    func makeContentCell() -> UITableViewCell {
        let cell = AudioResponseCell(audioQuestion: self)
        cell.title = prompt
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("Recordings", isDirectory: true)
        
        do {
            try FileManager().createDirectory(at: url,
                                              withIntermediateDirectories: true,
                                              attributes: nil)
        } catch {
            preconditionFailure("No write permission to write audio.")
        }
        
        cell.saveURL = url.appendingPathComponent(fragmentId /* + ".m4a" */)
        
        
        return cell
    }
    
    // Cell actions
    
    func didBeginRecording(_ sender: RecordButton) {
        print("begin recording")
    }
    
    func didFailToRecord(_ sender: RecordButton, error: Recorder.Error) {
        switch error {
        case .micAccess:
            let alert = UIAlertController(title: "No Mic Access",
                                          message: "Please enable microphone access in Settings.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            parentView?.present(alert, animated: true, completion: nil)
        case .fileWrite:
            let alert = UIAlertController(title: "No Write Permission",
                                          message: "Internal error.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            parentView?.present(alert, animated: true, completion: nil)
        case .interrupted:
            let alert = UIAlertController(title: "Recording Interrupted",
                                          message: "Please do not close close or leave this screen while recording.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Try Again", style: .default, handler: nil))
            parentView?.present(alert, animated: true, completion: nil)
        }
    }
    
    
    @objc func flipPage() {
        parentView?.nextPage()
    }
    
}
