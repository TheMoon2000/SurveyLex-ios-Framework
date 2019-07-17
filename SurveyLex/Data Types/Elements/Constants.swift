//
//  Constants.swift
//  SurveyLex
//
//  Created by Jia Rui Shan on 2019/5/15.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

// These constants can only be changed through framework modification.
internal let BUTTON_LIGHT_TINT = UIColor(red: 0.75, green: 0.89, blue: 1, alpha: 1)
internal let BUTTON_DEEP_BLUE = UIColor(red: 0.49, green: 0.7, blue: 0.94, alpha: 1)
internal let BUTTON_TINT = UIColor(red: 0.7, green: 0.85, blue: 1, alpha: 1)
internal let BUTTON_PRESSED = UIColor(red: 0.39, green: 0.59, blue: 0.88, alpha: 1)
internal let RECORD_TINT = UIColor(red: 1, green: 0.51, blue: 0.5, alpha: 1)
internal let BLUE_TINT = UIColor(red: 0.43, green: 0.64, blue: 0.94, alpha: 1)
internal let DARKER_TINT = UIColor(red: 0.33, green: 0.56, blue: 0.94, alpha: 1)
internal let SELECTION = UIColor(red: 0.9, green: 0.95, blue: 1, alpha: 1)
internal let DISABLED_BLUE = UIColor(red: 0.65, green: 0.79, blue: 0.99, alpha: 1)
internal let RECORDING = UIColor(red: 0.98, green: 0.4, blue: 0.4, alpha: 1)
internal let RECORDING_PRESSED = UIColor(red: 0.93, green: 0.36, blue: 0.36, alpha: 1)

// These constants are now environment variables in `Survey` class.
internal let UNFOCUSED_ALPHA: CGFloat = 0.3
internal let SIDE_PADDING: CGFloat = 20.0

extension UITextView {
    
    func format(as type: TextFormatter.TextType) {
        self.isEditable = false
        self.isScrollEnabled = false
        self.textAlignment = .left
        self.attributedText = TextFormatter.formatted(text, type: type)
        self.dataDetectorTypes = .link
        self.linkTextAttributes[.foregroundColor] = BLUE_TINT
        self.textContainerInset = .zero
        self.textContainer.lineFragmentPadding = 0.0
        self.backgroundColor = .clear
    }
}

/*
extension UITableView {
    // Correctly estimate heights
    override open func didMoveToSuperview() {
        super.didMoveToSuperview()
        layoutIfNeeded()
    }
}
*/
