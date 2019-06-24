//
//  ConsentCell.swift
//  SurveyLex
//
//  Created by Jia Rui Shan on 2019/6/22.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class ConsentCell: SurveyElementCell {
    
    var consentInfo: Consent!
    private var title: UITextView!
    private var separator: UIView!
    private var consentText: UITextView!
    private var agreeButton: UIButton!

    init(consent: Consent) {
        super.init()
        
        self.consentInfo = consent
        
        backgroundColor = .white
        selectionStyle = .none
        
        title = makeTitle()
        separator = makeSeparator()
        consentText = makeConsentText()
        agreeButton = makeAgreeButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func makeTitle() -> UITextView {
        let titleText = UITextView()
        titleText.isScrollEnabled = false
        titleText.attributedText = TextFormatter.formatted(consentInfo.title, type: .title)
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
    
    private func makeSeparator() -> UIView {
        let separatorLine = UIView()
        separatorLine.backgroundColor = UIColor(white: 0.8, alpha: 1)
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        addSubview(separatorLine)
        
        separatorLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
        separatorLine.widthAnchor.constraint(equalToConstant: 60).isActive = true
        separatorLine.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor).isActive = true
        separatorLine.topAnchor.constraint(equalTo: title.bottomAnchor,
                                           constant: 20).isActive = true
        
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
    
    private func makeAgreeButton() -> UIButton {
        let button = UIButton()
        button.setTitle("Agree & Continue", for: .normal)
        button.layer.cornerRadius = 4
        button.backgroundColor = BLUE_TINT
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.white, for: .normal)
        button.heightAnchor.constraint(equalToConstant: 49).isActive = true
        button.widthAnchor.constraint(equalToConstant: 210).isActive = true
        
        button.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchDown)
        button.addTarget(self,
                         action: #selector(buttonLifted(_:)),
                         for: [.touchCancel, .touchUpInside, .touchUpOutside, .touchDragExit])
        button.addTarget(self, action: #selector(agreed(_:)), for: .touchUpInside)
        
        addSubview(button)
        
        button.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor).isActive = true
        button.topAnchor.constraint(equalTo: consentText.bottomAnchor,
                                    constant: 32).isActive = true
        button.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor,
                                       constant: -40).isActive = true
        
        return button
    }
    
    @objc private func buttonPressed(_ sender: UIButton) {
        sender.backgroundColor = consentInfo.AGREE_PRESSED
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
        consentInfo.parentView?.flipPageIfNeeded()
    }
    
    override func unfocus() {}

}
