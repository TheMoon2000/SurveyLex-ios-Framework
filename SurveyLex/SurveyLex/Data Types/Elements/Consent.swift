//
//  Consent.swift
//  SurveyLex
//
//  Created by Jia Rui Shan on 2019/5/10.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

class Consent: Question, CustomStringConvertible {
    let title: String
    var fragment: Fragment?
    let consentText: String
    var completed = false
    let prompt: String
    var parentView: SurveyViewController?
    var isRequired = true
    
    let AGREE_PRESSED = UIColor(red: 0.39, green: 0.59, blue: 0.88, alpha: 1)
    
    required init(json: JSON, fragment: Fragment? = nil) {
        let dictionary = json.dictionaryValue
        
        guard let title = dictionary["title"]?.string,
              let consentText = dictionary["consentText"]?.string,
              let prompt = dictionary["prompt"]?.string
        else {
            print(json)
            preconditionFailure("Malformed consent data")
        }
        
        if let isRequired = dictionary["isRequired"]?.bool {
            self.isRequired = isRequired
        }
    
        self.title = title
        self.consentText = consentText
        self.prompt = prompt
        self.fragment = fragment
    }
    
    
    var type: ResponseType {
        return .consent
    }
    
    var description: String {
        return "Consent form <\(title)>"
    }
    
    func makeContentCell() -> UITableViewCell {
        let cell = UITableViewCell()
        cell.backgroundColor = .white
        
        let titleText = makeTitle(cell)
        let separator = makeSeparator(cell, topView: titleText)
        let consent = makeConsentText(cell, topView: separator)
        makeAgreeButton(cell, topView: consent)
        
        return cell
    }
    
    
    private func makeTitle(_ cell: UITableViewCell) -> UITextView {
        let titleText = UITextView()
        titleText.isScrollEnabled = false
        titleText.attributedText = TextFormatter.formatted(title, type: .title)
        titleText.translatesAutoresizingMaskIntoConstraints = false
        cell.addSubview(titleText)
        
        titleText.topAnchor.constraint(equalTo: cell.topAnchor,
                                        constant: 40).isActive = true
        titleText.leftAnchor.constraint(equalTo: cell.leftAnchor,
                                         constant: 32).isActive = true
        titleText.rightAnchor.constraint(equalTo: cell.rightAnchor,
                                          constant: -32).isActive = true
        
        return titleText
    }
    
    private func makeSeparator(_ cell: UITableViewCell, topView: UIView) -> UIView {
        let separatorLine = UIView()
        separatorLine.backgroundColor = UIColor(white: 0.8, alpha: 1)
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        cell.addSubview(separatorLine)
        
        separatorLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
        separatorLine.widthAnchor.constraint(equalToConstant: 60).isActive = true
        separatorLine.centerXAnchor.constraint(equalTo: cell.centerXAnchor).isActive = true
        separatorLine.topAnchor.constraint(equalTo: topView.bottomAnchor,
                                           constant: 20).isActive = true
        
        return separatorLine
    }
    
    private func makeConsentText(_ cell: UITableViewCell, topView: UIView) -> UITextView {
        let consent = UITextView()
        consent.attributedText = TextFormatter.formatted(consentText, type: .consentText)
        consent.textAlignment = .left
        consent.isEditable = false
        consent.dataDetectorTypes = .link
        consent.linkTextAttributes[.foregroundColor] = BLUE_TINT
        consent.isScrollEnabled = false
        consent.translatesAutoresizingMaskIntoConstraints = false
        cell.addSubview(consent)
        
        consent.topAnchor.constraint(equalTo: topView.bottomAnchor,
                                     constant: 20).isActive = true
        consent.leftAnchor.constraint(equalTo: cell.safeAreaLayoutGuide.leftAnchor,
                                      constant: 30).isActive = true
        consent.rightAnchor.constraint(equalTo: cell.safeAreaLayoutGuide.rightAnchor,
                                       constant: -30).isActive = true
        
        return consent
    }
    
    private func makeAgreeButton(_ cell: UITableViewCell, topView: UIView) {
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
        
        cell.addSubview(button)
        
        button.centerXAnchor.constraint(equalTo: cell.centerXAnchor).isActive = true
        button.topAnchor.constraint(equalTo: topView.bottomAnchor,
                                    constant: 32).isActive = true
        button.bottomAnchor.constraint(equalTo: cell.bottomAnchor,
                                       constant: -40).isActive = true
    }
    
    @objc private func buttonPressed(_ sender: UIButton) {
        sender.backgroundColor = self.AGREE_PRESSED
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
        self.completed = true
        parentView?.nextPage()
    }
}
