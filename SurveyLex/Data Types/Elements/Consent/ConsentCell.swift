//
//  ConsentCell.swift
//  SurveyLex
//
//  Created by Jia Rui Shan on 2019/6/22.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

/// A subclass of `SurveyElementCell` that displays a consent form. Consent forms are designed to occupy an *entire* fragment.
class ConsentCell: SurveyElementCell {
    
    /// Shortcut for the completion status of the cell, accessible from the `SurveyElementCell` class.
    override var completed: Bool {
        return consentInfo.completed
    }
    
    /// The `Consent` object which the current cell is presenting.
    var consentInfo: Consent!
    
    private var title: UITextView!
    private var separator: UIView!
    private var bottomSeparator: UIView!
    private var consentText: UITextView!
    private var agreeButton: UIButton!
    private var checkbox: Checkbox!
    private var prompt: UITextView!

    init(consent: Consent) {
        super.init()
        
        self.consentInfo = consent
        
        backgroundColor = .white
        selectionStyle = .none
        
        title = makeTitle()
        separator = makeSeparator(top: true)
        consentText = makeConsentText()
        bottomSeparator = makeSeparator(top: false)
        checkbox = makeCheckbox()
        prompt = makePromptText()
        agreeButton = makeAgreeButton()
        
        checkboxPressed()
    }
    
    private func makeTitle() -> UITextView {
        let titleText = UITextView()
        titleText.isScrollEnabled = false
        titleText.attributedText = TextFormatter.formatted(consentInfo.title, type: .title)
        titleText.textAlignment = .center
        titleText.isEditable = false
        titleText.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleText)
        
        titleText.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor,
                                       constant: 40).isActive = true
        titleText.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor,
                                        constant: 32).isActive = true
        titleText.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor,
                                         constant: -32).isActive = true
        
        return titleText
    }
    
    private func makeSeparator(top: Bool) -> UIView {
        let separatorLine = UIView()
        separatorLine.backgroundColor = UIColor(white: 0.8, alpha: 1)
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        addSubview(separatorLine)
        
        separatorLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
        separatorLine.widthAnchor.constraint(equalToConstant: 60).isActive = true
        separatorLine.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor).isActive = true
        if top {
            separatorLine.topAnchor.constraint(equalTo: title.bottomAnchor,
                                               constant: 20).isActive = true
        } else {
            separatorLine.topAnchor.constraint(equalTo: consentText.bottomAnchor,
                                               constant: 20).isActive = true
        }
        
        return separatorLine
    }
    
    private func makeConsentText() -> UITextView {
        let consent = UITextView()
        consent.attributedText = TextFormatter.formatted(consentInfo.consentText, type: .consentText)
        consent.textAlignment = .left
        consent.isEditable = false
        consent.dataDetectorTypes = .link
        consent.linkTextAttributes[.foregroundColor] = BLUE_TINT
        consent.isScrollEnabled = false
        consent.translatesAutoresizingMaskIntoConstraints = false
        addSubview(consent)
        
        consent.topAnchor.constraint(equalTo: separator.bottomAnchor,
                                     constant: 20).isActive = true
        consent.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor,
                                      constant: 30).isActive = true
        consent.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor,
                                       constant: -30).isActive = true
        
        return consent
    }
    
    private func makeCheckbox() -> Checkbox {
        let check = Checkbox()
        check.checkmarkStyle = .square
        check.borderStyle = .square
        check.borderWidth = 1.5
        check.checkmarkSize = 0.56
        check.checkmarkColor = BLUE_TINT
        check.checkedBorderColor = DISABLED_BLUE
        check.uncheckedBorderColor = .init(white: 0.87, alpha: 1)
        check.translatesAutoresizingMaskIntoConstraints = false
        addSubview(check)
        
        check.widthAnchor.constraint(equalToConstant: 20).isActive = true
        check.heightAnchor.constraint(equalToConstant: 20).isActive = true
        check.leftAnchor.constraint(equalTo: consentText.leftAnchor,
                                    constant: 1).isActive = true
        check.topAnchor.constraint(equalTo: bottomSeparator.bottomAnchor,
                                   constant: 24).isActive = true
        
        check.addTarget(self, action: #selector(checkboxPressed), for: .valueChanged)
        
        return check
    }
    
    private func makePromptText() -> UITextView {
        let prompt = UITextView()
        prompt.attributedText = TextFormatter.formatted(consentInfo.prompt,
                                                        type: .subtitle)
        prompt.isScrollEnabled = false
        prompt.isEditable = false
        prompt.dataDetectorTypes = .link
        prompt.linkTextAttributes[.foregroundColor] = BLUE_TINT
        prompt.translatesAutoresizingMaskIntoConstraints = false
        addSubview(prompt)
        
        prompt.topAnchor.constraint(equalTo: checkbox.topAnchor,
                                    constant: -9).isActive = true
        prompt.leftAnchor.constraint(equalTo: checkbox.rightAnchor,
                                     constant: 15).isActive = true
        prompt.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor,
                                      constant: -40).isActive = true
        
        return prompt
    }
    
    private func makeAgreeButton() -> UIButton {
        let button = UIButton()
        button.setTitle("Agree & Continue", for: .normal)
        button.layer.cornerRadius = 4
        button.backgroundColor = BLUE_TINT
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.white, for: .normal)
        button.heightAnchor.constraint(equalToConstant: 49).isActive = true
        button.widthAnchor.constraint(equalToConstant: 220).isActive = true
        
        button.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchDown)
        button.addTarget(self,
                         action: #selector(buttonLifted(_:)),
                         for: [.touchCancel, .touchUpInside, .touchUpOutside, .touchDragExit])
        button.addTarget(self, action: #selector(agreed(_:)), for: .touchUpInside)
        
        addSubview(button)
        
        button.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor).isActive = true
        button.topAnchor.constraint(equalTo: prompt.bottomAnchor,
                                    constant: 32).isActive = true
        button.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor,
                                       constant: -40).isActive = true
        
        return button
    }
    
    @objc private func checkboxPressed() {
        if checkbox.isChecked {
            agreeButton.isEnabled = true
            agreeButton.backgroundColor = BLUE_TINT
        } else {
            agreeButton.isEnabled = false
            agreeButton.backgroundColor = DISABLED_BLUE
        }
        consentInfo.completed = checkbox.isChecked
        consentInfo.parentView?.reloadDatasource()
    }
    
    @objc private func buttonPressed(_ sender: UIButton) {
        sender.backgroundColor = BUTTON_PRESSED
    }
    
    @objc private func buttonLifted(_ sender: UIButton) {
        UIView.transition(with: sender,
                          duration: 0.15,
                          options: .transitionCrossDissolve,
                          animations: {
                            sender.backgroundColor = BLUE_TINT},
                          completion: nil)
    }
    
    @objc private func agreed(_ sender: UIButton) {
        consentInfo.completed = true
        if consentInfo.parentView!.flipPageIfNeeded() {
            checkbox.isEnabled = false
        }
    }
    
    /// A consent cell should always be focused.
    override func unfocus() {}

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
