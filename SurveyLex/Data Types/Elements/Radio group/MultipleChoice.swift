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
    
    /// An array of pre-generated cells to be displayed as choices for the multiple choice question.
    var choiceCells = [MultipleChoiceCell]()
    
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
        
        // Make the pre-generaated cells
        for i in 0..<radioGroup.choices.count {
            let cell = MultipleChoiceCell(theme: radioGroup.theme)
            cell.titleLabel.attributedText = TextFormatter.formatted(radioGroup.choices[i], type: .plain)
            if i == radioGroup.selection {
                cell.radioCircle.isChecked = true
                cell.isSelected = true
            }
            choiceCells.append(cell)
        }
    }
    
    // Essential for calculating the correct height for the cells
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return choiceCells[indexPath.row].preferredHeight(width: parentCell.surveyPage.tableView.safeAreaLayoutGuide.layoutFrame.width)
    }
    
    // MARK: Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return choiceCells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        return choiceCells[indexPath.row]
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        radioGroup.selection = indexPath.row
        
        if !radioGroup.completed {
            radioGroup.completed = true
            if !radioGroup.parentView!.toNext(from: parentCell) {
                
                // The focus was not changed
                parentCell.surveyPage.focus(cell: parentCell)
            }
        } else {
            
            if indexPath.row != radioGroup.selection {
                UISelectionFeedbackGenerator().selectionChanged()
                parentCell.surveyPage.uploaded = false
            }
            
            // The cell has already been selected once, so keep it focused.
            parentCell.surveyPage.focus(cell: parentCell)
            parentCell.surveyPage.scrollToCell(cell: parentCell)
        }
    
    }
    
    // TODO: Only jump to next question is every previous required question is completed.
    
    
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
