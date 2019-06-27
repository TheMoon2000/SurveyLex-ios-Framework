//
//  FragmentTableController.swift
//  SurveyLex
//
//  Created by Jia Rui Shan on 2019/5/13.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

/// A subclass of `UITableViewController` designed to present a single survey fragment (page).
class FragmentTableController: UITableViewController {
    
    /// The native `Fragment` representation of the content of this fragment.
    var fragmentData: Fragment!
    
    /// The parent `SurveyViewController` which will display this fragment as one of its pages.
    var surveyViewController: SurveyViewController?
    
    /// An array of `SurveyElementCell`s in order, each representing a survey element in the fragment.
    var contentCells = [SurveyElementCell]()

    /// A helper variable that controls whether updates to `focusedRow` will trigger any side effects.
    private var focusedRowResponse = true
    
    /// The index of the row that is currently focused, as seen by the user.
    var focusedRow = -1 {
        didSet (oldValue) {
            if !focusedRowResponse { return }
            if focusedRow == oldValue { return }
            
            if focusedRow != -1 {
                let index = IndexPath(row: focusedRow, section: 0)
                if focusedRow < tableView.numberOfRows(inSection: 0) {
                    var pos = UITableView.ScrollPosition.middle
                    let cell = contentCells[focusedRow]
                    if cell.frame.height > tableView.frame.height || tableView.numberOfRows(inSection: 0) == 1 {
                        pos = .top
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        self.tableView.scrollToRow(at: index, at: pos, animated: true)
                    }
                }
                if let cell = tableView.cellForRow(at: index) as? SurveyElementCell {
                    UIView.animate(withDuration: 0.2) { cell.focus() }
                } else if focusedRow >= tableView.numberOfRows(inSection: 0) && allCompleted {
                    focusedRowResponse = false
                    focusedRow = oldValue
                    focusedRowResponse = true
                    surveyViewController?.flipPageIfNeeded()
                }
            }
            if oldValue != -1 {
                if let cell = tableView.cellForRow(at: IndexPath(row: oldValue, section: 0)) as? SurveyElementCell {
                    UIView.animate(withDuration: 0.2) { cell.unfocus() }
                }
            }
        }
    }
    
    // /// The maximum value `focusedRow` has taken.
    
    
    /// Convenient shortcut that returns the fragment index of the current page.
    var fragmentIndex: Int {
        return fragmentData.index
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !surveyViewController!.visitedFragments.contains(self) {
            surveyViewController?.visitedFragments.insert(self)
            DispatchQueue.main.async {
                self.focusedRow = 0
            }
        } else if fragmentData.questions.count == 1 {
            DispatchQueue.main.async {
                self.focusedRow = 0
            }
        } else if focusedRow != -1 {
            DispatchQueue.main.async {
                self.contentCells[self.focusedRow].focus()
            }
        }
    }
    
     /// A boolean array with the completion status of each survey element. This information is distributed to individual survey elements.
    private var completion: [(completed: Bool, required: Bool)] {
        return fragmentData.questions.map { ($0.completed, $0.isRequired) }
    }
    
    /// Whether the user can swipe right and proceed with the next page. That is, all the required questions have been completed.
    var unlocked: Bool {
        return !fragmentData.questions.contains { !$0.completed && $0.isRequired }
    }
    
    /// Whether all questions (required and optional) are completed by the user.
    var allCompleted: Bool {
        return !fragmentData.questions.contains { !$0.completed }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        precondition(fragmentData != nil)
        
        contentCells = fragmentData.questions.map { question in
            let cell = question.makeContentCell()
            cell.surveyPage = self
            return cell
        }
        
        fragmentData.questions.forEach { $0.parentView = surveyViewController }
        
        tableView.allowsSelection = true
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.keyboardDismissMode = .interactive
        
        view.backgroundColor = UIColor(white: 0.94, alpha: 1)
    }
    
    func focus(cell: SurveyElementCell) {
        if let row = self.contentCells.firstIndex(of: cell) {
            UIView.animate(withDuration: 0.2) {
                self.focusedRow = row
            }
        } else {
            preconditionFailure("cell not found")
        }
    }
    
    func isCellFocused(cell: SurveyElementCell) -> Bool {
        let row = tableView.indexPath(for: cell)?.row ?? -1
        return row == focusedRow
    }


    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contentCells.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Not very memory efficient, but we can assume that a survey
        // will never have too many question on the same page.
        
        if indexPath.row == focusedRow {
            contentCells[indexPath.row].focus()
        } else {
            contentCells[indexPath.row].unfocus()
        }
        
        return contentCells[indexPath.row]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        focusedRow = indexPath.row
    }
    
    /// Fixes the bug with device rotation by resetting the content offset.
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        let spaceBelow = tableView.contentSize.height - tableView.contentOffset.y
        let upwardOffset = max(0, size.height - spaceBelow)
        let proposedOffset = max(0, tableView.contentOffset.y - upwardOffset)
        coordinator.animate(alongsideTransition: {context in
            self.tableView.contentOffset = CGPoint(x: 0.0, y: proposedOffset)
        }, completion: nil)
    }

}
