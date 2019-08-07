//
//  LandingPage.swift
//  SurveyLex
//
//  Created by Jia Rui Shan on 2019/7/28.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

/// The view controller responsible for showing a landing page.
class LandingPage: UIViewController {
    
    var surveyViewController: SurveyViewController!
    
    private var surveyTitle: UILabel!
    private var logoImage: UIImageView!
    private var separator: UIView!
    private var note: UITextView!
    private var stackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Views in top to bottom order
        logoImage = {
            let logo = UIImageView(image: surveyViewController.surveyData.logo)
            if logo.image == nil { logo.isHidden = true }
            logo.contentMode = .scaleAspectFit
            logo.translatesAutoresizingMaskIntoConstraints = false
            
            logo.widthAnchor.constraint(equalToConstant: 120).isActive = true
            logo.heightAnchor.constraint(equalToConstant: 100).isActive = true
            
            return logo
        }()
        
        surveyTitle = {
            let label = UILabel()
            label.text = surveyViewController.surveyData.title
            label.font = .systemFont(ofSize: 24, weight: .medium)
            label.numberOfLines = 100
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            
            return label
        }()
        
        separator = {
            let separator = UIView()
            separator.backgroundColor = .init(white: 0.9, alpha: 1)
            separator.translatesAutoresizingMaskIntoConstraints = false
            
            separator.widthAnchor.constraint(equalToConstant: SEPARATOR_WIDTH).isActive = true
            separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
            
            return separator
        }()
        
        note = {
            let weblink = SURVEY_URL_PREFIX + "/" + surveyViewController.surveyData.surveyId
            
            let textView = UITextView()
            textView.text = "You are about to begin the [survey](\(weblink)). Swipe **left** to open up the first page and use swipe gestures to navigate through the pages."
            // This text view is NOT an actual consent form. The text style of consent form is used because it's most appropriate to display the survey instructions.
            textView.format(as: .consentText, theme: surveyViewController.theme)
            textView.textAlignment = .center
            textView.translatesAutoresizingMaskIntoConstraints = false
        
            return textView
        }()
        
        stackView = {
            let stack = UIStackView(arrangedSubviews: [
                logoImage, surveyTitle, separator, note
            ])
            stack.axis = .vertical
            stack.alignment = .center
            stack.spacing = 20.0
            stack.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(stack)
            
            stack.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 45).isActive = true
            stack.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -45).isActive = true
            stack.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: -5).isActive = true
            
            return stack
        }()
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        UIView.transition(with: surveyViewController.navigationMenu,
                          duration: 0.2,
                          options: .curveEaseInOut,
                          animations: {
                            self.surveyViewController.navigationMenu.alpha = 0.0
                          },
                          completion: nil)
        
        surveyViewController.navigationMenu.isUserInteractionEnabled = false
        
        surveyViewController.fragmentIndex = -1
    }
    

}
