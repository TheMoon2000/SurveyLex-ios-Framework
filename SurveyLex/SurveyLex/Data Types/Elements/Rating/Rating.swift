//
//  Rating.swift
//  SurveyLex
//
//  Created by Jia Rui Shan on 2019/5/10.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

class Rating : Question, CustomStringConvertible, RatingResponseDelegate {
    let title: String
    var fragment: Fragment?
    var isRequired = false
    var completed = false
    var parentView: SurveyViewController?
    var options = [(value: String, text: String)]()
    var choices: [String] {
        return options.map { $0.text }
    }
    var order: (fragment: Int, question: Int)
    
    /// Stores the user's response, which will be accessed during survey submission
    var currentSelections = [Int]()
    
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
    
    /// Delegate method that responds when the user makes a selection
    
    func didSelectRow(row: Int) {
        currentSelections = [row]
        if !self.completed {
            self.completed = true
            parentView?.nextPage()
        }
    }
    
}
