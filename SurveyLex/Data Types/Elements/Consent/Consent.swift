//
//  Consent.swift
//  SurveyLex
//
//  Created by Jia Rui Shan on 2019/5/10.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

/// Represents the information for a consent form in a SurveyLex survey.
class Consent: Question, CustomStringConvertible {
    
    // MARK: Protocol requirements
    
    var fragment: Fragment?
    var completed = false
    var parentView: SurveyViewController?
    var isRequired = true
    var order: (fragment: Int, question: Int)
    
    var type: ResponseType {
        return .consent
    }
    
    var description: String {
        let requiredString = isRequired ? " (required)" : ""
        return "Consent form <\(title)>" + requiredString
    }
    
    func makeContentCell() -> SurveyElementCell {
        return ConsentCell(consent: self)
    }
    
    var responseJSON: JSON {
        return JSON() // Need to be replaced
    }
    
    var bottomCellExpanded: Bool = false
    
    // MARK: Custom instance variables
    
    /// The title of the consent form.
    let title: String
    
    /// A raw text representation of the body of the consent form.
    let consentText: String
    
    /// The prompt for the consent form.
    let prompt: String
    
    /// This value records whether the consent form's checkbox is checked.
    var promptChecked = false
    
    
    // Setup
    
    /**
     Construct a new consent form from the provided data.
     - Parameters:
        -  json: The JSON that contains all the information that makes up the consent form.
        - order: A tuple that gives the index of the form in the survey (# fragment, # element), although it won't be displayed.
        - fragment: The parent `Fragment` object which the consent form belongs to.
     */
    required init(json: JSON, order: (Int, Int), fragment: Fragment? = nil) {
        let dictionary = json.dictionaryValue
        
        if let title = dictionary["title"]?.string {
            self.title = title
        } else {
            self.title = fragment?.parent.title ?? ""
        }
        
        self.consentText = dictionary["consentText"]?.string ?? ""
        
        if let isRequired = dictionary["isRequired"]?.bool {
            self.isRequired = isRequired
        }
    
        self.prompt = dictionary["prompt"]?.string ?? ""
        self.fragment = fragment
        self.order = order
    }
    
}
