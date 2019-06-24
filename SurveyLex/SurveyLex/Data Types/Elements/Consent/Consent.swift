//
//  Consent.swift
//  SurveyLex
//
//  Created by Jia Rui Shan on 2019/5/10.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

class Consent: Question, CustomStringConvertible {
    let title: String
    var fragment: Fragment?
    var consentText = ""
    var completed = false
    let prompt: String
    var parentView: SurveyViewController?
    var isRequired = true
    var order: (fragment: Int, question: Int)
    
    let AGREE_PRESSED = UIColor(red: 0.39, green: 0.59, blue: 0.88, alpha: 1)
    
    required init(json: JSON, order: (Int, Int), fragment: Fragment? = nil) {
        let dictionary = json.dictionaryValue
        
        guard let title = dictionary["title"]?.string,
              let consentText = dictionary["consentText"]?.string,
              let prompt = dictionary["prompt"]?.string
        else {
            print(json)
            preconditionFailure("Malformed consent data")
        }
        
        if let isRequired = dictionary["isRequired"]?.bool {
            self.isRequired = isRequired
        }
    
        self.title = title
        self.consentText = consentText
        self.prompt = prompt
        self.fragment = fragment
        self.order = order
    }
    
    
    var type: ResponseType {
        return .consent
    }
    
    var description: String {
        return "Consent form <\(title)>"
    }
    
    func makeContentCell() -> SurveyElementCell {
        return ConsentCell(consent: self)
    }
    
}
