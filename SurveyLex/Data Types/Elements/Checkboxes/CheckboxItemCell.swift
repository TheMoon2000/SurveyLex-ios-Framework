//
//  CheckboxItemCell.swift
//  SurveyLex Demo
//
//  Created by Jia Rui Shan on 2019/6/30.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class CheckboxItemCell: UITableViewCell {
    
    var checkboxesData: CheckBoxes!
    var checkbox: UICheckbox!
    weak var titleLabel: UILabel!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        checkbox = makeCheckbox()
        titleLabel = makeTitle()
    }
    
    private func makeCheckbox() -> UICheckbox {
        let checkbox = UICheckbox()
        checkbox.format(type: .square)
        checkbox.isUserInteractionEnabled = false
        checkbox.translatesAutoresizingMaskIntoConstraints = false
        checkbox.widthAnchor.constraint(equalToConstant: 20).isActive = true
        checkbox.heightAnchor.constraint(equalToConstant: 20).isActive = true
        addSubview(checkbox)
        
        checkbox.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 12).isActive = true
        checkbox.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor,
                                       constant: SIDE_PADDING + 2).isActive = true
        
        return checkbox
    }
    
    private func makeTitle() -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        
        label.leftAnchor.constraint(equalTo: checkbox.rightAnchor,
                                        constant: 20).isActive = true
        label.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor,
                                         constant: -SIDE_PADDING).isActive = true
        label.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor,
                                       constant: 9).isActive = true
        let bottomConstraint = label.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -11)
        bottomConstraint.priority = .init(999)
        bottomConstraint.isActive = true
        
        return label
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
