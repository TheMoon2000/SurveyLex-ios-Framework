//
//  MultipleChoiceCell.swift
//  SurveyLex
//
//  Created by Jia Rui Shan on 2019/5/15.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class MultipleChoiceCell: UITableViewCell {
    
    private var radioCircle: RadioCircle!
    private var titleLabel: UILabel!
    
    var titleText: String = "" {
        didSet {
            titleLabel.text = titleText
        }
    }
    
    override var isSelected: Bool {
        didSet {
            radioCircle.selected = isSelected
        }
    }
    
    override var tintColor: UIColor! {
        didSet {
            radioCircle.tintColor = tintColor
        }
    }
    
    
    init() {
        super.init(style: .default, reuseIdentifier: nil)
        selectionStyle = .none
        makeRadioCircle()
        makeLabel()
        contentView.backgroundColor = .white
        backgroundView = UIView()
        selectedBackgroundView = backgroundView
        backgroundView?.backgroundColor = .green
    }

    private func makeRadioCircle() {
        let circle = RadioCircle()
        circle.isOpaque = false
        circle.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(circle)
        
        circle.widthAnchor.constraint(equalToConstant: 24).isActive = true
        circle.heightAnchor.constraint(equalToConstant: 24).isActive = true
        circle.rightAnchor.constraint(equalTo: self.rightAnchor,
                                      constant: -20).isActive = true
        circle.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        radioCircle = circle
    }
    
    private func makeLabel() {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18)
        label.numberOfLines = 5
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(label)
        
        label.leftAnchor.constraint(equalTo: self.leftAnchor,
                                    constant: 20).isActive = true
        label.topAnchor.constraint(equalTo: self.topAnchor,
                                   constant: 20).isActive = true
        label.bottomAnchor.constraint(equalTo: self.bottomAnchor,
                                      constant: -20).isActive = true
        label.rightAnchor.constraint(equalTo: radioCircle.leftAnchor,
                                     constant: -30).isActive = true
        titleLabel = label
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        self.radioCircle.selected = selected
        UIView.transition(with: self, duration: 0.2, options: .curveEaseOut, animations: {
            self.contentView.backgroundColor = self.isSelected ? SELECTION : UIColor.white
        }, completion: nil)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
