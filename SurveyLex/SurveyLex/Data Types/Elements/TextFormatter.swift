//
//  TextFormatter.swift
//  SurveyLex
//
//  Created by Jia Rui Shan on 2019/5/14.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class TextFormatter {
    
    enum TextType {
        case title, consentText, body
    }
    
    static func formatted(_ string: String, type: TextType) -> NSAttributedString {
        var newString = string
        // Convert all the special expressions into hyperlinks
        do {
            let linkDetector = try NSRegularExpression(pattern: "\\[!\\[.*\\]\\(.*\\)\\]\\(.+\\)", options: .dotMatchesLineSeparators)
            var match = linkDetector.firstMatch(in: newString,
                                               options: .init(),
                                               range: NSMakeRange(0, newString.count))
            while match != nil {
                let matchString = String(newString[Range(match!.range, in: newString)!])
                let components = matchString.components(separatedBy: ["(", ")"])
                let link = components[components.count - 2]
                newString = newString.replacingOccurrences(of: matchString, with: link)
                match = linkDetector.firstMatch(in: newString, options: .init(), range: NSMakeRange(0, newString.count))
            }
        } catch {
            print("invalid expression")
        }
        
        let attrTxt = NSMutableAttributedString(string: newString)

        let pgStyle = NSMutableParagraphStyle()
        pgStyle.lineSpacing = 3
        pgStyle.alignment = .center
        
        var attributes = [NSAttributedString.Key : Any]()
        switch type {
        case .body:
            attributes[.font] = UIFont.systemFont(ofSize: 19, weight: .regular)
        case .consentText:
            attributes[.font] = UIFont.systemFont(ofSize: 16.7)
        case .title:
            attributes[.font] = UIFont.systemFont(ofSize: 22, weight: .medium)
        }
        
        attrTxt.addAttributes(attributes, range: NSMakeRange(0, newString.count))
        
        attrTxt.addAttributes([
            .paragraphStyle: pgStyle,
            .kern: 0.2
        ], range: NSMakeRange(0, newString.count))
        
        return attrTxt
    }
}
