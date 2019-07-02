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
    private var titleView: UITextView!

    init(title: String) {
        super.init(style: .default, reuseIdentifier: "checkbox")
        
        selectionStyle = .none
        checkbox = makeCheckbox()
        titleView = makeTitle(title)
    }
    
    private func makeCheckbox() -> UICheckbox {
        let checkbox = UICheckbox()
        checkbox.format(type: .square)
        checkbox.isUserInteractionEnabled = false
        checkbox.translatesAutoresizingMaskIntoConstraints = false
        checkbox.widthAnchor.constraint(equalToConstant: 19).isActive = true
        checkbox.heightAnchor.constraint(equalToConstant: 19).isActive = true
        addSubview(checkbox)
        
        checkbox.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor,
                                   constant: 10).isActive = true
        checkbox.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor,
                                       constant: SIDE_PADDING).isActive = true
        
        return checkbox
    }
    
    private func makeTitle(_ title: String) -> UITextView {
        let titleText = UITextView()
        titleText.text = title
        titleText.format(as: .plain)
        titleText.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleText)
        
        titleText.leftAnchor.constraint(equalTo: checkbox.rightAnchor,
                                        constant: 20).isActive = true
        titleText.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor,
                                         constant: -SIDE_PADDING).isActive = true
        titleText.topAnchor.constraint(equalTo: checkbox.topAnchor,
                                       constant: -3).isActive = true
        titleText.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor,
                                          constant: -10).isActive = true
        
        return titleText
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        checkbox.isChecked = selected
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
