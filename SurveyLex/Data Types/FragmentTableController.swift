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
    
    // MARK: - Custom instance variables
    
    /// An array of `SurveyElementCell`s in order, each representing a survey element in the fragment.
    var contentCells = [SurveyElementCell]()
    
    /// The index of the row that is currently focused, as seen by the user.
    var focusedRow = -1 {
        didSet (oldValue) {
            
            // Get the actual focused row.
            let topRow = focusedRow - focusedRow % 2
            
            if oldValue != -1 && topRow == oldValue - oldValue % 2 {
                return // The focus did not change, so exit
            }
            
            fragmentData.focusedRow = focusedRow
            
            if focusedRow != -1 {
                let index = IndexPath(row: focusedRow, section: 0)
                
                // Focus on the given cell.
                if focusedRow < tableView.numberOfRows(inSection: 0) {
                    var pos = UITableView.ScrollPosition.middle
                    if contentCells[focusedRow].frame.height > tableView.frame.height || tableView.numberOfRows(inSection: 0) == 1 {
                        pos = .top
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        self.tableView.scrollToRow(at: index, at: pos, animated: true)
                    }
                    
                    // We actually call focus() on the top cell.
                    UIView.animate(withDuration: 0.2) { self.contentCells[topRow].focus() }
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
                          options: .curveEaseInOut,
                          animations: {
                              self.navigationMenu.alpha = 1.0
                              self.navigationMenu.isUserInteractionEnabled = true
                          }, completion: nil)
        
        navigationMenu.nextButton.isEnabled = self.unlocked
        
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
            } else {
                self.focusedRow = self.fragmentData.focusedRow
            }
            
        }
    }
    
    // MARK: - Scrolling helper functions
    func scrollToRow(row: Int) {
        var pos = UITableView.ScrollPosition.middle
        let cell = self.contentCells[row]
        if cell.frame.height > self.tableView.frame.height || self.tableView.numberOfRows(inSection: 0) == 1 {
            pos = .top
        }
        self.tableView.scrollToRow(at: IndexPath(row: row, section: 0), at: pos, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.contentCells[row].focus()
        }
    }
    
    func scrollToCell(cell: SurveyElementCell) {
        if let index = contentCells.firstIndex(of: cell) {
            scrollToRow(row: index)
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
        tableView.contentInset.bottom = FragmentMenu.height
        
        // View setup
        view.backgroundColor = UIColor(white: 0.95, alpha: 1)
        
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
        
        self.navigationMenu.isHidden = false
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
                        
            self.tableView.reloadRows(at: [targetIndex], with: .automatic)
            
            // Scroll to the newly expanded row. We need to wait for the expansion animation to finish before scrolling to the row.
            if self.contentCells[row + 1].expanded {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    self.scrollToRow(row: row + 1)
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
        
        if indexPath.section == 1 {
            let cell = UITableViewCell()
            cell.addSubview(navigationMenu)
            cell.selectionStyle = .none
            navigationMenu.translatesAutoresizingMaskIntoConstraints = false

            
            navigationMenu.leftAnchor.constraint(equalTo: cell.leftAnchor).isActive = true
            navigationMenu.rightAnchor.constraint(equalTo: cell.rightAnchor).isActive = true
            navigationMenu.topAnchor.constraint(equalTo: cell.topAnchor).isActive = true
            navigationMenu.bottomAnchor.constraint(equalTo: cell.bottomAnchor).isActive = true
            return cell
        }
        
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
                print("fragment \(self.pageIndex) uploaded")
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
        uploadResponse()
        
    }
    
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
