//
//  Question.swift
//  SurveyLex
//
//  Created by Jia Rui Shan on 2019/5/9.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

protocol Question: class, CustomStringConvertible {
    init(json: JSON, fragment: Fragment)
    var type: ResponseType { get }
    var fragment: Fragment { get }
    var isRequired: Bool { get }
    var completed: Bool { get }
    var parentView: SurveyViewController? { get set }

    /// The view of this particular UI element, as displayed to the user.
    func makeContentCell() -> UITableViewCell
}

enum ResponseType: String {
    case text = "text"
    case rating = "rating"
    case radioGroup = "radiogroup"
    case consent = "consent" // NOT used for initialization
    case audio = "audio" // NOT used for initialization
}
