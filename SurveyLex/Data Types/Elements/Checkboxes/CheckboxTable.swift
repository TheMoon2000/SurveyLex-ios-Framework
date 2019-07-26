//
//  CheckboxTable.swift
//  SurveyLex Demo
//
//  Created by Jia Rui Shan on 2019/6/30.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

/// A special subclass of `UITableView` that displays a group of checkboxes.
class CheckboxTable: UITableView, UITableViewDelegate, UITableViewDataSource {

    var checkboxData: CheckBoxes!
    var parentCell: CheckboxesBottomCell!
    private var choiceCells = [CheckboxItemCell]()
    
    override var intrinsicContentSize: CGSize {
        self.reloadData()
        return contentSize
    }
    
    init(checkboxes: CheckBoxes, parentCell: CheckboxesBottomCell) {
        super.init(frame: .zero, style: .plain)
        
        checkboxData = checkboxes
        self.parentCell = parentCell
        
        separatorStyle = .none
        tableFooterView = UIView(frame: .zero)
        delegate = self
        dataSource = self
        
        for i in 0..<checkboxes.choices.count {
            let cell = CheckboxItemCell()
            cell.titleLabel.attributedText = TextFormatter.formatted(checkboxes.choices[i], type: .plain)
            cell.checkbox.isChecked = checkboxData.selections.contains(i)
            choiceCells.append(cell)
        }
    }
    
    // MARK: Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return choiceCells.count
    }
    
    // Essential for calculating the correct height for the cells
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return choiceCells[indexPath.row].preferredHeight(width: parentCell.surveyPage!.tableView.safeAreaLayoutGuide.layoutFrame.width)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return choiceCells[indexPath.row]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UISelectionFeedbackGenerator().selectionChanged()
        tableView.deselectRow(at: indexPath, animated: false)
        
        // Focus the current checkbox question
        parentCell.surveyPage?.focus(cell: parentCell)
        
        // Tell the fragment page controller that its information needs to be uploaded again
        checkboxData.fragment?.uploaded = false
        
        // Cell has been modified
        checkboxData.modified = true
        
        parentCell.topCell.surveyPage?.scrollToCell(cell: parentCell)
        
        choiceCells[indexPath.row].checkbox.isChecked.toggle()
        if choiceCells[indexPath.row].checkbox.isChecked {
            checkboxData.selections.insert(indexPath.row)
        } else {
            checkboxData.selections.remove(indexPath.row)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
