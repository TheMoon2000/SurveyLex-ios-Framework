//
//  CheckboxesBottomCell.swift
//  SurveyLex
//
//  Created by Jia Rui Shan on 2019/7/15.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

/// A subclass of `SurveyElementCell` that displays the bottom half of a checkbox question — the checkbox table.
class CheckboxesBottomCell: SurveyElementCell {
    
    /// A reference to the top cell.
    var topCell: CheckboxesCell!
    
    /// A reference to the `Checkboxes` question data which this cell is partially displaying.
    private var checkboxes: CheckBoxes!
    
    /// The table view that displays the checkbox choices.
    private var checkboxTable: CheckboxTable!
    
    required init(checkboxes: CheckBoxes, topCell: CheckboxesCell) {
        super.init()
        
        self.checkboxes = checkboxes
        self.topCell = topCell
        
        self.expanded = false
        
        self.checkboxTable = makeCheckboxTable()
    }
    
    private func makeCheckboxTable() -> CheckboxTable {
        let table = CheckboxTable(checkboxes: checkboxes, parentCell: self)
        table.isScrollEnabled = false
        
        table.translatesAutoresizingMaskIntoConstraints = false
        addSubview(table)
        
        table.topAnchor.constraint(equalTo: topAnchor).isActive = true
        table.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        table.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        let bottomConstraint = table.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        bottomConstraint.priority = .init(999)
        bottomConstraint.isActive = true
        
        return table
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
