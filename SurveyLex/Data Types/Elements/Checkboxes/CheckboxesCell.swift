//
//  CheckboxesCell.swift
//  SurveyLex Demo
//
//  Created by Jia Rui Shan on 2019/6/30.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

/// A subclass of `SurveyElementCell` that displays the top half of a checkbox question. The bottom half, represented by a `CheckboxesBottomCell`, will be expanded when this cell is focused.
class CheckboxesCell: SurveyElementCell {
    
    var checkboxData: CheckBoxes!
    private var title: UITextView!
    private var checkboxTable: CheckboxTable!
    
    /// A checkboxes question is considered completed if it's modified at least once.
    override var completed: Bool {
        return checkboxData.modified
    }
    
    /// Custom cell below for checkbox cell.
    override var cellBelow: SurveyElementCell {
        return bottomCell
    }
    
    override var hasCellBelow: Bool {
        return true
    }
    
    
    // UI elements responsible for the expansion trigger.
    private var expansionIndicator: UIImageView!
    private var bottomCell: CheckboxesBottomCell!
    private var expandButton: UIButton!
    
    // Quick access.
    private var allowMenuCollapse: Bool {
        return checkboxData.parentView!.survey.allowMenuCollapse
    }
    
    /// Whether expansion events for the bottom row are suppressed. This boolean variable is necessary to prevent the expansion event from being triggered twice when the user taps on the expansion button when the top cell is not yet focused, resulting in the first expansion event sent on `focus()` and the second event sent on `buttonActionTriggered`.
    private var suppressExpansion = false

    
    // MARK: UI Setup
    
    init(checkboxes: CheckBoxes) {
        super.init()
        
        checkboxData = checkboxes
        title = makeTitle()
        expansionIndicator = makeExpansionIndicator()
        bottomCell = CheckboxesBottomCell(checkboxes: checkboxes, topCell: self)
    }
    
    private func makeTitle() -> UITextView {
        let titleText = UITextView()
        titleText.text = checkboxData.title
        titleText.format(as: .title, theme: checkboxData.theme)
        titleText.textColor = .black
        titleText.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleText)
        
        titleText.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor,
                                        constant: SIDE_PADDING).isActive = true
        titleText.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor,
                                         constant: -SIDE_PADDING).isActive = true
        titleText.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor,
                                       constant: 20).isActive = true
        return titleText
    }
    
    private func makeExpansionIndicator() -> UIImageView {
        let button = UIButton()
        button.contentVerticalAlignment = .top
        button.titleLabel?.font = .systemFont(ofSize: 16.5, weight: .medium)
        button.setTitleColor(.darkGray, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        addSubview(button)
        
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        button.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor,
                                     constant: SIDE_PADDING).isActive = true
        button.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor,
                                      constant: -SIDE_PADDING).isActive = true
        
        button.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 2).isActive = true
        button.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
        
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
        expand.contentMode = .scaleAspectFit
        if checkboxData.bottomCellExpanded {
            expand.transform = CGAffineTransform(rotationAngle: .pi - .tinyPositive)
        }
        expand.translatesAutoresizingMaskIntoConstraints = false
        expand.widthAnchor.constraint(equalToConstant: 22).isActive = true
        expand.heightAnchor.constraint(equalToConstant: 22).isActive = true
        insertSubview(expand, belowSubview: button)
        
        expand.centerXAnchor.constraint(equalTo: button.centerXAnchor).isActive = true
        expand.centerYAnchor.constraint(equalTo: button.centerYAnchor).isActive = true
        
        return expand
    }
    
    // MARK: Button event handlers
    
    @objc private func buttonPressed(_ sender: UIButton) {
        UIView.transition(with: self,
                          duration: 0.1,
                          options: .transitionCrossDissolve,
                          animations: {
                            self.expansionIndicator.image = #imageLiteral(resourceName: "expand_pressed")
        },
                          completion: nil)
    }
    
    @objc private func buttonLifted(_ sender: UIButton) {
        UIView.transition(with: self,
                          duration: 0.15,
                          options: .transitionCrossDissolve,
                          animations: {
                            self.expansionIndicator.image = #imageLiteral(resourceName: "expand")
        }, completion: nil)
        
    }
    
    @objc private func buttonEventTriggered(_ sender: UIButton) {
        
        guard !suppressExpansion else {
            return
        }
        
        suppressExpansion = true
        surveyPage.focus(cell: self)
        suppressExpansion = false
        
        toggleExpansion(sender)
    }
    
    private func toggleExpansion(_ sender: UIButton) {
        
        if !allowMenuCollapse {
            sender.isUserInteractionEnabled = false
            UIView.transition(with: self,
                              duration: 0.25,
                              options: .transitionCrossDissolve,
                              animations: {
                                self.expansionIndicator.image = #imageLiteral(resourceName: "disabled 3x")
                              }, completion: nil)
        }
        
        bottomCell.expanded.toggle()
        checkboxData.bottomCellExpanded = bottomCell.expanded
        self.surveyPage.expandOrCollapse(from: self)
//        bottomCell.focus()
        if self.bottomCell.expanded {
            UIView.animate(withDuration: 0.25) {
                //  This is stupid but you need to set the angle to a value slightly less than π for the indicator to always rotate on the right side. Rotation animations always takes the path that requires the least motion.
                self.expansionIndicator.transform = CGAffineTransform(rotationAngle: .pi - .tinyPositive)
            }
            
        } else if allowMenuCollapse {
            UIView.animate(withDuration: 0.25) {
                self.expansionIndicator.transform = CGAffineTransform(rotationAngle: 0)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func focus() {
        super.focus()
        
        bottomCell.focus()
        
        if !checkboxData.modified && !bottomCell.expanded && !suppressExpansion {
            toggleExpansion(expandButton)
            
            // Temporarily set `suppressExpansion` to true to block the button press event from being triggered.
            suppressExpansion = true
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.suppressExpansion = false
            }
        }
    }
    
    override func unfocus() {
        super.unfocus()
        
        bottomCell.unfocus()
    }

}
