//
//  SurveyIDViewController.swift
//  Voice Capture Utility
//
//  Created by Jia Rui Shan on 2019/5/6.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON
import SurveyLex

class SurveyIDViewController: UIViewController, SurveyResponseDelegate {
    
    private var lookupButton: UIButton!
    private var textView: UITextView!
    private var accessoryView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Survey Lookup Demo"
        
        accessoryView = makeAccessoryView() // 1
        textView = makeTextView() // 2
        lookupButton = makeLookupButton() // 3
        
        
//        textView.text = "41e8abf0-62b9-11e9-a454-f5b21638e785"
        textView.text = "5f108ef0-5d23-11e9-8d7e-bb5f7e5229ff"
    }
    
    
    /// Make keyboard accessory view
    
    private func makeAccessoryView() -> UIView {
        let button = UIButton(type: .system)
        button.setTitle("Done", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        button.addTarget(self, action: #selector(dismissKeyboard), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        let signButton = UIButton(type: .system)
        signButton.setTitle("–", for: .normal)
        signButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        signButton.addTarget(self, action: #selector(dash), for: .touchUpInside)
        signButton.translatesAutoresizingMaskIntoConstraints = false
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 45))
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(white: 0.92, alpha: 1).cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        view.addSubview(signButton)
        view.backgroundColor = UIColor(white: 0.95, alpha: 0.9)
        
        NSLayoutConstraint.activate([
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            signButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            signButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            signButton.widthAnchor.constraint(equalToConstant: 30)
            ])
        return view
    }
    
    
    /// Make a text view!
    
    private func makeTextView() -> UITextView {
        let txv = UITextView()
        txv.layer.borderColor = UIColor(white: 0.93, alpha: 1).cgColor
        txv.textContainerInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        txv.font = UIFont.systemFont(ofSize: 24)
        txv.allowsEditingTextAttributes = false
        txv.textColor = UIColor(white: 0.1, alpha: 1)
        txv.autocapitalizationType = .none
        txv.keyboardType = .asciiCapable
        txv.textAlignment = .center
        txv.autocorrectionType = .no
        txv.layer.borderWidth = 1
        txv.layer.cornerRadius = 8
        txv.inputAccessoryView = accessoryView
        
        txv.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(txv)
        
        
        // Layout constraints
        
        txv.leftAnchor.constraint(equalTo: view.leftAnchor,
                                  constant: 30).isActive = true
        txv.rightAnchor.constraint(equalTo: view.rightAnchor,
                                   constant: -30).isActive = true
        txv.heightAnchor.constraint(equalToConstant: 120).isActive = true
        txv.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor,
                                     constant: -25).isActive = true
        
        return txv
    }
    
    /// Make a customized-looking button!
    
    private func makeLookupButton() -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("Lookup Survey", for: .normal)
        button.layer.cornerRadius = 24
        button.tintColor = BUTTON_DEEP_BLUE
        button.layer.borderWidth = 1
        button.layer.borderColor = BUTTON_TINT.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        
        button.widthAnchor.constraint(equalToConstant: 160).isActive = true
        button.heightAnchor.constraint(equalToConstant: 48).isActive = true
        button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        button.topAnchor.constraint(equalTo: textView.bottomAnchor,
                                    constant: 20).isActive = true
        button.addTarget(self, action: #selector(lookup(_:)), for: .touchUpInside)
        
        return button
    }
    
    
    @objc private func dismissKeyboard() {
        textView.endEditing(true)
    }
    
    @objc private func dash() {
        textView.insertText("-")
    }
    
    @objc func lookup(_ sender: UIButton) {
//         test()
        let survey = Survey(surveyID: textView.text,
                            target: self)
        survey.delegate = self
        survey.load()
    }
    
    // Survey response delegate methods
    
    func surveyDidLoad(_ survey: Survey) {
        survey.present()
    }
    
    func surveyDidPresent(_ survey: Survey) {
        
    }
    
    func surveyReturnedResponse(_ survey: Survey, response: Survey.Response) {
        switch response {
        case .invalidRequest:
            self.invalidSurveyWarning()
        case .connectionError:
            self.noInternetConnectionWarning()
        case .cancelled:
            print("survey closed halfway")
        case .submitted:
            print("submitted")
        default:
            print(response)
            break
        }
    }
    
    private func invalidSurveyWarning() {
        let alert = UIAlertController(title: "Survey Not Found",
                                      message: "Please check that the survey ID you provided is valid.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func noInternetConnectionWarning() {
        let alert = UIAlertController(title: "Network Failure",
                                      message: "We were unable to establish connection to the server. Please check your internet connection.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func test() {
        let input = """
{
  "audioResponseSamples": [
    "nlx-913a2700-6d41-11e9-9606-77a8c7579692",
    "nlx-0d459fb0-6d87-11e9-9606-77a8c7579692"
  ],
  "textQuestionsResponses": [],
  "fragments": [
    {
      "fragmentId": "533cdc00-62b9-11e9-a454-f5b21638e785",
      "type": "TEXT_SURVEYJS",
      "data": {
        "surveyjs": {
          "questions": [
            {
              "type": "rating",
              "rateValues": [
                { "value": "1 Ineffective", "text": "This cell is intended to be very very long in order to test the appearance of the rating UI." },
                2,
                3,
                4,
                { "value": "5 Effective", "text": "5 Effective" }
              ],
              "title": "Did you feel effective today?",
              "isRequired": true
            },
            {
              "type": "rating",
              "rateValues": [
                { "value": "No", "text": "No" },
                { "value": "Not Really", "text": "Not Really" },
                { "value": "Somewhat", "text": "Somewhat" },
                { "value": "Mostly", "text": "Mostly" },
                { "value": "Yes", "text": "Yes" }
              ],
              "title": "Did you do what you planned on doing?",
              "isRequired": true
            },
            {
              "type": "radiogroup",
              "choices": ["Yes", "No"],
              "title": "Is this for yesterday? (Or another day?)",
              "isRequired": true
            }
          ]
        }
      }
    },
    {
      "fragmentId": "536ff9f0-62b9-11e9-a454-f5b21638e785",
      "type": "AUDIO_STANDARD",
      "data": {
        "prompt": "What happened today?",
        "isRequired": true
      }
    }
  ],
  "viewNum": 0,
  "published": true,
  "archived": false,
  "_id": "5cb9ec43faddfa5f7bb65d3b",
  "surveyId": "41e8abf0-62b9-11e9-a454-f5b21638e785",
  "__v": 0,
  "textQuestions": [],
  "createdDate": "2019-04-19T15:41:55.852Z",
  "logoUrl": "",
  "voiceQuestionPrompts": [
    {
      "_id": "5cb9ec43faddfa7173b65d3a",
      "prompt": "What happened today?",
      "lengthInSeconds": 30
    }
  ],
  "title": "Post Day Diary",
  "creator": "53123c80-a80f-11e8-bac6-81a4b6c08649",
  "sessions": null,
  "id": "5cb9ec43faddfa5f7bb65d3b"
}

"""
        let json = JSON(parseJSON: input)
        let survey = Survey(json: json, target: self)
        survey.present()
    }
}
/*
extension UITextView {
    
    /// Center the text vertically within the container.
    override open var contentSize: CGSize {
        didSet {
            var topCorrection = (bounds.size.height - contentSize.height * zoomScale) / 2.0
            topCorrection = max(0, topCorrection)
            contentInset = UIEdgeInsets(top: topCorrection, left: 0, bottom: 0, right: 0)
        }
    }
}
*/
