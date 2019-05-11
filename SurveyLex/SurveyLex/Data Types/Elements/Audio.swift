//
//  Audio.swift
//  SurveyLex
//
//  Created by Jia Rui Shan on 2019/5/10.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

struct Audio: Question, CustomStringConvertible {
    let prompt: String
    var isRequired = false
    var duration = 60.0 // Length of the audio response
    
    init(json: JSON) {
        let dictionary = json.dictionaryValue
        
        guard let prompt = dictionary["prompt"]?.string else {
            print(json)
            preconditionFailure("Malformed text question")
        }
        
        if let isRequired = dictionary["isRequired"]?.boolValue {
            self.isRequired = isRequired
        }
        
        self.prompt = prompt
    }
    
    var type: ResponseType {
        return .audio
    }
    
    var description: String {
        return "Audio question: <\(prompt)>"
    }
}
