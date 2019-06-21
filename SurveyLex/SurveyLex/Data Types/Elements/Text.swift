//
//  Text.swift
//  SurveyLex
//
//  Created by Jia Rui Shan on 2019/5/9.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

class Text: Question, CustomStringConvertible {
    let title: String
    var fragment: Fragment?
    var isRequired = false
    var completed: Bool {
        return !response.isEmpty
    }
    var response = ""
    var parentView: SurveyViewController?
    
    required init(json: JSON, fragment: Fragment? = nil) {
        let dictionary = json.dictionaryValue
        
        guard let title = dictionary["title"]?.string else {
            print(json)
            preconditionFailure("Malformed text question")
        }
        
        if let isRequired = dictionary["isRequired"]?.boolValue {
            self.isRequired = isRequired
        }
        self.title = title
        self.fragment = fragment
        
        self.isRequired = false // debugging
    }
    
    var type: ResponseType {
        return .text
    }
    
    var description: String {
        return "Text response: <\(title)>"
    }
    
    func makeContentCell() -> UITableViewCell {
        let cell = UITableViewCell()
        cell.selectionStyle = .none

        let textView = makeTextView(cell: cell)
        let textfield = makeTextField(cell: cell, topView: textView)
        makeLine(cell: cell, topView: textfield)
        
        return cell
    }
    
    private func makeTextView(cell: UITableViewCell) -> UITextView {
        let textView = UITextView()
        textView.attributedText = TextFormatter.formatted(title, type: .title)
        textView.textAlignment = .left
        textView.isEditable = false
        textView.dataDetectorTypes = .link
        textView.linkTextAttributes[.foregroundColor] = BLUE_TINT
        textView.isScrollEnabled = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        cell.addSubview(textView)
        
        textView.topAnchor.constraint(equalTo: cell.safeAreaLayoutGuide.topAnchor,
                                      constant: 20).isActive = true
        textView.leftAnchor.constraint(equalTo: cell.safeAreaLayoutGuide.leftAnchor,
                                       constant: 18).isActive = true
        textView.rightAnchor.constraint(equalTo: cell.safeAreaLayoutGuide.rightAnchor,
                                        constant: -18).isActive = true
        return textView
    }
    
    private func makeTextField(cell: UITableViewCell, topView: UIView) -> UITextField {
        let textfield = UITextField()
        textfield.borderStyle = .none
        textfield.clearButtonMode = .whileEditing
        textfield.returnKeyType = .done
        textfield.addTarget(self, action: #selector(dismissKeyboard(_:)), for: .primaryActionTriggered)
        textfield.placeholder = isRequired ? "Required" : "Optional"
        textfield.translatesAutoresizingMaskIntoConstraints = false
        cell.addSubview(textfield)
        
        textfield.leftAnchor.constraint(equalTo: cell.safeAreaLayoutGuide.leftAnchor,
                                        constant: 22).isActive = true
        textfield.rightAnchor.constraint(equalTo: cell.safeAreaLayoutGuide.rightAnchor,
                                         constant: -22).isActive = true
        textfield.heightAnchor.constraint(equalToConstant: 48).isActive = true
        textfield.topAnchor.constraint(equalTo: topView.bottomAnchor,
                                       constant: 5).isActive = true
        textfield.bottomAnchor.constraint(equalTo: cell.safeAreaLayoutGuide.bottomAnchor,
                                          constant: -10).isActive = true
        
        return textfield
    }
    
    @objc private func dismissKeyboard(_ sender: UITextField) {
        sender.endEditing(true)
    }
    
    private func makeLine(cell: UITableViewCell, topView: UIView) {
        let line = UIView()
        line.backgroundColor = .init(white: 0.9, alpha: 0.9)
        line.translatesAutoresizingMaskIntoConstraints = false
        cell.addSubview(line)
        
        line.leftAnchor.constraint(equalTo: topView.leftAnchor).isActive = true
        line.rightAnchor.constraint(equalTo: topView.rightAnchor).isActive = true
        line.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
        line.topAnchor.constraint(equalTo: topView.bottomAnchor).isActive = true
    }
    
    /// A special subclass of UITextField that adds 10 pixels of inset in the horizontal direction.
    class CustomTextField: UITextField {
        override func textRect(forBounds bounds: CGRect) -> CGRect {
            return bounds.inset(by: UIEdgeInsets(top: 0, left: 10, bottom: -1, right: 10))
        }
        
        override func editingRect(forBounds bounds: CGRect) -> CGRect {
            return bounds.inset(by: UIEdgeInsets(top: 0, left: 10, bottom: -1, right: 10))
        }
        
        override func borderRect(forBounds bounds: CGRect) -> CGRect {
            return bounds.inset(by: .zero)
        }
    }

}
