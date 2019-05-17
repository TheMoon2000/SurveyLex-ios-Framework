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
    let fragment: Fragment
    var isRequired = false
    var completed = false
    var parentView: SurveyViewController?
    
    required init(json: JSON, fragment: Fragment) {
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
        
        self.isRequired = false // debugging
    }
    
    var type: ResponseType {
        return .text
    }
    
    var description: String {
        return "Text response: <\(title)>"
    }
    
    func makeContentCell() -> UITableViewCell {
        let cell = UITableViewCell()
        cell.backgroundColor = .white
        
        return cell
    }

}
