//
//  RatingCell.swift
//  SurveyLex
//
//  Created by Jia Rui Shan on 2019/6/20.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class RatingCell: UITableViewCell {
    
    private var titleLabel: UILabel!
    
    var titleText: String = "" {
        didSet {
            titleLabel.text = titleText
        }
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                titleLabel?.font = .systemFont(ofSize: 18.5, weight: .medium)
                titleLabel?.textColor = .black
            } else {
                titleLabel?.font = .systemFont(ofSize: 17.5)
                titleLabel?.textColor = .lightGray
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        makeLabel()
    }
    
    private func makeLabel() {
        let label = UILabel()
        label.text = "-"
        label.numberOfLines = 8
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(label)
        
        label.leftAnchor.constraint(equalTo: self.leftAnchor,
                                    constant: 20).isActive = true
        label.topAnchor.constraint(equalTo: self.topAnchor,
                                   constant: 20).isActive = true
        label.bottomAnchor.constraint(equalTo: self.bottomAnchor,
                                      constant: -20).isActive = true
        label.rightAnchor.constraint(equalTo: self.rightAnchor,
                                     constant: -80).isActive = true
        titleLabel = label
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
//        self.isSelected = selected
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}

