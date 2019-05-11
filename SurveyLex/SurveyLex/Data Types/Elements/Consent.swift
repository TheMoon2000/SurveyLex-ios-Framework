//
//  Consent.swift
//  SurveyLex
//
//  Created by Jia Rui Shan on 2019/5/10.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

struct Consent: Question, CustomStringConvertible {
    var title: String
    var consentText: String
    var prompt: String
    var isRequired = true
    
    init(json: JSON) {
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
    }
    
    
    var type: ResponseType {
        return .consent
    }
    
    var description: String {
        return "Consent form <\(title)>"
    }
}
