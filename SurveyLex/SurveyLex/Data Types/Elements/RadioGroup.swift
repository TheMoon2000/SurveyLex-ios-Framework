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
    var isRequired = false
    var choices = [String]()
    
    required init(json: JSON) {
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
    }
    
    var type: ResponseType {
        return .radioGroup
    }
    
    var description: String {
        return "Radio group: <" + choices.map {$0.description}.joined(separator: ", ") + ">"
    }
    
    var contentCell: UITableViewCell {
        let cell = UITableViewCell()
        cell.backgroundColor = UIColor(red: 1, green: 0.9, blue: 1, alpha: 1)
        return cell
    }
    
}
