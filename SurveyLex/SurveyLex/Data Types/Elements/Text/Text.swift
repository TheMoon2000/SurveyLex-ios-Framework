//
//  Text.swift
//  SurveyLex
//
//  Created by Jia Rui Shan on 2019/5/9.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

/// Represents the information about a text response question in a SurveyLex survey.
class Text: Question, CustomStringConvertible {
    
    // Inherited
    
    var fragment: Fragment?
    var isRequired = false

    var parentView: SurveyViewController?
    var order: (fragment: Int, question: Int)
    
    var completed: Bool {
        return isRequired ? !response.isEmpty : true
    }
    
    var type: ResponseType {
        return .text
    }
    
    var description: String {
        return "Text response: <\(title)>"
    }
    
    func makeContentCell() -> SurveyElementCell {
        return TextCell(textQuestion: self)
    }
    
    var responseJSON: JSON {
        return JSON() // Need to be replaced
    }
    
    // Custom instance variables
    
    /// The prompt for the text response question.
    let title: String
    
    /// The response inputted by the user.
    var response = ""
    
    /**
     Construct a new text response question from the provided data.
     - Parameters:
        - json: The JSON that contains all the information for the text response question.
        - order: A tuple that gives the index of the question in the survey (# fragment, # question).
        - fragment: The parent `Fragment` object which the text response question belongs to.
     */
    required init(json: JSON, order: (Int, Int), fragment: Fragment? = nil) {
        let dictionary = json.dictionaryValue
        
        guard let title = dictionary["title"]?.string else {
            print(json)
            preconditionFailure("Malformed text question")
        }
        
        if let isRequired = dictionary["isRequired"]?.boolValue {
            self.isRequired = isRequired
        }
        self.title = title
        self.fragment = fragment
        self.order = order
    }

    
    /// A special subclass of UITextField that adds 10 pixels of inset in the horizontal direction.
    class CustomTextField: UITextField {
        override func textRect(forBounds bounds: CGRect) -> CGRect {
            return bounds.inset(by: UIEdgeInsets(top: 0, left: 10, bottom: -1, right: 10))
        }
        
        override func editingRect(forBounds bounds: CGRect) -> CGRect {
            return bounds.inset(by: UIEdgeInsets(top: 0, left: 10, bottom: -1, right: 10))
        }
        
        override func borderRect(forBounds bounds: CGRect) -> CGRect {
            return bounds.inset(by: .zero)
        }
    }

}
