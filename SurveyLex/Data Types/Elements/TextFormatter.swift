//
//  TextFormatter.swift
//  SurveyLex
//
//  Created by Jia Rui Shan on 2019/5/14.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import Down

/// An internal class for the framework designed to format markdown text into NSAttributedText, with the help of the framework `Down`.
class TextFormatter {
    
    /// The style to format the given markdown string.
    enum TextType {
        
        /// Used for all titles and audio question prompts.
        case title
        
        /// Used for consent texts and info texts.
        case consentText
        
        /// Used for the checkbox prompt on a consent form.
        case subtitle
        
        /// Used for radio group questions and checkbox choices.
        case plain
    }
    
    /**
     Format the given string using the given text type.
     
     - Parameters:
         - string: The raw markdown string.
         - type: The type of text the markdown string is.
     
     - Returns: An attributed string containin the markdown.
    */
    static func formatted(_ string: String, type: TextType) -> NSAttributedString {
        
        var newString = string // This mutable string will be used instead
        
        // Convert all the special expressions into hyperlinks
        let linkDetector = try! NSRegularExpression(pattern: "!\\[.*\\]\\(.*\\)", options: [])
        let matches = linkDetector.matches(in: newString,
                                           options: .init(),
                                           range: NSMakeRange(0, newString.count))
        for match in matches.reversed() {
            let matchString = String(newString[Range(match.range, in: newString)!])
            let components = matchString.components(separatedBy: ["(", ")"])
            let link = components[components.count - 2]
            let newText = "[Media: [Link](\(link))]"
            newString = newString.replacingOccurrences(of: matchString, with: newText)
        }
        
        let consentStyle = """
            body {
                font-family: -apple-system;
                font-size: 17px;
                line-height: 1.5;
                letter-spacing: 1%;
            }
            
            h1, h2, h3, h4, h5, h6 {
                font-weight: 500;
            }
"""
        let subtitleStyle = """
            body {
                font-family: -apple-system;
                font-size: 16px;
                line-height: 1.4;
                letter-spacing: 1%;
            }

            h1, h2, h3, h4, h5, h6 {
                font-weight: 600;
            }

            h1 {
                font-size: 21px;
            }

            h2 {
                font-size: 20px;
            }

            h3 {
                font-size: 19px;
            }
"""

        let titleStyle = """
            body {
                font-family: -apple-system;
                font-weight: 500;
                font-size: 23px;
                line-height: 1.4;
                letter-spacing: 2px;
            }

            h1, h2, h3, h4, h5, h6 {
                font-weight: 500;
            }
"""
        
        let plainStyle = """
            body {
                font-family: -apple-system;
                font-size: 18px;
                line-height: 1.4;
                letter-spacing: 1%;
            }

            h1, h2, h3, h4, h5, h6 {
                font-weight: 500;
            }
"""
        
        let _ = """
            body {
                font: -apple-system-body; font-size: 18px; }
            h1 { font: -apple-system-title1 }
            h2 { font: -apple-system-title2 }
            h3 { font: -apple-system-title3 }
            h4, h5, h6 { font: -apple-system-headline }
"""
        
        guard !newString.isEmpty else {
            return NSAttributedString(string: "")
        }
        
        
        switch type {
        case .consentText:
            do {
                let down = try Down(markdownString: newString).toAttributedString(.default, stylesheet: consentStyle)
                
                // As of Down 0.6.2, the framework always produces an attributed string with an extra blank line at the end. To remove that line, we return the substring that excludes the last character ('\r').
                return down.attributedSubstring(from: NSMakeRange(0, down.length - 1))
            } catch {
                return legacy(string, type: .consentText)
            }
        case .subtitle:
            do {
                let down = try Down(markdownString: newString).toAttributedString(.default, stylesheet: subtitleStyle)
                return down.attributedSubstring(from: NSMakeRange(0, down.length - 1))
            } catch {
                return legacy(string, type: .subtitle)
            }
        case .title:
            do {
                let down = try Down(markdownString: newString).toAttributedString(.default, stylesheet: titleStyle)
                return down.attributedSubstring(from: NSMakeRange(0, down.length - 1))
            } catch {
                return legacy(string, type: .title)
            }
        case .plain:
            do {
                let down = try Down(markdownString: newString).toAttributedString(.default, stylesheet: plainStyle)
                return down.attributedSubstring(from: NSMakeRange(0, down.length - 1))
            } catch {
                return legacy(string, type: .title)
            }
        }
        
    }
    
    /// Legacy formatter used as fallback
    private static func legacy(_ string: String, type: TextType) -> NSAttributedString {
        
        debugMessage("Warning: fallback text formatter called")
        
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
                
        let attrTxt = NSMutableAttributedString(string: newString)
        
        let pgStyle = NSMutableParagraphStyle()
        pgStyle.lineSpacing = 4
        pgStyle.paragraphSpacing = 10
        pgStyle.alignment = .left
        
        var attributes = [NSAttributedString.Key : Any]()
        switch type {
        case .consentText:
            attributes[.font] = UIFont.systemFont(ofSize: 17)
        case .subtitle:
            attributes[.font] = UIFont.systemFont(ofSize: 16)
        case .title:
            attributes[.font] = UIFont.systemFont(ofSize: 22, weight: .medium)
        case .plain:
            attributes[.font] = UIFont.systemFont(ofSize: 18.5)
        }
        
        attrTxt.addAttributes(attributes, range: NSMakeRange(0, newString.count))
        
        attrTxt.addAttributes([
            .paragraphStyle: pgStyle,
            .kern: 0.2
            ], range: NSMakeRange(0, newString.count))
        
        return attrTxt
    }
}
