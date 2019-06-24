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
    init(json: JSON, order: (Int, Int), fragment: Fragment?)
    
    /// An enum that classifies the question by its response type
    var type: ResponseType { get }
    
    /// The parent fragment which the question belongs to
    var fragment: Fragment? { get }
    
    /// A boolean indicating whether the question requires a response in order for the user to proceed.
    var isRequired: Bool { get }
    
    /// A boolean indicating whether the question has received a response.
    var completed: Bool { get }
    
    /// Indicating the order of the question in the survey.
    var order: (fragment: Int, question: Int) { get set }
    
    /// The overarching `SurveyViewController` front-end object that contains the entire survey.
    var parentView: SurveyViewController? { get set }

    /// The view of this particular UI element, as displayed to the user.
    func makeContentCell() -> SurveyElementCell
}

/// Gives default argument for the init method
extension Question {
    init(json: JSON, order: (Int, Int), fragment: Fragment? = nil) {
        self.init(json: json, order: (1, 1), fragment: fragment)
    }
}


enum ResponseType: String {
    
    /// Texual response, involves a prompt and a textfield.
    case text = "text"
    
    /// Single-choice rating question, picks one option from a list.
    case rating = "rating"
    
    /// Similar to rating question.
    case radioGroup = "radiogroup"
    
    case consent = "consent" // NOT used for initialization
    case audio = "audio" // NOT used for initialization
}
