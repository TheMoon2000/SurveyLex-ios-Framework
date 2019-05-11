//
//  Fragment.swift
//  Voice Capture Utility
//
//  Created by Jia Rui Shan on 2019/5/7.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

struct Fragment: CustomStringConvertible {
    private var id = ""
    var type: FragmentType
    
    /// An order list of all the questions that appear in this fragment
    var questions = [Question]()
    
    public init(json: JSON) {
        let dictionary = json.dictionaryValue
        
        guard let fragmentId = dictionary["fragmentId"]?.string,
              let type = dictionary["type"]?.string,
              let data = dictionary["data"]
        else {
            print(dictionary)
            preconditionFailure("Malformed fragment data")
        }
        
        self.id = fragmentId
        self.type = FragmentType(rawValue: type)!
        
        if self.type == .audio {
            questions.append(Audio(json: data))
        } else if self.type == .consent {
            questions.append(Consent(json: data))
        } else { // must be text questions
            guard let questionJSONList = data.dictionary?["surveyjs"]? .dictionaryValue["questions"]?.array else {
                preconditionFailure("Malformed text question:")
            }
            for q in questionJSONList {
                self.questions.append(match(q))
            }
        }
    }
    
    /// Matches a JSON packet to a specific question object
    private func match(_ json: JSON) -> Question {
        switch json.dictionaryValue["type"]?.stringValue ?? "" {
        case "rating":
            return Rating(json: json)
        case "text":
            return Text(json: json)
        case "radiogroup":
            return RadioGroup(json: json)
        default:
            preconditionFailure("Unmatched question type: '\(json.dictionaryValue["type"]?.stringValue ?? "")'")
        }
    }
    
    public enum FragmentType: String {
        case consent = "CONSENT"
        case textSurvey = "TEXT_SURVEYJS"
        case audio = "AUDIO_STANDARD"
    }
    
    var description: String {
        let idParts = id.components(separatedBy: "-")
        let questionsDescription = questions.map {
            $0.description.replacingOccurrences(of: "\n", with: "\n  ")
        }
        return "Fragment <\(idParts[0])...\(idParts[4])>: \n  " + questionsDescription.joined(separator: "\n  ")
    }
}
