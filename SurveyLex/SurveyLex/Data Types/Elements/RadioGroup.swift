//
//  Question.swift
//  Voice Capture Utility
//
//  Created by Jia Rui Shan on 2019/5/7.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

class RadioGroup: Question, CustomStringConvertible, RatingResponseDelegate {
    let title: String
    var fragment: Fragment?
    let choices: [String]
    var isRequired = false
    var completed = false
    var selection = -1
    var parentView: SurveyViewController?
    
    required init(json: JSON, fragment: Fragment? = nil) {
        let dictionary = json.dictionaryValue
        
        guard let title = dictionary["title"]?.string,
              let questionData = dictionary["choices"]?.arrayObject as? [String]
        else {
            print(json)
            preconditionFailure("Malformed radiogroup question")
        }
        
        if let required = dictionary["isRequired"]?.bool {
            self.isRequired = required
        }
        
        self.title = title
        self.choices = questionData
        self.fragment = fragment
    }
    
    var type: ResponseType {
        return .radioGroup
    }
    
    var description: String {
        return "Radio group: <" + choices.map {$0.description}.joined(separator: ", ") + ">"
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
        let rateInfo = choices.map { ($0, $0) }
        let choiceTable = MultipleChoiceView(rateInfo: rateInfo, delegate: self)
        choiceTable.translatesAutoresizingMaskIntoConstraints = false
        choiceTable.isScrollEnabled = false
        cell.addSubview(choiceTable)
        
        choiceTable.leftAnchor.constraint(equalTo: cell.safeAreaLayoutGuide.leftAnchor).isActive = true
        choiceTable.rightAnchor.constraint(equalTo: cell.safeAreaLayoutGuide.rightAnchor).isActive = true
        choiceTable.bottomAnchor.constraint(equalTo: cell.safeAreaLayoutGuide.bottomAnchor,
                                            constant: -30).isActive = true
        return choiceTable
    }
    
    func didSelectRow(row: Int) {
        selection = row
        if !self.completed {
            self.completed = true
            parentView?.nextPage()
        }
    }

}
