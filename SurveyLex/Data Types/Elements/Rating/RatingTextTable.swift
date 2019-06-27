//
//  RatingTextTable.swift
//  SurveyLex
//
//  Created by Jia Rui Shan on 2019/6/20.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class RatingTextTable: UITableView, UITableViewDelegate, UITableViewDataSource {
    
    var selectionIndex: Int?
    
    override var intrinsicContentSize: CGSize {
        self.reloadData()
        return contentSize
    }
    
    /// The rating information which the table view is presenting
    var rateInfo = [(value: String, text: String)]()
    
    init(rateInfo: [(value: String, text: String)]) {
        super.init(frame: .zero, style: .plain)
        tableFooterView = UIView(frame: .zero)
        self.delegate = self
        self.dataSource = self
        self.rateInfo = rateInfo
//        separatorInset = .zero
        self.separatorStyle = .none
        self.rowHeight = UITableView.automaticDimension
        self.register(RatingCell.classForCoder(),
                      forCellReuseIdentifier: "rateValue")
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "rateValue") as! RatingCell
        cell.titleText = rateInfo[indexPath.row].text
        print(cell.titleText)
        cell.tintColor = BLUE_TINT
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectionIndex = indexPath.row
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
