//
//  RadioGroupCell.swift
//  SurveyLex
//
//  Created by Jia Rui Shan on 2019/6/23.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

/// A subclass of `SurveyElementCell` that display a radio group question.
class RadioGroupCell: SurveyElementCell {
    
    /// Shortcut for the completion status of the cell, accessible from the `SurveyElementCell` class.
    override var completed: Bool {
        return radioGroup.completed
    }
    
    /// Custom cell below for radio group cell.
    override var cellBelow: SurveyElementCell {
        return bottomCell
    }
    
    /// The `RadioGroup` instance which the current cell is presenting.
    var radioGroup: RadioGroup!
    
    /// The text view for the title of the radio group question.
    var title: UITextView!
    
    /// The table subview embedded in this cell.
    private var choiceTable: MultipleChoiceView!
    
    private var expansionIndicator: UIImageView!
    private var bottomCell: RadioGroupBottomCell!
    private var expandButton: UIButton!
    
    /// Whether expansion events for the bottom row are suppressed.
    private var suppressExpansion = false
    
    init(radioGroup: RadioGroup) {
        super.init()
        self.radioGroup = radioGroup
        
        title = makeTitleView()
        expansionIndicator = makeExpansionIndicator()
        bottomCell = RadioGroupBottomCell(radioGroup: radioGroup, topCell: self)
    }
    
    // MARK: Main components (title & radio group)
    
    private func makeTitleView() -> UITextView {
        let titleText = UITextView()
        titleText.text = radioGroup.title
        titleText.format(as: .title)
        titleText.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleText)
        
        titleText.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor,
                                      constant: 20).isActive = true
        titleText.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor,
                                        constant: SIDE_PADDING).isActive = true
        titleText.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor,
                                         constant: -SIDE_PADDING).isActive = true
        return titleText
    }
    
    private func makeExpansionIndicator() -> UIImageView {
        let button = UIButton()
        button.contentVerticalAlignment = .top
        button.setTitle("Tap to Expand", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16.5, weight: .medium)
        button.setTitleColor(.darkGray, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        addSubview(button)
        
        button.heightAnchor.constraint(equalToConstant: 65).isActive = true
        button.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor,
                                     constant: SIDE_PADDING).isActive = true
        button.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor,
                                      constant: -SIDE_PADDING).isActive = true
        
        button.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 15).isActive = true
        button.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -10).isActive = true
        
        button.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(buttonLifted(_:)), for: [
            .touchUpInside,
            .touchUpOutside,
            .touchCancel,
            .touchDragOutside,
            .touchDragExit])
        button.addTarget(self, action: #selector(buttonEventTriggered(_:)), for: .touchUpInside)
        
        expandButton = button
        
        
        let expand = UIImageView(image: #imageLiteral(resourceName: "expand"))
        expand.transform = CGAffineTransform(rotationAngle: .pi)
        expand.contentMode = .scaleAspectFit
        expand.translatesAutoresizingMaskIntoConstraints = false
        expand.widthAnchor.constraint(equalToConstant: 19).isActive = true
        expand.heightAnchor.constraint(equalToConstant: 19).isActive = true
        insertSubview(expand, belowSubview: button)

        expand.centerXAnchor.constraint(equalTo: button.centerXAnchor).isActive = true
        expand.bottomAnchor.constraint(equalTo: button.bottomAnchor, constant: -10).isActive = true
        
        return expand
    }
    
    // MARK: Button event handlers
    
    @objc private func buttonPressed(_ sender: UIButton) {
        UIView.transition(with: self,
                          duration: 0.1,
                          options: .transitionCrossDissolve,
                          animations: {
                            self.expansionIndicator.image = #imageLiteral(resourceName: "expand_pressed")
                            sender.setTitleColor(.lightGray, for: .normal)
                          },
                          completion: nil)
    }
    
    @objc private func buttonLifted(_ sender: UIButton) {
        UIView.transition(with: self,
                          duration: 0.15,
                          options: .transitionCrossDissolve,
                          animations: {
                            self.expansionIndicator.image = #imageLiteral(resourceName: "expand")
                            sender.setTitleColor(.darkGray, for: .normal)
                          }, completion: nil)
        
    }
    
    @objc private func buttonEventTriggered(_ sender: UIButton) {
        
        guard !suppressExpansion else {
            return
        }
        
        suppressExpansion = true
        surveyPage?.focus(cell: self)
        suppressExpansion = false
        
        toggleExpansion(sender)
    }
    
    private func toggleExpansion(_ sender: UIButton) {
        
        bottomCell.expanded.toggle()
        self.surveyPage?.expandOrCollapse(from: self)
        bottomCell.focus()
        if self.bottomCell.expanded {
            UIView.animate(withDuration: 0.25) {
                //  This is stupid but you need to set the angle to a negative value for the indicator to always rotate on the right side. Rotation animations always takes the path that requires the least motion.
                self.expansionIndicator.transform = CGAffineTransform(rotationAngle: -0.00001)
                sender.setTitle("Tap to Collapse", for: .normal)
            }
        } else {
            UIView.animate(withDuration: 0.25) {
                self.expansionIndicator.transform = CGAffineTransform(rotationAngle: .pi)
                sender.setTitle("Tap to Expand", for: .normal)
            }
        }
    }
    
    // MARK: Customized focus / unfocus appearance
    
    override func focus() {
        super.focus()
      
        bottomCell.focus()
        
        if !radioGroup.completed && !bottomCell.expanded && !suppressExpansion {
            toggleExpansion(expandButton)
            
            // Temporarily set `hasAutoExpanded` to true to block the button press event from being triggered.
            suppressExpansion = true
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.suppressExpansion = false
            }
        }
        
    }
    
    override func unfocus() {
        super.unfocus()
        
        bottomCell.unfocus()
        
//        DispatchQueue.main.async {
//            self.surveyPage?.collapse(from: self)
//        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }


}
