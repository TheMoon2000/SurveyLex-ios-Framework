//
//  RadioGroupCell.swift
//  SurveyLex
//
//  Created by Jia Rui Shan on 2019/6/23.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

/// A subclass of `SurveyElementCell` that display a radio group question.
class RadioGroupCell: SurveyElementCell {
    
    /// Shortcut for the completion status of the cell, accessible from the `SurveyElementCell` class.
    override var completed: Bool {
        return radioGroup.completed
    }
    
    /// The `RadioGroup` instance which the current cell is presenting.
    var radioGroup: RadioGroup!
    
    /// The text view for the title of the radio group question.
    private var title: UITextView!
    
    /// The table subview embedded in this cell.
    private var choiceTable: MultipleChoiceView!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(radioGroup: RadioGroup) {
        super.init()
        self.radioGroup = radioGroup
        
        title = makeTitleView()
        choiceTable = makeChoiceTable()
    }
    
    // MARK: Main components (title & radio group)
    
    private func makeTitleView() -> UITextView {
        let titleText = UITextView()
        titleText.text = "\(radioGroup.order.fragment).\(radioGroup.order.question) " + radioGroup.title
        titleText.format(as: .title)
        titleText.textColor = .black
        titleText.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleText)
        
        titleText.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor,
                                      constant: 20).isActive = true
        titleText.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor,
                                        constant: SIDE_PADDING).isActive = true
        titleText.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor,
                                         constant: -SIDE_PADDING).isActive = true
        return titleText
    }
    
    private func makeChoiceTable() -> MultipleChoiceView {
        let choiceTable = MultipleChoiceView(radioGroup: radioGroup, parentCell: self)
        choiceTable.translatesAutoresizingMaskIntoConstraints = false
        choiceTable.isScrollEnabled = false
        addSubview(choiceTable)
        
        choiceTable.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        choiceTable.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        choiceTable.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor,
                                            constant: -30).isActive = true
        choiceTable.topAnchor.constraint(equalTo: title.bottomAnchor,
                                         constant: 20).isActive = true
        
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
    
    // MARK: Customized focus / unfocus appearance
    
    override func focus() {
        super.focus()
//        title.textColor = .black
    }
    
    override func unfocus() {
        super.unfocus()
//        title.textColor = .darkGray
    }

}
