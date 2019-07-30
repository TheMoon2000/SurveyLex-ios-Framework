//
//  FragmentMenu.swift
//  SurveyLex Demo
//
//  Created by Jia Rui Shan on 2019/7/29.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//
// A navigation menu that appears at the bottom of every page.

import UIKit

class FragmentMenu: UITableViewCell {
    
    var surveyPage: SurveyPage!
    
    var backButton: UIButton!
    var nextButton: UIButton!
    var goToPageButton: UIButton!
    private var currentAlertVC: UIAlertController?

    required init(surveyPage: SurveyPage) {
        super.init(style: .default, reuseIdentifier: nil)
        
        selectionStyle = .none
        self.surveyPage = surveyPage
        
        backgroundColor = .init(white: 0.95, alpha: 1)
        
        backButton = {
            let button = UIButton(type: .system)
            button.setImage(#imageLiteral(resourceName: "previous_thin"), for: .normal)
            button.tintColor = BLUE_TINT
            button.translatesAutoresizingMaskIntoConstraints = false
            addSubview(button)
            
            button.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor).isActive = true
            button.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 10).isActive = true
            
            button.addTarget(self, action: #selector(flipBack), for: .touchUpInside)
            
            return button
        }()
        
        nextButton = {
            let button = UIButton(type: .system)
            button.setImage(#imageLiteral(resourceName: "next_thin"), for: .normal)
            button.tintColor = BLUE_TINT
            button.isEnabled = surveyPage.unlocked
            button.translatesAutoresizingMaskIntoConstraints = false
            addSubview(button)
            
            button.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor).isActive = true
            button.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -10).isActive = true
            
            button.addTarget(self, action: #selector(flipNext), for: .touchUpInside)
            
            return button
        }()
        
        for button in [backButton, nextButton] {
            button?.imageView?.contentMode = .scaleAspectFit
            button?.widthAnchor.constraint(equalToConstant: 40).isActive = true
            button?.heightAnchor.constraint(equalToConstant: 19).isActive = true
        }
        
        goToPageButton = {
            let button = UIButton(type: .system)
            button.tintColor = DARKER_TINT
            button.setTitle("Go to Page", for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
            button.translatesAutoresizingMaskIntoConstraints = false
            addSubview(button)
            
            button.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor).isActive = true
            button.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor).isActive = true
            
            button.addTarget(self, action: #selector(goToPage), for: .touchUpInside)
            
            return button
        }()
    }
    
    private func numberOfFragments() -> Int {
        return surveyPage.surveyViewController!.fragmentPages.count
    }
    
    @objc private func goToPage() {
        
        let lowerBound = surveyPage.surveyViewController!.survey.showLandingPage ? 0 : 1
        
        let alert = UIAlertController(title: "Go to Page", message: "Please enter a page number between \(lowerBound) and \(numberOfFragments()).", preferredStyle: .alert)
        alert.view.tintColor = DARKER_TINT
        
        currentAlertVC = alert
        
        alert.addTextField { textfield in
            textfield.placeholder = "Page number"
            textfield.keyboardType = .numberPad
            textfield.autocorrectionType = .no
            
            textfield.addTarget(self, action: #selector(self.pageNumberTextFieldValueChanged), for: .editingChanged)
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { action in
            self.currentAlertVC = nil
        })
        alert.addAction(UIAlertAction(title: "Go", style: .default) {
            action in
            self.goToPageHandler(alert: alert)
        })
        
        // By default, the page number textfield is blank so we disable the 'Go' button.
        alert.actions.last?.isEnabled = false

        surveyPage.present(alert, animated: true, completion: nil)
    }
    
    @objc private func pageNumberTextFieldValueChanged(_ sender: UITextField) {
        let alert = currentAlertVC!
        if let pageNumber = Int(sender.text!) {
            if surveyPage.surveyViewController!.survey.showLandingPage {
                alert.actions.last?.isEnabled = pageNumber >= 0 && pageNumber <= numberOfFragments()
            } else {
                alert.actions.last?.isEnabled = pageNumber > 0 && pageNumber <= numberOfFragments()
            }
        } else {
            alert.actions.last?.isEnabled = false
        }
    }
    
    /// Handles the 'Go' action from the 'Go To Page' alert.
    private func goToPageHandler(alert: UIAlertController) {
        let rawInputText = alert.textFields![0].text ?? ""
        
        // Assert that the input text is a valid integer.
        guard let pageNumber = Int(rawInputText) else {
            preconditionFailure("Internal inconsistency in page number")
        }
        
        surveyPage.surveyViewController!.goToPage(page: pageNumber - 1)
        
        currentAlertVC = nil
    }
    
    // Forward and backward buttons
    
    @objc private func flipBack() {
        surveyPage.surveyViewController?.goToPage(page: surveyPage.pageIndex - 1)
    }
    
    @objc private func flipNext() {
        if !surveyPage.surveyViewController!.flipPageIfNeeded() {
            if let nextVC = surveyPage.surveyViewController!.pageViewController(surveyPage.surveyViewController!, viewControllerAfter: surveyPage) {
                surveyPage.surveyViewController!.setViewControllers([nextVC], direction: .forward, animated: true, completion: nil)
            } else {
                debugMessage("Cannot flip to next page.")
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
