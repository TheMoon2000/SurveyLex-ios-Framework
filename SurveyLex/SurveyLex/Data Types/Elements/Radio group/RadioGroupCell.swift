//
//  RadioGroupCell.swift
//  SurveyLex
//
//  Created by Jia Rui Shan on 2019/6/23.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class RadioGroupCell: SurveyElementCell, RatingResponseDelegate {
    
    var radioGroup: RadioGroup!
    private var textView: UITextView!
    private var choiceTable: MultipleChoiceView!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(radioGroup: RadioGroup) {
        super.init()
        self.radioGroup = radioGroup
        
        textView = makeTextView()
        choiceTable = makeChoiceTable()
    }
    
    private func makeTextView() -> UITextView {
        let textView = UITextView()
        textView.attributedText = TextFormatter.formatted(radioGroup.title,
                                                          type: .title)
        textView.textAlignment = .left
        textView.isUserInteractionEnabled = false
        textView.dataDetectorTypes = .link
        textView.linkTextAttributes[.foregroundColor] = BLUE_TINT
        textView.isScrollEnabled = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textView)
        
        textView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor,
                                      constant: 30).isActive = true
        textView.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor,
                                       constant: 18).isActive = true
        textView.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor,
                                        constant: -18).isActive = true
        return textView
    }
    
    private func makeChoiceTable() -> MultipleChoiceView {
        let rateInfo = radioGroup.choices.map { ($0, $0) }
        let choiceTable = MultipleChoiceView(rateInfo: rateInfo, delegate: self)
        choiceTable.translatesAutoresizingMaskIntoConstraints = false
        choiceTable.isScrollEnabled = false
        addSubview(choiceTable)
        
        choiceTable.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor).isActive = true
        choiceTable.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor).isActive = true
        choiceTable.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor,
                                            constant: -30).isActive = true
        choiceTable.topAnchor.constraint(equalTo: textView.bottomAnchor,
                                         constant: 20).isActive = true
        
        return choiceTable
        
    }
    
    // Rating response delegate
    
    func didSelectRow(row: Int) {
        radioGroup.selection = row
        if !radioGroup.completed {
            radioGroup.completed = true
            radioGroup.parentView?.updateCompletionRate(true)
        }
        
        if (surveyPage?.isCellFocused(cell: self) ?? false) {
            print("move forward to row \(surveyPage!.focusedRow + 1)")
            surveyPage?.focusedRow += 1
        }
    }

}
