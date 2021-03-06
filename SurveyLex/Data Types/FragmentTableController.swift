//
//  FragmentTableController.swift
//  SurveyLex
//
//  Created by Jia Rui Shan on 2019/5/13.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

/// A subclass of `UITableViewController` designed to present multiple questions on a page.
class FragmentTableController: UITableViewController, SurveyPage {
    
    // MARK: - Protocol requirements
    
    var fragmentData: Fragment!
    
    var surveyViewController: SurveyViewController?
    
    var completed: Bool {
        return !fragmentData.questions.contains { !$0.completed }
    }
    
    var unlocked: Bool {
        return !fragmentData.questions.contains { !$0.completed && $0.isRequired }
    }
    
    var navigationMenu: FragmentMenu {
        return surveyViewController!.navigationMenu
    }
    
    /// A `FragmentTableController` always allows swiping.
    var fixScreen: Bool {
        return false
    }
    
    // MARK: - Custom instance variables
    
    /// An array of `SurveyElementCell`s in order, each representing a survey element in the fragment.
    var contentCells = [SurveyElementCell]()
    
    /// The index of the row that is currently focused, as seen by the user. Setting the focused row will cause that row to be focused.
    var focusedRow = -1 {
        didSet (oldValue) {
            
            fragmentData.focusedRow = focusedRow

            // Get the actual focused row.
            let topRow = focusedRow - focusedRow % 2
            
            if oldValue != -1 && topRow == oldValue - oldValue % 2 {
                return // The focus did not change, so exit
            }
            
            if focusedRow != -1 {
                
                // Focus on the given cell.
                if focusedRow < tableView.numberOfRows(inSection: 0) {
                    if contentCells[topRow].cellBelow.expanded || !contentCells[topRow].hasCellBelow {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            self.scrollToRow(row: self.focusedRow)
                        }
                    }
                    
                    // We actually call focus() on the top cell.
                    UIView.animate(withDuration: 0.2) { self.contentCells[topRow].focus()
                    }
                }
            }
            if oldValue != -1 {
                UIView.animate(withDuration: 0.2) {
                    self.contentCells[oldValue - oldValue % 2].unfocus()
                }
            }
        }
    }
    
    /// Shortcut for accessing the survey data
    private var surveyData: SurveyData? {
        return surveyViewController?.surveyData
    }
    
    var uploaded: Bool = false {
        didSet {
            // The value of the local `uploaded` property should always be in sync with `fragmentData.uploaded`, which is preserved after exit.
            fragmentData.uploaded = uploaded
            
            // Since `uploaded` is set to `false` every time a value is changed within a fragment table, we can write code here to update the next button of the navigation menu.
            if !uploaded {
                DispatchQueue.main.async {
                    self.navigationMenu.nextButton.isEnabled = self.unlocked
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
        
        // Update the top navigation bar
        surveyViewController!.fragmentIndex = pageIndex
                
        // Update navigation menu display
        
        UIView.transition(with: navigationMenu,
                          duration: 0.3,
                          options: .curveEaseOut,
                          animations: {
                              self.navigationMenu.alpha = 1.0
                          }, completion: nil)
        
        navigationMenu.enableUserInteractions(true)
        
        navigationMenu.nextButton.isEnabled = self.unlocked
        navigationMenu.backButton.isEnabled = pageIndex > 0 || surveyViewController!.survey.showLandingPage
        
        appearHandler()
    }
    
    /// This function will run as soon as both `viewAppeared` and `loadedContentCells` are `true`.
    private func appearHandler() {
        
        if !viewAppeared || !loadedContentCells { return }
        
        DispatchQueue.main.async {
            if !self.surveyData!.visited.contains(self.pageIndex) {
                self.surveyData?.visited.insert(self.pageIndex)
                self.focusedRow = 0 // Focus on the first row if none is focused.
            } else if self.fragmentData.questions.count == 1 {
                self.focusedRow = 0
            } else if self.focusedRow != self.fragmentData.focusedRow {
                // Load the focused row from cache
                self.focusedRow = self.fragmentData.focusedRow
            } else {
                self.scrollToRow(row: self.focusedRow)
            }
            
        }
    }
    
    // MARK: - Scrolling helper functions
    
    /// Scroll the given row to the center of the view if it fits; otherwise, the top cell will be scrolled to the top of the screen.
    func scrollToRow(row: Int) {
        
        if row == -1 { return }
        
        let topRow = row - row % 2
        let bottomRow = topRow + 1
        
        func centerRow(row: Int) {
            var pos = UITableView.ScrollPosition.middle
            let cell = self.contentCells[row]
            if cell.frame.height > self.tableView.frame.height || self.tableView.numberOfRows(inSection: 0) == 1 {
                pos = .top
            }
            self.tableView.scrollToRow(at: IndexPath(row: row, section: 0), at: pos, animated: true)
        }
        
        if contentCells[bottomRow].expanded {
            let visibleHeight = self.view.frame.height - self.navigationMenu.height
            let topRemainingHeight = (visibleHeight - contentCells[bottomRow].frame.height) / 2
            if topRemainingHeight >= contentCells[topRow].frame.height {
                centerRow(row: bottomRow)
            } else {
                self.tableView.scrollToRow(at: IndexPath(row: topRow, section: 0), at: .top, animated: true)
            }
        } else {
            centerRow(row: topRow)
        }
    }
    
    func scrollToCell(cell: SurveyElementCell) {
        if let index = contentCells.firstIndex(of: cell) {
            if cell.frame.height <= self.tableView.frame.height {
                scrollToRow(row: index)
            }
        }
    }

    // MARK: - UI setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        precondition(fragmentData != nil)
        
        // Table setup
        tableView.allowsSelection = true
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .interactive
        tableView.contentInset.bottom = navigationMenu.height
        
        // Set background color
        view.backgroundColor = UIColor(white: 0.96, alpha: 1)
        
        let label: UILabel = {
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
        }()
                
        uploaded = fragmentData.uploaded
        
        // Load content cells
        DispatchQueue.main.async {
            self.loadSurveyElements()
            label.isHidden = true
            self.loadedContentCells = true
        }
    }
    
    
    func loadSurveyElements() {
        
        for question in fragmentData.questions {
            question.parentView = surveyViewController
            
            let cell = question.makeContentCell()
            cell.surveyPage = self // Essential
            cell.unfocus()
            contentCells.append(cell)
            cell.cellBelow.surveyPage = self // Essential
            
            // Restore the expansion status of the bottom cells
            if question.bottomCellExpanded {
                cell.cellBelow.expanded = true
            }
            
            contentCells.append(cell.cellBelow)
        }
        if fragmentData.questions.count == 1 {
            tableView.reloadSections(IndexSet(arrayLiteral: 0), with: .automatic)
        } else {
            tableView.reloadSections(IndexSet(arrayLiteral: 0), with: .none)
        }
    }
    
    // MARK: - Row actions
    
    func focus(cell: SurveyElementCell) {
        if let row = self.contentCells.firstIndex(of: cell) {
            self.focusedRow = row
        } else {
            preconditionFailure("cell not found")
        }
    }
    
    /**
     Updates the visibility status of the given cell if needed.
     
     - Parameters:
        - cell: A cell (with odd index) whose visibility status is to be updated.
     */
    func expandOrCollapse(from cell: SurveyElementCell) {
        if let row = self.contentCells.firstIndex(of: cell) {
            let targetIndex = IndexPath(row: row + 1, section: 0)
            
            self.focusedRow = row + 1
            self.tableView.reloadRows(at: [targetIndex], with: .automatic)
            
            // Scroll to the newly expanded row. We need to wait for the expansion animation to finish before scrolling to the row.
            if self.contentCells[row + 1].expanded {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    self.scrollToRow(row: row)
                }
            }
        }
    }
    
    func isCellFocused(cell: SurveyElementCell) -> Bool {
        let row = tableView.indexPath(for: cell)?.row ?? -1
        return (row - row % 2) == focusedRow - focusedRow % 2
    }


    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contentCells.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let cell = contentCells[indexPath.row]
        if !cell.expanded {
            return 0.0
        }
        
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let cell = contentCells[indexPath.row]

        if !cell.expanded { return 0.0 }
        
        
        let width = UIScreen.main.bounds.width - 55.0
        let preferred = cell.preferredHeight(width: width)
        return preferred
}
 
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Not very memory efficient, but we can assume that a survey
        // will never have too many question on the same page.
        
        if indexPath.row % 2 == 0 || contentCells[indexPath.row].expanded {
            return contentCells[indexPath.row]
        } else {
            return SurveyElementCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        focusedRow = indexPath.row
    }
    
    // MARK: - Response submission
    
    /// Uploads the current fragment to the server.
    func uploadResponse() {
        
        fragmentData.needsReupload = false
        
        // If no changes were made to the page, then no re-upload is needed.
        if uploaded { return }
        
        var responseRequest = URLRequest(url: API_RESPONSE)
        responseRequest.httpMethod = "POST"
        responseRequest.httpBody = try? fragmentData.fragmentJSON.rawData()
        responseRequest.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        let task = CUSTOM_SESSION.dataTask(with: responseRequest) {
            data, response, error in
            
            guard error == nil else {
                debugMessage("Fragment \(self.pageIndex) upload failed with error message: \(error!.localizedDescription)")
                self.uploadFailed()
                return
            }
            
            // Status code 200 means 'successful'
            if (try? JSON(data: data!).dictionary?["status"]?.int ?? 0) == 200 {
                self.uploaded = true
                self.uploadCompleted()
            } else {
                debugMessage("Server did not return status code 200 for fragment \(self.pageIndex)!")
                self.uploadFailed()
            }
        }
        
        task.resume()
    }
    
    /// Calls the upload method when moving to another page.
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // Upload the fragment to the server after it disappears from view.
        
        if surveyViewController!.survey.mode == .submission {
            uploadResponse()
        }
        
    }
    
    // MARK: -
    
    /// The focused row should still be focused and visible after orientation change.
    override func viewWillTransition(to size: CGSize, with coordinator:
        UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: {context in
            
            // We reload the table because the height of some rows will be different. Strangely, this row height adjustment mechanism didn't have any effect when I tested it on iOS simulators.
            self.tableView.reloadData()
            // Scroll to the current row
            self.tableView.scrollToRow(at: IndexPath(row: self.focusedRow, section: 0), at: .none, animated: false)
        }, completion: nil)
    }

}
