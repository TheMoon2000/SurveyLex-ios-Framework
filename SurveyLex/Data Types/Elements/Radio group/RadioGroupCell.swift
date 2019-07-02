//
//  RadioGroupCell.swift
//  SurveyLex
//
//  Created by Jia Rui Shan on 2019/6/23.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

/// A subclass of `SurveyElementCell` that display a radio group question.
class RadioGroupCell: SurveyElementCell, RatingResponseDelegate {
    
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
        let rateInfo = radioGroup.choices.map { ($0, $0) }
        let choiceTable = MultipleChoiceView(rateInfo: rateInfo, delegate: self)
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
    
    // MARK: Rating response delegate
    
    func didSelectRow(row: Int) {
        radioGroup.selection = row
        
        if !radioGroup.completed {
            radioGroup.completed = true
            if !radioGroup.parentView!.toNext(from: self) {
                // The focus was not changed
                surveyPage?.focus(cell: self)
            }
        } else {
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
