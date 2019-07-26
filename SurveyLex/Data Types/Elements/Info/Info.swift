//
//  Info.swift
//  SurveyLex
//
//  Created by Jia Rui Shan on 2019/6/30.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

/// Represents the information for an info screen in a SurveyLex survey.
class Info: Question, CustomStringConvertible {
    
    // MARK: Protocol requirements
    
    var fragment: Fragment?
    var completed = true
    var parentView: SurveyViewController?
    var isRequired = false
    var order: (fragment: Int, question: Int)
    
    var type: ResponseType {
        return .info
    }
    
    var description: String {
        return "Info screen <\(title)>"
    }
    
    func makeContentCell() -> SurveyElementCell {
        return InfoCell(info: self)
    }
    
    var responseJSON: JSON {
        return JSON() // Need to be replaced
    }
    
    var bottomCellExpanded: Bool = false

    
    // MARK: Custom instance variables
    
    /// The title of the info screen.
    let title: String
    
    /// A raw text representation of the body of the info screen.
    let content: String
    
    
    // MARK: Setup
    
    /**
     Construct a new info screen from the provided data.
     - Parameters:
     -  json: The JSON that contains all the information that makes up the info screen.
     - order: A tuple that gives the index of the form in the survey (# fragment, # element), although it won't be displayed.
     - fragment: The parent `Fragment` object which the info screen belongs to.
     */
    required init(json: JSON, order: (Int, Int), fragment: Fragment? = nil) {
        let dictionary = json.dictionaryValue
        
        self.title = dictionary["title"]?.string ?? "Untitled Info screen"
        self.content = dictionary["content"]?.string ?? "No content"
        self.fragment = fragment
        self.order = order
    }
}
