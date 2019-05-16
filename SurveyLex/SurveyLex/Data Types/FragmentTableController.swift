//
//  FragmentTableController.swift
//  SurveyLex
//
//  Created by Jia Rui Shan on 2019/5/13.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class FragmentTableController: UITableViewController {
    
    var fragmentData: Fragment!
    var surveyViewController: SurveyViewController?
    var contentCells = [UITableViewCell]()
    var completed = false
    
    /// A boolean array with the completion status of each survey element.
    /// This information is distributed to individual survey elements.
    /// - Parameters:
    private var completion: [(completed: Bool, required: Bool)] {
        return fragmentData.questions.map { ($0.completed, $0.isRequired) }
    }
    
    /// Whether the user can swipe right and proceed with the next page.
    var unlocked: Bool {
        return !fragmentData.questions.contains { !$0.completed && $0.isRequired }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        precondition(fragmentData != nil)
        
        contentCells = fragmentData.questions.map { $0.makeContentCell() }
        fragmentData.questions.forEach { $0.parentView = surveyViewController }
                
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView(frame: .zero)
        
        
        view.backgroundColor = UIColor(white: 0.94, alpha: 1)
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
        
        return contentCells[indexPath.row]
    }
    
    var fragmentIndex: Int {
        return fragmentData.index
    }
    
    func updateCompletionStatusByQuestions() {
        self.completed = unlocked
    }

}
