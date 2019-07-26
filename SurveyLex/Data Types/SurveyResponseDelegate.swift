//
//  SurveyResponseDelegate.swift
//  SurveyLex
//
//  Created by Jia Rui Shan on 2019/5/16.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

/// Handles events for a survey presentation.
public protocol SurveyResponseDelegate {
    
    /// Called when the `Survey` instance established a connection to the server and retrieved all necessary information about the survey.
    func surveyDidLoad(_ survey: Survey)
    
    func surveyEncounteredError(_ survey: Survey, error: Survey.Error, message: String?)
    
    func surveyFailedToPresent(_ survey: Survey, error: Survey.Error)
    
    /// Called when the survey is presented to the user.
    func surveyDidPresent(_ survey: Survey)
    
    func surveyWillClose(_ survey: Survey, completed: Bool)
    
    func surveyDidClose(_ survey: Survey, completed: Bool)
}

extension SurveyResponseDelegate {
    public func surveyDidLoad(_ survey: Survey) {}
    
    public func surveyDidPresent(_ survey: Survey) {}
    
    public func surveyFailedToPresent(_ survey: Survey, error: Survey.Error) {}
    
    public func surveyWillClose(_ survey: Survey, completed: Bool) {}

    public func surveyDidClose(_ survey: Survey, completed: Bool) {}
    
    public func surveyEncounteredError(_ survey: Survey, error: Survey.Error, message: String?) {
        switch error {
        case .invalidRequest:
            self.invalidSurveyWarning(survey)
        case .connectionError:
            self.noInternetConnectionWarning(survey)
        default:
            break
        }
        
        surveyFailedToPresent(survey, error: error)
    }
    
    private func invalidSurveyWarning(_ survey: Survey) {
        let alert = UIAlertController(title: "Survey Not Found",
                                      message: "Please check that the survey ID you provided is valid.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        survey.targetVC?.present(alert, animated: true, completion: nil)
    }
    
    private func noInternetConnectionWarning(_ survey: Survey) {
        let alert = UIAlertController(title: "Network Failure",
                                      message: "We were unable to establish connection to the server. Please check your internet connection.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        survey.targetVC?.present(alert, animated: true, completion: nil)
    }
    
    private func emptySurveyWarning(_ survey: Survey) {
        let alert = UIAlertController(title: "Empty Survey",
                                      message: "It is required that a survey has at least one page of content.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        survey.targetVC?.present(alert, animated: true, completion: nil)
    }
}
