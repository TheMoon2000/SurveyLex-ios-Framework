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
    let consentText: String
    let prompt: String
    var isRequired = true
    
    required init(json: JSON) {
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
    }
    
    
    var type: ResponseType {
        return .consent
    }
    
    var description: String {
        return "Consent form <\(title)>"
    }
    
    var contentCell: UITableViewCell {
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
                                         constant: 30).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: cell.rightAnchor,
                                          constant: -30).isActive = true
        
        let separatorLine = UIView()
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        separatorLine.backgroundColor = UIColor(white: 0.8, alpha: 1)
        cell.addSubview(separatorLine)
        separatorLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
        separatorLine.widthAnchor.constraint(equalToConstant: 60).isActive = true
        separatorLine.centerXAnchor.constraint(equalTo: cell.centerXAnchor).isActive = true
        separatorLine.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20).isActive = true
        
        let consentLabel = UILabel()
        consentLabel.text = consentText
        consentLabel.lineBreakMode = .byWordWrapping
        consentLabel.numberOfLines = 1000
        consentLabel.textAlignment = .left
        consentLabel.font = .systemFont(ofSize: 18)
        let attrTxt = NSMutableAttributedString(attributedString: consentLabel.attributedText!)
        let pgStyle = NSMutableParagraphStyle()
        pgStyle.lineSpacing = 2
        attrTxt.addAttributes([.kern: 0.5, .paragraphStyle: pgStyle], range: NSMakeRange(0, consentText.count))
        consentLabel.attributedText = attrTxt
        consentLabel.translatesAutoresizingMaskIntoConstraints = false
        cell.addSubview(consentLabel)
        
        consentLabel.leftAnchor.constraint(equalTo: cell.leftAnchor,
                                           constant: 30).isActive = true
        consentLabel.rightAnchor.constraint(equalTo: cell.rightAnchor,
                                            constant: -30).isActive = true
        consentLabel.topAnchor.constraint(equalTo: separatorLine.bottomAnchor,
                                          constant: 20).isActive = true
        consentLabel.bottomAnchor.constraint(equalTo: cell.bottomAnchor,
                                             constant: -50).isActive = true
        
//        cell.heightAnchor.constraint(greaterThanOrEqualToConstant: UIScreen.main.bounds.height - 60 - UIApplication.shared.keyWindow!.safeAreaInsets.bottom).isActive = true
        
        return cell
    }
    
    var cellHeight: CGFloat {
        return 800
    }
}
