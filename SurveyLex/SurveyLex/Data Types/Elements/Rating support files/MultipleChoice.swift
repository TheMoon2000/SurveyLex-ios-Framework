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
    var selectionIndex: Int?
    
    override var intrinsicContentSize: CGSize {
        return contentSize
    }
    
    var rating: Rating!


    init(ratingQuestion: Rating, delegate: RatingResponseDelegate) {
        super.init(frame: .zero, style: .plain)
        tableFooterView = UIView(frame: .zero)
        self.delegate = self
        self.responseDelegate = delegate
        self.dataSource = self
        self.rating = ratingQuestion
        separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.rowHeight = UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let cell = self.tableView(tableView, cellForRowAt: indexPath)
        return cell.preferredHeight()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rating.choices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = MultipleChoiceCell()
        cell.titleText = rating.choices[indexPath.row]
        cell.tintColor = BLUE_TINT
        if let index = selectionIndex {
            cell.setSelected(indexPath.row == index, animated: false)
        }
        return cell
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectionIndex = indexPath.row
        responseDelegate?.didSelectRow(row: indexPath.row)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}

extension UIView {
    
    /// Extension method that finds the optimal height for the view, given its current width.
    func preferredHeight() -> CGFloat {
        let widthConstraint = self.widthAnchor.constraint(equalToConstant: frame.width)
        self.addConstraint(widthConstraint)
        let height = systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        self.removeConstraint(widthConstraint)
        return height
    }
}
