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
    
    /// Whether the cell is expanded. Non-expanded cells have 0 height.
    var expanded = true

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /// The completion status of the cell.
    var completed: Bool {
        return false
    }
    
    var cellBelow: SurveyElementCell {
        let cell = SurveyElementCell()
        cell.expanded = false
        
        return cell
    }
    
    init() {
        super.init(style: .default, reuseIdentifier: nil)
        
        selectionStyle = .none
        backgroundColor = .white
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
