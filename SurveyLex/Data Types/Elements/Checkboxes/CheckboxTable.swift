//
//  CheckboxTable.swift
//  SurveyLex Demo
//
//  Created by Jia Rui Shan on 2019/6/30.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class CheckboxTable: UITableView, UITableViewDelegate, UITableViewDataSource {

    var checkboxData: CheckBoxes!
    var parentCell: CheckboxesCell!
    
    override var intrinsicContentSize: CGSize {
//        self.reloadData()
        return contentSize
    }
    
    init(checkboxes: CheckBoxes, parentCell: CheckboxesCell) {
        super.init(frame: .zero, style: .plain)
        
        checkboxData = checkboxes
        self.parentCell = parentCell
        
        allowsMultipleSelection = true
        separatorStyle = .none
        tableFooterView = UIView(frame: .zero)
        delegate = self; dataSource = self
        rowHeight = UITableView.automaticDimension
    }
    
    // MARK: Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return checkboxData.choices.count
    }
    
    // Essential for calculating the correct height for the cells
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let cell = self.tableView(tableView, cellForRowAt: indexPath)
        let width = UIScreen.main.bounds.width
        return cell.preferredHeight(width: width - 55)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = CheckboxItemCell(title: checkboxData.choices[indexPath.row])
        cell.checkbox.isChecked = checkboxData.selections.contains(indexPath.row)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UISelectionFeedbackGenerator().selectionChanged()
        parentCell.surveyPage?.focus(cell: parentCell)
        parentCell.modified = true
        checkboxData.selections.insert(indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        UISelectionFeedbackGenerator().selectionChanged()
        checkboxData.selections.remove(indexPath.row)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
