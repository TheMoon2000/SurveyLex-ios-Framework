//
//  FragmentTableController.swift
//  SurveyLex
//
//  Created by Jia Rui Shan on 2019/5/13.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

/// A subclass of `UITableViewController` designed to present multiple questions on a page.
class FragmentTableController: UITableViewController, SurveyPage {
    
    // Protocol requirements
    
    var fragmentData: Fragment!
    
    var surveyViewController: SurveyViewController?
    
    var completed: Bool {
        return !fragmentData.questions.contains { !$0.completed }
    }
    
    var unlocked: Bool {
        return !fragmentData.questions.contains { !$0.completed && $0.isRequired }
    }
    
    //
    //
    // -------------------------
    //
    //
    
    // Custom instance variables
    
    /// An array of `SurveyElementCell`s in order, each representing a survey element in the fragment.
    var contentCells = [SurveyElementCell]()

    /// A helper variable that controls whether updates to `focusedRow` will trigger any side effects.
    private var focusedRowResponse = true
    
    /// Completion status of every question.
    private var completion: [(completed: Bool, required: Bool)] {
        return fragmentData.questions.map { ($0.completed, $0.isRequired) }
    }
    
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
                    UIView.animate(withDuration: 0.2) { cell.focus() }
                }
            }
            if oldValue != -1 {
                UIView.animate(withDuration: 0.2) {
                    self.contentCells[oldValue].unfocus()
                }
            }
        }
    }
    
    
    /// Whether the view has appeared at least once.
    private var viewAppeared = false
    
    /// Whether the content cells are loaded.
    var loadedContentCells = false {
        didSet (oldValue) {
            // If the content cells are loaded for the first time, and the view has already appeared, then we run `appearHandler()`.
            if !oldValue && viewAppeared {
                self.appearHandler()
            }
        }
    }
    
    /// Usually, the view is already loaded by the time it appears. However, if that didn't happen, then we won't call `appearHandler()` until the view has been loaded.
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewAppeared = true
        
        // Update the navigation bar
        surveyViewController?.fragmentIndex = pageIndex
        
        if !loadedContentCells { return }
        
        appearHandler()
    }
    /// This function will run as soon as both `viewAppeared` and `loadedContentCells` are `true`.
    private func appearHandler() {
        
        if !viewAppeared || !loadedContentCells { return }
        
        DispatchQueue.main.async {
            if !self.surveyViewController!.visited.contains(self.pageIndex) {
                self.surveyViewController?.visited.insert(self.pageIndex)
                self.focusedRow = 0
            } else if self.fragmentData.questions.count == 1 {
                self.focusedRow = 0
            } else if self.focusedRow != -1 && false {
                self.contentCells[self.focusedRow].focus()
            }
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        precondition(fragmentData != nil)
        
        tableView.allowsSelection = true
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.keyboardDismissMode = .interactive
        
        view.backgroundColor = UIColor(white: 0.94, alpha: 1)
        
        let label = insertLoadingLabel()
//        tableView.isHidden = true
        
        for question in fragmentData.questions {
            question.parentView = surveyViewController
            
            let cell = question.makeContentCell()
            cell.surveyPage = self
            cell.unfocus()
            contentCells.append(cell)
        }
        
        DispatchQueue.main.async {
            self.loadSurveyElements()
            label.isHidden = true
//            self.tableView.isHidden = false
            self.loadedContentCells = true
        }
    }
    
    private func insertLoadingLabel() -> UILabel {
        let label = UILabel()
        label.text = "Loading content..."
        label.textColor = .gray
        label.font = .systemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        tableView.insertSubview(label, at: 0)
        
        label.centerXAnchor.constraint(equalTo: tableView.safeAreaLayoutGuide.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: tableView.safeAreaLayoutGuide.centerYAnchor,
                                       constant: -5).isActive = true
        
        return label
    }
    
    func loadSurveyElements() {
        tableView.reloadSections(IndexSet(arrayLiteral: 0), with: .none)
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
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let cell = contentCells[indexPath.row]
        let width = UIScreen.main.bounds.width - 55
        let preferred = cell.preferredHeight(width: width)
        return preferred
    }
 
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Not very memory efficient, but we can assume that a survey
        // will never have too many question on the same page.
        
        /*
        if indexPath.row == focusedRow {
            contentCells[indexPath.row].focus()
        } else {
            contentCells[indexPath.row].unfocus()
        }*/
        
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
//            self.tableView.reloadData()
        }, completion: nil)
    }

}
