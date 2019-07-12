//
//  RadioGroupBottomCell.swift
//  SurveyLex
//
//  Created by Jia Rui Shan on 2019/7/12.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class RadioGroupBottomCell: SurveyElementCell {

    var radioGroup: RadioGroup!
    var radioTable: MultipleChoiceView!
    var topCell: RadioGroupCell!
    
    init(radioGroup: RadioGroup, topCell: RadioGroupCell) {
        super.init()
        
        self.radioGroup = radioGroup
        self.topCell = topCell
        
        self.radioTable = makeChoiceTable()
        
        self.expanded = false
    }

    private func makeChoiceTable() -> MultipleChoiceView {
        let choiceTable = MultipleChoiceView(radioGroup: radioGroup, parentCell: self)
        choiceTable.translatesAutoresizingMaskIntoConstraints = false
        choiceTable.isScrollEnabled = false
        addSubview(choiceTable)
        
        choiceTable.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor).isActive = true
        choiceTable.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor).isActive = true
        choiceTable.topAnchor.constraint(equalTo: topAnchor).isActive = true
        let bottomConstraint = choiceTable.bottomAnchor.constraint(equalTo: bottomAnchor)
        bottomConstraint.priority = .defaultHigh
        bottomConstraint.isActive = true
        
        return choiceTable
    }
    
    // MARK: MultipleChoice table selection handler
    
    func didSelectRow(row: Int) {
        radioGroup.selection = row
        
        if !radioGroup.completed {
            radioGroup.completed = true
            if (surveyPage?.isCellFocused(cell: self) ?? false) {
                if !radioGroup.parentView!.toNext(from: self) {
                    // This is the last cell on the page, so keep it focused
                    surveyPage?.focus(cell: self)
                }
            } else {
                // The cell was not focused when a selection was made, so now focus it.
                surveyPage?.focus(cell: self)
            }
        } else {
            // The cell has already been selected once, so keep it focused.
            surveyPage?.focus(cell: self)
        }
    }
    
    override func focus() {
        super.focus()
        
        self.alpha = 1
        
        if topCell.title.alpha == UNFOCUSED_ALPHA {
            topCell.focus()
        }
    }
    
    override func unfocus() {
        super.unfocus()
        
        self.alpha = UNFOCUSED_ALPHA
        
        if topCell.title.alpha == 1.0 {
            topCell.unfocus()
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
