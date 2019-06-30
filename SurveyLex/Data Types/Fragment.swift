//
//  Fragment.swift
//  Voice Capture Utility
//
//  Created by Jia Rui Shan on 2019/5/7.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

/// Second class of survey objects. A `Fragment` is a collection of individual survey elements, intended to be presented together.
class Fragment: CustomStringConvertible {
    
    /// The fragment id.
    internal var id = ""
    
    /// Specifies the type of fragment this one is.
    var type: FragmentType
    
    /// An order list of all the questions that appear in this fragment.
    var questions = [Question]()
    
    /// The index of the fragment (starting at 1).
    let index: Int
    
    public init(json: JSON, index: Int) {
        let dictionary = json.dictionaryValue
        
        guard let fragmentId = dictionary["fragmentId"]?.string,
              let type = dictionary["type"]?.string,
              let data = dictionary["data"]
        else {
            print(dictionary)
            preconditionFailure("Malformed fragment data")
        }
        
        self.id = fragmentId
        self.index = index
        self.type = FragmentType(rawValue: type)!
        
        switch self.type {
        case .audio:
            questions.append(Audio(json: data, order: (index + 1, 1), fragment: self))
        case .consent:
            questions.append(Consent(json: data, order: (index + 1, 1), fragment: self))
        case .textSurvey:
            // must be surveyjs questions
            guard let questionJSONList = data.dictionary?["surveyjs"]? .dictionaryValue["questions"]?.array else {
                preconditionFailure("Malformed text question:")
            }
            for i in 0..<questionJSONList.count {
                let q = match(questionJSONList[i], order: (index + 1, i + 1))
                self.questions.append(q)
            }
        case .info:
            questions.append(Info(json: data, order: (index + 1, 1), fragment: self))
        }
    }
    
    /// Matches a JSON to a specific question object.
    private func match(_ json: JSON, order: (Int, Int)) -> Question {
        let type = json.dictionaryValue["type"]?.stringValue ?? ""
        switch type {
        case "rating":
            return Rating(json: json, order: order, fragment: self)
        case "text":
            return Text(json: json, order: order, fragment: self)
        case "radiogroup":
            return RadioGroup(json: json, order: order, fragment: self)
        default:
//            preconditionFailure("Unmatched question type: '\(json.dictionaryValue["type"]?.stringValue ?? "")'")
            let u = UnsupportedQuestion(json: json, order: order, fragment: self)
            u.typeString = type
            return u
        }
    }
    
    /// The category that a fragment belongs to.
    public enum FragmentType: String {
        case consent = "CONSENT"
        case textSurvey = "TEXT_SURVEYJS"
        case audio = "AUDIO_STANDARD"
        case info = "INFO"
    }
    
    /// Customized description that is more debug-friendly.
    var description: String {
        let idParts = id.components(separatedBy: "-")
        let questionsDescription = questions.map {
            $0.description.replacingOccurrences(of: "\n", with: "\n  ")
        }
        return "Fragment <\(idParts[0])...\(idParts[4])>: \n  " + questionsDescription.joined(separator: "\n  ")
    }
    
    /// Returns a `FragmentTableController` object to be used for the survey UI.
    var contentVC: FragmentTableController {
        let fragmentTable = FragmentTableController()
        fragmentTable.fragmentData = self
        return fragmentTable
    }
    
    /// Prepares the fragment in JSON form for submission.
    var fragmentJSON: JSON {
        var response = JSON()
        response.dictionaryObject?["fragmentId"] = self.id
        let typeJSON = JSON(parseJSON: "{type: \(self.type.rawValue)}")
        response.dictionaryObject?["type"] = typeJSON
        
        switch self.type {
        case .textSurvey:
            var data = JSON()
            questions.forEach { q in
                data.arrayObject?.append(q.responseJSON)
            }
            response.dictionaryObject?["data"] = data
            return response
        default:
            return response
        }
    }
}
