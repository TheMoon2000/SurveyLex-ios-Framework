//
//  FragmentTableController.swift
//  SurveyLex
//
//  Created by Jia Rui Shan on 2019/5/13.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class FragmentTableController: UITableViewController, FragmentViewController {
    
    var fragmentData: Fragment!
    
    var contentCells = [UITableViewCell]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        precondition(fragmentData != nil)
        
        contentCells = fragmentData.questions.map { $0.contentCell }

        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        tableView.tableFooterView = nil
        
        view.backgroundColor = UIColor(white: 0.94, alpha: 1)
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contentCells.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return contentCells[indexPath.row].intrinsicContentSize.height
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return contentCells[indexPath.row]
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    var fragmentIndex: Int {
        return fragmentData.index
    }

}
