//
//  MultipleChoiceView.swift
//  SurveyLex
//
//  Created by Jia Rui Shan on 2019/5/15.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

/// A table view embedded in a `RadioGroupCell`.
class MultipleChoiceView: UITableView, UITableViewDelegate, UITableViewDataSource {
    
    var radioGroup: RadioGroup!
    var parentCell: RadioGroupBottomCell!
    
    override var intrinsicContentSize: CGSize {
        self.reloadData()
        if radioGroup.selection != -1 {
            selectRow(at: IndexPath(row: radioGroup.selection, section: 0), animated: false, scrollPosition: .none)
        }
        return contentSize
    }

    init(radioGroup: RadioGroup, parentCell: RadioGroupBottomCell) {
        super.init(frame: .zero, style: .plain)
        
        self.radioGroup = radioGroup
        self.parentCell = parentCell
        
        tableFooterView = UIView(frame: .zero)
        self.delegate = self
        self.dataSource = self
        separatorInset = .zero
        separatorColor = .init(white: 0.85, alpha: 1)
        self.rowHeight = UITableView.automaticDimension
        self.register(MultipleChoiceCell.classForCoder(),
                      forCellReuseIdentifier: "choice")
    }
    
    // Essential for calculating the correct height for the cells
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let cell = self.tableView(tableView, cellForRowAt: indexPath)
        let width = UIScreen.main.bounds.width
//        print(cell.preferredHeight(width: width - 55), cell.preferredHeight(width: cell.frame.width))
        return cell.preferredHeight(width: cell.frame.width)
    }
    
    // MARK: Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return radioGroup.choices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "choice") as! MultipleChoiceCell
        cell.titleLabel.attributedText = TextFormatter.formatted(radioGroup.choices[indexPath.row], type: .plain)
        return cell
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        parentCell.didSelectRow(row: indexPath.row)
        UISelectionFeedbackGenerator().selectionChanged()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}

extension UIView {
    
    /// Extension method that finds the optimal height for the view, given its current width.
    func preferredHeight(width: CGFloat) -> CGFloat {
        let widthConstraint = self.widthAnchor.constraint(equalToConstant: width)
        widthConstraint.priority = .init(999)
        self.addConstraint(widthConstraint)
        let height = systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        self.removeConstraint(widthConstraint)
        return height
    }
}
