//
//  Constants.swift
//  SurveyLex
//
//  Created by Jia Rui Shan on 2019/5/15.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

let BUTTON_LIGHT_TINT = UIColor(red: 0.75, green: 0.89, blue: 1, alpha: 1)
let BUTTON_DEEP_BLUE = UIColor(red: 0.49, green: 0.7, blue: 0.94, alpha: 1)
let BUTTON_TINT = UIColor(red: 0.7, green: 0.85, blue: 1, alpha: 1)
let BUTTON_PRESSED = UIColor(red: 0.39, green: 0.59, blue: 0.88, alpha: 1)
let RECORD_TINT = UIColor(red: 1, green: 0.51, blue: 0.5, alpha: 1)
let BLUE_TINT = UIColor(red: 0.43, green: 0.64, blue: 0.94, alpha: 1)
let DARKER_TINT = UIColor(red: 0.33, green: 0.56, blue: 0.94, alpha: 1)
let SELECTION = UIColor(red: 0.9, green: 0.95, blue: 1, alpha: 1)
let DISABLED_BLUE = UIColor(red: 0.65, green: 0.79, blue: 0.99, alpha: 1)

let UNFOCUSED_ALPHA: CGFloat = 0.3
let SIDE_PADDING: CGFloat = 20.0

extension UITextView {
    
    func format(as type: TextFormatter.TextType) {
        self.isEditable = false
        self.isScrollEnabled = false
        self.dataDetectorTypes = .link
        self.linkTextAttributes[.foregroundColor] = BLUE_TINT
        self.attributedText = TextFormatter.formatted(text, type: type)
        self.textContainerInset = .zero
        self.textContainer.lineFragmentPadding = 0.0
        
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let matches = detector.matches(in: text, options: [], range: NSMakeRange(0, text.count))
        self.isUserInteractionEnabled = !matches.isEmpty
        
        switch type {
        case .plain:
            self.dataDetectorTypes = []
            self.textAlignment = .left
        case .title:
            self.isSelectable = false
        case .subtitle:
            self.textAlignment = .left
        case .consentText:
            self.textAlignment = .left
        }
    }
}
