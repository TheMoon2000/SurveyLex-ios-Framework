//
//  Checkboxes.swift
//  SurveyLex Demo
//
//  Created by Jia Rui Shan on 2019/6/30.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

/// Represents the information for a checkbox question in a SurveyLex survey.
class CheckBoxes: Question, CustomStringConvertible {
    
    // MARK: Protocol requirements
    
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
        var json = JSON()
        let selectedChoices = selections.map { choices[$0] }
        json.dictionaryObject?["question\(order.question)"] = selectedChoices
        return json
    }
    
    // MARK: Custom instance variables
    
    /// The title of the checkbox question.
    let title: String
    
    /// The choices available for the user to choose from in this radio group question.
    let choices: [String]
    
    /// The indexes of the current selections.
    var selections = Set<Int>()
    
    /// Whether the user has modified their response for this question.
    var modified = false
    
    var bottomCellExpanded: Bool = false
    
    // MARK: Setup
    
    /**
     Construct a new checkbox question data object from the provided data.
     - Parameters:
     -  json: The JSON that contains all the information that makes up the checkbox question.
     - order: A tuple that gives the index of the form in the survey (# fragment, # element), although it won't be displayed.
     - fragment: The parent `Fragment` object which the checkbox question belongs to.
     */
    
    required init(json: JSON, order: (Int, Int), fragment: Fragment?) {
        let dictionary = json.dictionaryValue
        
        guard let questionData = dictionary["choices"]?.arrayObject as? [String]
            else {
            print(json)
            preconditionFailure("Malformed checkboxes question")
        }
        
        if let title = dictionary["title"]?.string {
            self.title = title
        } else {
            self.title = "<Question \(order.1)>"
        }
        
        if let required = dictionary["isRequired"]?.boolValue {
            isRequired = required
        }
        
        self.choices = questionData
        self.fragment = fragment
        self.order = order
    }
}
