//
//  Text.swift
//  SurveyLex
//
//  Created by Jia Rui Shan on 2019/5/9.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

struct Text: Question, CustomStringConvertible {
    let title: String
    var isRequired = false
    
    init(json: JSON) {
        let dictionary = json.dictionaryValue
        
        guard let title = dictionary["title"]?.string else {
            print(json)
            preconditionFailure("Malformed text question")
        }
        
        if let isRequired = dictionary["isRequired"]?.boolValue {
            self.isRequired = isRequired
        }
        self.title = title
    }
    
    var type: ResponseType {
        return .text
    }
    
    var description: String {
        return "Text response: <\(title)>"
    }
}
