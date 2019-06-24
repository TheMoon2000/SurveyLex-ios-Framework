//
//  Question.swift
//  Voice Capture Utility
//
//  Created by Jia Rui Shan on 2019/5/7.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

class RadioGroup: Question, CustomStringConvertible {
    let title: String
    var fragment: Fragment?
    let choices: [String]
    var isRequired = false
    var completed = false
    var selection = -1
    var parentView: SurveyViewController?
    var order: (fragment: Int, question: Int)
    
    required init(json: JSON, order: (Int, Int), fragment: Fragment? = nil) {
        let dictionary = json.dictionaryValue
        
        guard let title = dictionary["title"]?.string,
              let questionData = dictionary["choices"]?.arrayObject as? [String]
        else {
            print(json)
            preconditionFailure("Malformed radiogroup question")
        }
        
        if let required = dictionary["isRequired"]?.bool {
            self.isRequired = required
        }
        
        self.title = title
        self.choices = questionData
        self.fragment = fragment
        self.order = order
    }
    
    var type: ResponseType {
        return .radioGroup
    }
    
    var description: String {
        return "Radio group: <" + choices.map {$0.description}.joined(separator: ", ") + ">"
    }
    
    func makeContentCell() -> SurveyElementCell {
        return RadioGroupCell(radioGroup: self)
    }

}
