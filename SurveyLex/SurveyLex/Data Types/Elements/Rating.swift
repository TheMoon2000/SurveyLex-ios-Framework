//
//  Rating.swift
//  SurveyLex
//
//  Created by Jia Rui Shan on 2019/5/10.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

class Rating : Question, CustomStringConvertible, RatingResponseDelegate {
    let title: String
    var fragment: Fragment?
    var isRequired = false
    var completed = false
    var parentView: SurveyViewController?
    var options = [(value: String, text: String)]()
    var choices: [String] {
        return options.map { $0.text }
    }
    
    /// Stores the user's response, which will be accessed during survey submission
    var currentSelections = [Int]()
    
    required init(json: JSON, fragment: Fragment? = nil) {
        let dictionary = json.dictionaryValue
        
        guard let title = dictionary["title"]?.string,
              let rateValues = dictionary["rateValues"]?.array
        else {
            print(json)
            preconditionFailure("Malformed text question")
        }
        
        self.title = title
        self.fragment = fragment
        
        if let isRequired = dictionary["isRequired"]?.boolValue {
            self.isRequired = isRequired
        }
        
        for option in rateValues {
            if let optionDict = option.dictionaryObject as? [String: String] {
                options.append((optionDict["value"]!, optionDict["text"]!))
            } else if let value = option.int {
                options.append((String(value), String(value)))
            }
        }
        
    }
    
    var type: ResponseType {
        return .rating
    }
    
    var description: String {
        let choices = "\(options.first?.text ?? "")...\(options.last?.text ?? "")"
        return "\(title):\n  <\(choices)> (\(options.count) choices total)"
    }
    
    func makeContentCell() -> UITableViewCell {
        let cell = UITableViewCell()
        
        let textView = makeTextView(cell)
        let table = makeChoiceTable(cell)
        table.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 30).isActive = true
        return cell
    }
    
    private func makeTextView(_ cell: UITableViewCell) -> UITextView {
        let textView = UITextView()
        textView.attributedText = TextFormatter.formatted(title, type: .body)
        textView.textAlignment = .center
        textView.isEditable = false
        textView.dataDetectorTypes = .link
        textView.linkTextAttributes[.foregroundColor] = BLUE_TINT
        textView.isScrollEnabled = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        cell.addSubview(textView)
        
        textView.topAnchor.constraint(equalTo: cell.safeAreaLayoutGuide.topAnchor,
                                      constant: 30).isActive = true
        textView.leftAnchor.constraint(equalTo: cell.safeAreaLayoutGuide.leftAnchor,
                                       constant: 30).isActive = true
        textView.rightAnchor.constraint(equalTo: cell.safeAreaLayoutGuide.rightAnchor,
                                        constant: -30).isActive = true
        return textView
    }
    
    private func makeChoiceTable(_ cell: UITableViewCell) -> UITableView {
        let choiceTable = MultipleChoiceView(rateInfo: options, delegate: self)
        choiceTable.translatesAutoresizingMaskIntoConstraints = false
        choiceTable.isScrollEnabled = false
        cell.addSubview(choiceTable)
        
        choiceTable.leftAnchor.constraint(equalTo: cell.safeAreaLayoutGuide.leftAnchor).isActive = true
        choiceTable.rightAnchor.constraint(equalTo: cell.safeAreaLayoutGuide.rightAnchor).isActive = true
        choiceTable.bottomAnchor.constraint(equalTo: cell.safeAreaLayoutGuide.bottomAnchor,
                                            constant: -30).isActive = true
//        choiceTable.contentSize.width = UIScreen.main.bounds.width
//        choiceTable.layoutSubviews()
//        choiceTable.heightAnchor.constraint(greaterThanOrEqualToConstant: choiceTable.contentSize.height).isActive = true
        
        return choiceTable
    }
    
    
    /// Delegate method that responds when the user makes a selection
    
    func didSelectRow(row: Int) {
        currentSelections = [row]
        if !self.completed {
            self.completed = true
            parentView?.nextPage()
        }
    }
    
}
