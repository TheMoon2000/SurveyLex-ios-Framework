//
//  UnsupportedCell.swift
//  SurveyLex
//
//  Created by Jia Rui Shan on 2019/6/30.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

/// A subclass of `SurveyElementCell` designed to represent generic, unsupported cell types. This class should only be used for debugging.
class UnsupportedCell: SurveyElementCell {
    
    /// The `Unsupported` survey element object which the cell is presenting.
    var source: UnsupportedQuestion!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(unsupportedQuestion: UnsupportedQuestion) {
        super.init()
        
        source = unsupportedQuestion
        makeLabel()
    }
    
    private func makeLabel() {
        let textView = UITextView()
        textView.text = "Unsupported cell <\(source.typeString)>: \(source.title)"
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.font = .systemFont(ofSize: 18)
        textView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textView)
        
        textView.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor,
                                       constant: 20).isActive = true
        textView.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor,
                                        constant: -20).isActive = true
        textView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor,
                                      constant: 20).isActive = true
        textView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor,
                                         constant: -20).isActive = true
    }
    
}
