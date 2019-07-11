//
//  SurveySubmission.swift
//  SurveyLex Demo
//
//  Created by Jia Rui Shan on 2019/7/4.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

class SurveySubmission: UIViewController {

    var surveyViewController: SurveyViewController!
    
    private var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel = {
            let label = UILabel()
            label.text = "Submit"
            label.font = .systemFont(ofSize: 30, weight: .medium)
            label.textColor = .darkGray
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            
            label.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor,
                                           constant: -50).isActive = true
            
            return label
        }()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        titleLabel.text = "Submitting response..."
        submitResponse()
    }
    
    private func submitResponse() {
        let dateString = ISO8601DateFormatter().string(from: surveyViewController.surveyData.startTime)
        
        var sessionJSON = JSON()
        sessionJSON.dictionaryObject?["startTime"] = dateString
        sessionJSON.dictionaryObject?["sessionId"] = surveyViewController.surveyData.sessionID
        sessionJSON.dictionaryObject?["surveyId"] = surveyViewController.surveyData.surveyId
        
        print("session JSON: \(sessionJSON)")
        
        for f in surveyViewController.surveyData.fragments {
            print(f.fragmentJSON)
        }
    }

}

