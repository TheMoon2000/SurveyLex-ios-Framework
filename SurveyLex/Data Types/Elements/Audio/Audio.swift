//
//  Audio.swift
//  SurveyLex
//
//  Created by Jia Rui Shan on 2019/5/10.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

/// Represents the information for an audio question in a SurveyLex survey. One single audio response takes up an entire `Fragment`.
class Audio: Question, CustomStringConvertible {
    
    // MARK: Protocol requirements
    
    var fragment: Fragment?
    var isRequired = false
    var completed = false
    var parentView: SurveyViewController?
    var order: (fragment: Int, question: Int)
    
    var type: ResponseType {
        return .audio
    }
    
    var description: String {
        return "Audio question: <\(prompt)>"
    }
    
    var responseJSON: JSON {
        return JSON() // Need to be replaced
    }
    
    // MARK: Custom instance variables
    
    /// The prompt of the audio question.
    let prompt: String

    /// The max length of the audio response.
    var duration = 60.0
    
    /// Whether the recording automatically starts.
    var autoStart = false
    
    /// Self-explanatory.
    private var lengthOfMostRecentRecording = 0.0

    
    // MARK: Setup
    
    /**
     Construct a new audio response question from the provided data.
     - Parameters:
        - json: The JSON that contains all the information that makes up the audio response question.
        - order: A tuple that gives the index of the question in the survey (# fragment, # question).
        - fragment: The parent `Fragment` object which the question belongs to.
     */
    required init(json: JSON, order: (Int, Int), fragment: Fragment? = nil) {
        let dictionary = json.dictionaryValue
        
        guard let prompt = dictionary["prompt"]?.string else {
            print(json)
            preconditionFailure("Malformed text question")
        }
        
        if let duration = Double(dictionary["maxLength"]?.stringValue ?? "60") {
            self.duration = duration
        }
        
        if let isRequired = dictionary["isRequired"]?.boolValue {
            self.isRequired = isRequired
        }
        
        
        self.prompt = prompt
        self.fragment = fragment
        self.order = order
    }
    
    func makeContentCell() -> SurveyElementCell {
        return SurveyElementCell()
    }
    
    // MARK: Cell actions
    
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
    
}
