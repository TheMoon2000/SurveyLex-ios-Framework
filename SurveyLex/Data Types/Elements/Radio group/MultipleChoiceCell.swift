//
//  MultipleChoiceCell.swift
//  SurveyLex
//
//  Created by Jia Rui Shan on 2019/6/20.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

/// A cell in a `MultipleChoice` table view.
class MultipleChoiceCell: UITableViewCell {
    
    private var radioCircle: RadioCircle!
    private var titleLabel: UILabel!
    private var highlightBackground: UIView!
    
    var titleText: String = "" {
        didSet {
            titleLabel.text = titleText
        }
    }
    
    override var tintColor: UIColor! {
        didSet {
            radioCircle.tintColor = tintColor
        }
    }
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        highlightBackground = {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
            view.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            view.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            view.topAnchor.constraint(equalTo: topAnchor).isActive = true
            view.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            
            return view
        }()
        
        makeRadioCircle()
        makeLabel()
        
        highlightBackground.backgroundColor = .white
    }
    
    private func makeRadioCircle() {
        let circle = RadioCircle()
        circle.isOpaque = false
        circle.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(circle)
        
        circle.widthAnchor.constraint(equalToConstant: 24).isActive = true
        circle.heightAnchor.constraint(equalToConstant: 24).isActive = true
        circle.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor,
                                      constant: -SIDE_PADDING).isActive = true
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
        
        label.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor,
                                    constant: 20).isActive = true
        label.topAnchor.constraint(equalTo: topAnchor,
                                   constant: SIDE_PADDING).isActive = true
        label.bottomAnchor.constraint(equalTo: bottomAnchor,
                                      constant: -20).isActive = true
        label.rightAnchor.constraint(equalTo: radioCircle.leftAnchor,
                                     constant: -SIDE_PADDING).isActive = true
        titleLabel = label
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        self.radioCircle.selected = selected

        let transition = {
            self.highlightBackground.backgroundColor = selected ? SELECTION : UIColor.white
        }
        
        UIView.transition(with: self, duration: 0.2, options: .curveEaseOut, animations: {
            transition()
        }, completion: nil)
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
