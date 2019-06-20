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
//    var selectionIndex: Int?
    
    var selectedRow: Int?
    
    override var intrinsicContentSize: CGSize {
        self.reloadData()
        if let row = selectedRow {
            self.selectRow(at: IndexPath(row: row, section: 0), animated: false, scrollPosition: .none)
        }
        return contentSize
    }
    
    /// The rating information which the table view is presenting
    var rateInfo = [(value: String, text: String)]()

    init(rateInfo: [(value: String, text: String)], delegate: RatingResponseDelegate) {
        super.init(frame: .zero, style: .plain)
        tableFooterView = UIView(frame: .zero)
        self.delegate = self
        self.responseDelegate = delegate
        self.dataSource = self
        self.allowsMultipleSelection = false
        self.rateInfo = rateInfo
        separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.rowHeight = UITableView.automaticDimension
        self.register(MultipleChoiceCell.classForCoder(),
                      forCellReuseIdentifier: "choice")
    }
    
    // Essential for calculating the correct height for the cells
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let cell = self.tableView(tableView, cellForRowAt: indexPath)
        let width = UIScreen.main.bounds.width
        return cell.preferredHeight(width: width - 55)
    }
    
    // Datasource methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rateInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "choice") as! MultipleChoiceCell
        cell.titleText = rateInfo[indexPath.row].text
        cell.tintColor = BLUE_TINT
        return cell
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRow = indexPath.row
        responseDelegate?.didSelectRow(row: indexPath.row)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}

extension UIView {
    
    /// Extension method that finds the optimal height for the view, given its current width.
    func preferredHeight(width: CGFloat) -> CGFloat {
        let widthConstraint = self.widthAnchor.constraint(equalToConstant: width)
        self.addConstraint(widthConstraint)
        let height = systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        self.removeConstraint(widthConstraint)
        return height
    }
}
