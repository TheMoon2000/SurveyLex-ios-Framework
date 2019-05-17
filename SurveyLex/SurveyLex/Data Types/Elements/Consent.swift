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
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textAlignment = .center
        titleLabel.font = .systemFont(ofSize: 22, weight: .medium)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        cell.addSubview(titleLabel)
        
        titleLabel.topAnchor.constraint(equalTo: cell.topAnchor,
                                        constant: 40).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: cell.leftAnchor,
                                         constant: 32).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: cell.rightAnchor,
                                          constant: -32).isActive = true
        
        let separatorLine = UIView()
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        separatorLine.backgroundColor = UIColor(white: 0.8, alpha: 1)
        cell.addSubview(separatorLine)
        separatorLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
        separatorLine.widthAnchor.constraint(equalToConstant: 60).isActive = true
        separatorLine.centerXAnchor.constraint(equalTo: cell.centerXAnchor).isActive = true
        separatorLine.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20).isActive = true
        
        let consentLabel = UILabel()
        consentLabel.lineBreakMode = .byWordWrapping
        consentLabel.numberOfLines = 1000
        consentLabel.textAlignment = .left
        let attrTxt = TextFormatter.formatted(consentText, type: .consentText)
        consentLabel.attributedText = attrTxt
        consentLabel.translatesAutoresizingMaskIntoConstraints = false
        cell.addSubview(consentLabel)
        
        consentLabel.leftAnchor.constraint(equalTo: cell.leftAnchor,
                                           constant: 32).isActive = true
        consentLabel.rightAnchor.constraint(equalTo: cell.rightAnchor,
                                            constant: -32).isActive = true
        consentLabel.topAnchor.constraint(equalTo: separatorLine.bottomAnchor,
                                          constant: 20).isActive = true
        
        let agreeButton = makeAgreeButton()
        cell.addSubview(agreeButton)
        agreeButton.centerXAnchor.constraint(equalTo: cell.centerXAnchor).isActive = true
        agreeButton.topAnchor.constraint(equalTo: consentLabel.bottomAnchor, constant: 32).isActive = true
        agreeButton.bottomAnchor.constraint(equalTo: cell.bottomAnchor,
                                            constant: -40).isActive = true
        
        
        return cell
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
        
        return button
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
