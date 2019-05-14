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
    var isRequired = false
    var duration = 60.0 // Length of the audio response
    var fragmentId = "default"
    
    required init(json: JSON) {
        let dictionary = json.dictionaryValue
        
        guard let prompt = dictionary["prompt"]?.string else {
            print(json)
            preconditionFailure("Malformed text question")
        }
        
        if let isRequired = dictionary["isRequired"]?.boolValue {
            self.isRequired = isRequired
        }
        
        self.prompt = prompt
    }
    
    var type: ResponseType {
        return .audio
    }
    
    var description: String {
        return "Audio question: <\(prompt)>"
    }
    
    var contentCell: UITableViewCell {
        let cell = UITableViewCell()
        cell.backgroundColor = .white
        
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .medium)
        label.text = prompt
        label.numberOfLines = 100
        label.adjustsFontSizeToFitWidth = true
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        cell.addSubview(label)
        label.leftAnchor.constraint(equalTo: cell.leftAnchor,
                                    constant: 30).isActive = true
        label.rightAnchor.constraint(equalTo: cell.rightAnchor,
                                     constant: -30).isActive = true
        label.topAnchor.constraint(equalTo: cell.topAnchor,
                                   constant: 40).isActive = true
        
        
        let recorder = Recorder(filename: fragmentId)
        
        let button = RecordButton(duration: 30,
                                  radius: 55,
                                  recorder: recorder)
        
        button.tintColor = BUTTON_TINT
        cell.addSubview(button)
        button.centerXAnchor.constraint(equalTo: cell.centerXAnchor).isActive = true
        button.topAnchor.constraint(greaterThanOrEqualTo: label.bottomAnchor, constant: 120).isActive = true
        
        let skip = UIButton(type: .system)
        skip.tintColor = BUTTON_DEEP_BLUE
        skip.titleLabel?.font = .systemFont(ofSize: 16.8, weight: .medium)
        skip.setTitle("Skip", for: .normal)
        skip.translatesAutoresizingMaskIntoConstraints = false
        cell.addSubview(skip)
        skip.widthAnchor.constraint(equalTo: button.widthAnchor, constant: -5).isActive = true
        skip.centerXAnchor.constraint(equalTo: cell.centerXAnchor).isActive = true
        skip.topAnchor.constraint(equalTo: button.bottomAnchor, constant: 20).isActive = true
        skip.bottomAnchor.constraint(equalTo: cell.bottomAnchor, constant: -45).isActive = true
        skip.isHidden = isRequired
        
        
        // 60 is the constant height of the navigation bar & status bar
        cell.heightAnchor.constraint(greaterThanOrEqualToConstant: UIScreen.main.bounds.height - 60 - UIApplication.shared.keyWindow!.safeAreaInsets.bottom).isActive = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(recordingError), name: NSNotification.Name(rawValue: "No mic permission"), object: nil)
        
        
        return cell
    }
    
    // Cell actions
    
    @objc func recordingError(_ sender: RecordButton) {
        let alert = UIAlertController(title: "No Mic Access",
                                      message: "Please enable microphone access in Settings",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//        self.present(alert, animated: true, completion: nil)
    }
}
