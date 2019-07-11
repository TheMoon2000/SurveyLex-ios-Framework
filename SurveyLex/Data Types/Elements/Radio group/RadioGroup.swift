//
//  Question.swift
//  Voice Capture Utility
//
//  Created by Jia Rui Shan on 2019/5/7.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

/// Represents the information for a radio group question in a SurveyLex survey.
class RadioGroup: Question, CustomStringConvertible {
    
    // Inherited
    
    var fragment: Fragment?
    var isRequired = false
    var completed = false
    var parentView: SurveyViewController?
    var order: (fragment: Int, question: Int)
    
    var type: ResponseType {
        return .radioGroup
    }
    
    var description: String {
        return "Radio group: <" + choices.map {$0.description}.joined(separator: ", ") + ">"
    }
    
    func makeContentCell() -> SurveyElementCell {
        return RadioGroupCell(radioGroup: self)
    }
    
    var responseJSON: JSON {
        var json = JSON()
        json.dictionaryObject?["question\(order.question)"] = selection == -1 ? JSON.null : choices[selection]
        
        return json
    }
    
    // Custom instance variables
    
    /// The title of the radio group question.
    let title: String

    /// The choices available for the user to choose from in this radio group question.
    let choices: [String]
    
    /// The index of the current selection. -1 means nothing is selected.
    var selection = -1
    
    
    /**
     Construct a new `RadioGroup` question from the provided data.
     - Parameters:
        - json: The JSON that contains all the information that makes up the radio group.
        - order: A tuple that gives the index of the question in the survey (# fragment, # question).
        - fragment: The parent `Fragment` object which the radio group belongs to.
     */
    required init(json: JSON, order: (Int, Int), fragment: Fragment? = nil) {
        let dictionary = json.dictionaryValue
        
        guard let questionData = dictionary["choices"]?.arrayObject as? [String]
        else {
            print(json)
            preconditionFailure("Malformed radiogroup question")
        }
        
        if let title = dictionary["title"]?.string {
            self.title = title
        } else {
            self.title = "<Question \(order.1)>"
        }
        
        if let required = dictionary["isRequired"]?.bool {
            self.isRequired = required
        }
        
        self.choices = questionData
        self.fragment = fragment
        self.order = order
    }

}
