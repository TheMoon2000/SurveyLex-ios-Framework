//
//  Question.swift
//  SurveyLex
//
//  Created by Jia Rui Shan on 2019/5/9.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

protocol Question: CustomStringConvertible {
    init(json: JSON)
    var type: ResponseType { get }
    var isRequired: Bool { get }
    
    /// The view of this particular question, as displayed to the user.
    var contentCell: UITableViewCell { get }
}

enum ResponseType: String {
    case text = "text"
    case rating = "rating"
    case radioGroup = "radiogroup"
    case consent = "consent" // NOT used for initialization
    case audio = "audio" // NOT used for initialization
}
