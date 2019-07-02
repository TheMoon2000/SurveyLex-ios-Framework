//
//  CheckboxesCell.swift
//  SurveyLex Demo
//
//  Created by Jia Rui Shan on 2019/6/30.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class CheckboxesCell: SurveyElementCell {
    
    var checkboxData: CheckBoxes!
    private var title: UITextView!
    private var checkboxTable: CheckboxTable!
    var modified = false
    override var completed: Bool {
        return modified
    }

    init(checkboxes: CheckBoxes) {
        super.init()
        
        self.checkboxData = checkboxes
        title = makeTitle()
        checkboxTable = makeCheckboxTable()
    }
    
    private func makeTitle() -> UITextView {
        let titleText = UITextView()
        titleText.text = "\(checkboxData.order.fragment).\(checkboxData.order.question) " + checkboxData.title
        titleText.format(as: .title)
        titleText.textColor = .black // Assume unfocused by default
        titleText.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleText)
        
        titleText.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor,
                                        constant: SIDE_PADDING).isActive = true
        titleText.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor,
                                         constant: -SIDE_PADDING).isActive = true
        titleText.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor,
                                       constant: 20).isActive = true
        return titleText
    }
    
    private func makeCheckboxTable() -> CheckboxTable {
        let table = CheckboxTable(checkboxes: checkboxData, parentCell: self)
        table.isScrollEnabled = false
        
        /*
        table.layer.borderColor = UIColor.orange.cgColor
        table.layer.borderWidth = 1
        */
        
        table.translatesAutoresizingMaskIntoConstraints = false
        addSubview(table)
        
        table.topAnchor.constraint(equalTo: title.bottomAnchor,
                                   constant: 20).isActive = true
        table.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        table.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        table.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor,
                                      constant: -20).isActive = true
        
        return table
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
