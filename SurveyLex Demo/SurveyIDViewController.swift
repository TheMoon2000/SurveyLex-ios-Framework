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
        
        // Tribe 4 application
        textView.text = "16261720-43fe-11e9-8a24-cd4ab4d0c054"
        
        // Post day diary
//        textView.text = "41e8abf0-62b9-11e9-a454-f5b21638e785"
        
        // Music survey
//        textView.text = "5f108ef0-5d23-11e9-8d7e-bb5f7e5229ff"
        
        // Custom (everything in one survey)
//        textView.text = "b1d9d390-9b5c-11e9-a279-9f8e317e3dcc"
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
        let survey = Survey(surveyID: textView.text,
                            target: self)
        survey.delegate = self
        survey.loadAndPresent()
    }
    
    // MARK: Delegate methods
    
    // Some protocol methods have default implementation, so be sure to check the documentation
    
    func surveyDidClose(_ survey: Survey, completed: Bool) {
        if !completed {
            print("survey closed without being completed")
        }
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
