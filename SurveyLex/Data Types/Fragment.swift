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
    
    /// The survey data object which the fragment belongs to.
    let parent: SurveyData!
    
    let fragmentSource: JSON
    
    /// The JSON representation of this fragment's response data used for submission.
    let fragmentData: JSON
    
    /// The fragment id.
    var id = ""
    
    /// Specifies the type of fragment this one is.
    var type: FragmentType
    
    /// An order list of all the questions that appear in this fragment.
    var questions = [Question]()
    
    /// The index of the fragment (starting at 0).
    let index: Int
    
    /// The response ID for the page.
    let responseId = UUID().uuidString.lowercased()
    
    /// The focused row in the fragment.
    var focusedRow = 0
    
    /// Whether the information one this survey page is completely uploaded.
    var uploaded = false
    
    /// If the initial upload failed, then `needsReupload` needs to be set to true to indicate that it needs to be uploaded again during survey submission.
    var needsReupload = false
    
    public required init(json: JSON, index: Int, parentSurvey: SurveyData? = nil) {
        
        parent = parentSurvey
        
        let dictionary = json.dictionaryValue
        
        guard let fragmentId = dictionary["fragmentId"]?.string,
              let type = dictionary["type"]?.string,
              let data = dictionary["data"]
        else {
            print(dictionary)
            preconditionFailure("Malformed fragment data")
        }
        
        self.fragmentSource = json
        self.fragmentData = data
        self.id = fragmentId
        self.index = index
        self.type = FragmentType(rawValue: type) ?? FragmentType.unsupported
        
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
        default:
            break
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
        case "checkbox":
            return CheckBoxes(json: json, order: order, fragment: self)
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
        case unsupported = ""
    }
    
    /// Customized description that is more debug-friendly.
    var description: String {
        let idParts = id.components(separatedBy: "-")
        let questionsDescription = questions.map {
            $0.description.replacingOccurrences(of: "\n", with: "\n  ")
        }
        return "Fragment <\(idParts[0])...\(idParts[4])>: \n  " + questionsDescription.joined(separator: "\n  ")
    }
    
    /// Returns a `UIViewController` object to be used for the survey UI.
    var contentVC: SurveyPage {
        switch type {
        case .audio:
            let vc = AudioPage(audioQuestion: questions.first as! Audio)
            return vc
        case .consent:
            fallthrough
        case .info:
            fallthrough
        case .textSurvey:
            let fragmentPage = FragmentTableController()
            fragmentPage.fragmentData = self
            return fragmentPage
        case .unsupported:
            let page = UnsupportedPage()
            page.fragmentData = self
            return page
        }
    }
    
    /// Prepares the fragment in JSON form for submission.
    var fragmentJSON: JSON {
        var response = JSON()
        response.dictionaryObject?["createdDate"] = ISO8601DateFormatter().string(from: Date())
        response.dictionaryObject?["responseId"] = self.responseId
        response.dictionaryObject?["fragmentId"] = self.id
        response.dictionaryObject?["fragmentType"] = type.rawValue
        response.dictionaryObject?["fragmentData"] = fragmentData
        response.dictionaryObject?["sessionId"] = parent.sessionID
        response.dictionaryObject?["surveyId"] = parent.surveyId
        
        var data = JSON()

        switch self.type {
        case .textSurvey:
            self.questions.forEach { q in
                data.dictionaryObject?.merge(q.responseJSON.dictionaryValue) { (current, _) in
                    return current
                }
            }

        case .info:
            fallthrough
        case .audio:
            // Note: `sampleId` and `skipped` need to be added later in the `data` attribute
            fallthrough
        default:
            break
        }
        
        response.dictionaryObject?["data"] = data
        return response
    }
}
