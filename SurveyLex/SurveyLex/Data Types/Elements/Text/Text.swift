//
//  Text.swift
//  SurveyLex
//
//  Created by Jia Rui Shan on 2019/5/9.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

class Text: Question, CustomStringConvertible {
    let title: String
    var fragment: Fragment?
    var isRequired = false
    var completed: Bool {
        return !response.isEmpty
    }
    var response = ""
    var parentView: SurveyViewController?
    var order: (fragment: Int, question: Int)
    
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
        
        self.isRequired = false // debugging
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
    
    
    @objc private func dismissKeyboard(_ sender: UITextField) {
        sender.endEditing(true)
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
