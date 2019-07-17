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
        
        register(CheckboxItemCell.classForCoder(), forCellReuseIdentifier: "checkbox")
        
        for choice in checkboxes.choices {
            let cell = dequeueReusableCell(withIdentifier: "checkbox") as! CheckboxItemCell
            cell.titleLabel.attributedText = TextFormatter.formatted(choice, type: .plain)
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
        parentCell.surveyPage?.focus(cell: parentCell)
        parentCell.topCell.modified = true
        
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
