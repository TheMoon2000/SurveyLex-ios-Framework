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
        
        var newString = string // This mutable string will be used instead
        
        // Convert all the special expressions into hyperlinks
        let linkDetector = try! NSRegularExpression(pattern: "\\[!\\[.*\\]\\(.*\\)\\]\\(.+\\)", options: .dotMatchesLineSeparators)
        let matches = linkDetector.matches(in: newString,
                                           options: .init(),
                                           range: NSMakeRange(0, newString.count))
        for match in matches {
            let matchString = String(newString[Range(match.range, in: newString)!])
            let components = matchString.components(separatedBy: ["(", ")"])
            let link = components[components.count - 2]
            newString = newString.replacingOccurrences(of: matchString, with: link)
        }
        
        newString = linkFormat(regex: "\\*\\*.+\\*\\*", input: newString)
        
        let attrTxt = NSMutableAttributedString(string: newString)

        let pgStyle = NSMutableParagraphStyle()
        pgStyle.lineSpacing = 3
        pgStyle.alignment = .center
        
        var attributes = [NSAttributedString.Key : Any]()
        switch type {
        case .body:
            attributes[.font] = UIFont.systemFont(ofSize: 19, weight: .regular)
        case .consentText:
            attributes[.font] = UIFont.systemFont(ofSize: 17)
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
    
    private static func linkFormat(regex: String, input: String) -> String {
        
        var newString = input
        
        let detector = try! NSRegularExpression(pattern: regex, options: .dotMatchesLineSeparators)
        let matches = detector.matches(in: newString,
                                       options: .init(),
                                       range: NSMakeRange(0, newString.count))
        for match in matches {
            let matchString = String(newString[Range(match.range, in: newString)!])
            let start = matchString.index(matchString.startIndex, offsetBy: 2)
            let end = matchString.index(matchString.endIndex, offsetBy: -2)
            let link = matchString[start..<end]
            newString = newString.replacingOccurrences(of: matchString, with: link)
        }
        
        return newString
    }
}
