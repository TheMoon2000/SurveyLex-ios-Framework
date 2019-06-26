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
    
    /// The `RadioGroup` instance which the current cell is presenting.
    var radioGroup: RadioGroup!
    
    /// The text view for the title of the radio group question.
    private var title: UITextView!
    
    
    private var choiceTable: MultipleChoiceView!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(radioGroup: RadioGroup) {
        super.init()
        self.radioGroup = radioGroup
        
        title = makeTextView()
        choiceTable = makeChoiceTable()
    }
    
    private func makeTextView() -> UITextView {
        let textView = UITextView()
        let numbered = "\(radioGroup.order.fragment).\(radioGroup.order.question) " + radioGroup.title
        textView.attributedText = TextFormatter.formatted(numbered, type: .title)
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
        choiceTable.topAnchor.constraint(equalTo: title.bottomAnchor,
                                         constant: 20).isActive = true
        
        return choiceTable
        
    }
    
    // Rating response delegate
    
    func didSelectRow(row: Int) {
        radioGroup.selection = row
        radioGroup.completed = true
        
        if (surveyPage?.isCellFocused(cell: self) ?? false) {
            surveyPage?.focusedRow += 1
        }
        radioGroup.parentView?.flipPageIfNeeded(cell: self)
    }
    
    // Customized focus / unfocus appearance
    
    override func focus() {
        super.focus()
        title.textColor = .black
    }
    
    override func unfocus() {
        super.unfocus()
        title.textColor = .darkGray
    }

}
