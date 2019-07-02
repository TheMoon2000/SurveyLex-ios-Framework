//
//  Checkboxes.swift
//  SurveyLex Demo
//
//  Created by Jia Rui Shan on 2019/6/30.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

class CheckBoxes: Question, CustomStringConvertible {
    
    // Inherited
    
    var fragment: Fragment?
    var isRequired = false
    var completed: Bool {
        if !isRequired {
            return true
        } else {
            return !selections.isEmpty
        }
    }
    var parentView: SurveyViewController?
    var order: (fragment: Int, question: Int)
    
    var type: ResponseType {
        return .checkbox
    }
    
    var description: String {
        return "Checkboxes: <" + choices.map { $0.description }.joined(separator: ", ") + ">"
    }
    
    func makeContentCell() -> SurveyElementCell {
        return CheckboxesCell(checkboxes: self)
    }
    
    var responseJSON: JSON {
        return JSON() // Needs to be replaced
    }
    
    // Custom instance variables
    
    /// The title of the checkbox question.
    let title: String
    
    /// The choices available for the user to choose from in this radio group question.
    let choices: [String]
    
    /// The indexes of the current selections.
    var selections = Set<Int>()
    
    required init(json: JSON, order: (Int, Int), fragment: Fragment?) {
        let dictionary = json.dictionaryValue
        
        guard let title = dictionary["title"]?.string,
              let questionData = dictionary["choices"]?.arrayObject as? [String]
            else {
                print(json)
                preconditionFailure("Malformed checkboxes question")
        }
        
        if let required = dictionary["isRequired"]?.boolValue {
            isRequired = required
        }
        
        self.title = title
        self.choices = questionData
        self.fragment = fragment
        self.order = order
    }
}
