//
//  Rating.swift
//  SurveyLex
//
//  Created by Jia Rui Shan on 2019/5/10.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

struct Rating : Question, CustomStringConvertible {
    let title: String
    var isRequired = false
    var options = [(value: String, text: String)]()
    
    init(json: JSON) {
        let dictionary = json.dictionaryValue
        
        guard let title = dictionary["title"]?.string,
              let rateValues = dictionary["rateValues"]?.array
        else {
            print(json)
            preconditionFailure("Malformed text question")
        }
        
        self.title = title
        
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
        return .text
    }
    
    var description: String {
        let choices = "\(options.first?.text ?? "")...\(options.last?.text ?? "")"
        return "\(title):\n  <\(choices)> (\(options.count) choices total)"
    }
}
