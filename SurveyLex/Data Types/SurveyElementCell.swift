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
    

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var completed: Bool {
        return false
    }
    
    init() {
        super.init(style: .default, reuseIdentifier: nil)
        
        selectionStyle = .none
    }
    
    /// Focus the cell by initiating a series of visual changes.
    func focus() {
        subviews.forEach { $0.alpha = 1.0 }
    }
    
    /// Unfocus the cell by initiating a series of visual changes.
    func unfocus() {
        subviews.forEach { $0.alpha = UNFOCUSED_ALPHA }
    }


}
