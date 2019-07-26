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
    
    /// The completion status of the cell. This boolean property is different from the `completed` status of the question for which the cell presents. The `completion` status of a `SurveyElementCell` indicates whether the user has already gone through this question, regardless of whether a non-empty response is given (e.g. the case of checkboxes), whereas `completion` in the case of a `Question` means that the response it currently holds is non-empty (e.g. for checkboxes at least one needs to be checked).
    var completed: Bool {
        return false
    }
    
    var cellBelow: SurveyElementCell {
        let cell = SurveyElementCell()
        cell.expanded = false
        
        return cell
    }
    
    /// Shortcut to access whether auto-focus is enabled for this survey.
    var autofocus: Bool {
        return surveyPage?.surveyViewController?.survey.autofocus ?? true
    }
    
    /// Optional handler to rearrange the cell just before it appears.
    var appearHandler: ((SurveyViewController) -> ())?
    
    /// An optional handler to rearrange the cell after it has disappeared from view.
    var disappearHandler: ((SurveyViewController) -> ())?
    
    init() {
        super.init(style: .default, reuseIdentifier: nil)
        
        selectionStyle = .none
        backgroundColor = .white
    }
    
    /// Focuses the cell by initiating a series of visual changes.
    func focus() {
        subviews.forEach { $0.alpha = 1.0 }
    }
    
    /// Unfocuses the cell by initiating a series of visual changes.
    func unfocus() {
        subviews.forEach { $0.alpha = autofocus ? UNFOCUSED_ALPHA : 1.0 }
    }

    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
