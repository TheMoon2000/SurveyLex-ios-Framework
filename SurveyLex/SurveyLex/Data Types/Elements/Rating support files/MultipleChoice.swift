//
//  MultipleChoiceView.swift
//  SurveyLex
//
//  Created by Jia Rui Shan on 2019/5/15.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class MultipleChoiceView: UITableView, UITableViewDelegate, UITableViewDataSource {

    var responseDelegate: RatingResponseDelegate?
    
    var choices = [String]() {
        didSet {
            self.reloadData()
        }
    }

    init(choices: [String], delegate: RatingResponseDelegate) {
        super.init(frame: .zero, style: .plain)
        tableFooterView = UIView(frame: .zero)
        self.delegate = self
        self.responseDelegate = delegate
        self.dataSource = self
        self.isScrollEnabled = false
        self.choices = choices
        separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        estimatedRowHeight = 60
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return choices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = MultipleChoiceCell()
        cell.titleText = choices[indexPath.row]
        cell.tintColor = BLUE_TINT
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        responseDelegate?.didSelectRow(row: indexPath.row)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
