//
//  Rating.swift
//  SurveyLex
//
//  Created by Jia Rui Shan on 2019/5/10.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

/// Represents the information for a rating question in a SurveyLex survey.
class Rating : Question, CustomStringConvertible, RatingResponseDelegate {
    
    // Inherited
    
    var fragment: Fragment?
    var isRequired = false
    var completed = false
    var parentView: SurveyViewController?
    var order: (fragment: Int, question: Int)
    
    var type: ResponseType {
        return .rating
    }
    
    var description: String {
        let choices = "\(options.first?.text ?? "")...\(options.last?.text ?? "")"
        return "\(title):\n  <\(choices)> (\(options.count) choices total)"
    }
    
    func makeContentCell() -> SurveyElementCell {
        return RatingSliderCell(ratingQuestion: self)
    }
    
    var responseJSON: JSON {
        return JSON() // Need to be replaced
    }
    
    // Custom instance variables
    
    /// The title of the rating question.
    let title: String
    
    /// The values that the rating response can take.
    var options = [(value: String, text: String)]()

    /// Convenient shortcut for only getting the displayed texts of the choices.
    var choices: [String] { return options.map { $0.text } }
    
    /// The index of the current selection
    var currentSelection = -1
    
    /**
     Construct a new `Rating` question from the provided data.
     - Parameters:
        - json: The JSON that contains all the information that makes up the question.
        - order: A tuple that gives the index of the question in the survey (# fragment, # question).
        - fragment: The parent `Fragment` object which the question belongs to.
     */
    required init(json: JSON, order: (Int, Int), fragment: Fragment? = nil) {
        let dictionary = json.dictionaryValue
        
        guard let title = dictionary["title"]?.string,
              let rateValues = dictionary["rateValues"]?.array
        else {
            print(json)
            preconditionFailure("Malformed text question")
        }
        
        self.title = title
        self.fragment = fragment
        self.order = order
        
        if let isRequired = dictionary["isRequired"]?.boolValue {
            self.isRequired = isRequired
        }
        
        for option in rateValues {
            if let optionDict = option.dictionaryObject as? [String: String] {
                options.append((optionDict["value"]!, optionDict["text"]!))
            } else if let value = option.int {
                options.append((String(value), String(value)))
            }
        }
        
    }
    
    /// Delegate method that is called when the user makes a selection.
    func didSelectRow(row: Int) {
        currentSelection = row
        UISelectionFeedbackGenerator().selectionChanged()
        completed = true
    }
    
}