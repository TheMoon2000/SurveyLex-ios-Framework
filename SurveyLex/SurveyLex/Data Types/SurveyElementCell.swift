//
//  SurveyElementCell.swift
//  SurveyLex
//
//  Created by Jia Rui Shan on 2019/6/22.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class SurveyElementCell: UITableViewCell {
 
    /// Reference to the Fragment Table View Controller that displays the current survey element.
    var surveyPage: FragmentTableController?
    
    private(set) var isCurrentQuestion = false

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init() {
        super.init(style: .default, reuseIdentifier: nil)
        
        selectionStyle = .none
    }
    
    func focus() {
        isCurrentQuestion = true
        subviews.forEach { $0.alpha = 1.0 }
    }
    
    func unfocus() {
        isCurrentQuestion = false
        subviews.forEach { $0.alpha = UNFOCUSED_ALPHA }
    }


}
