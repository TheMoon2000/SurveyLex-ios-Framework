//
//  SurveyResponseDelegate.swift
//  SurveyLex
//
//  Created by Jia Rui Shan on 2019/5/16.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

public protocol SurveyResponseDelegate {
    
    /// Called when the `Survey` instance established a connection to the server and retrieved all necessary information about the survey.
    func surveyDidLoad(_ survey: Survey)
    
    func surveyReturnedResponse(_ survey: Survey, response: Survey.Response)
    
    /// Called when the survey is presented to the user.
    func surveyDidPresent(_ survey: Survey)
}

extension SurveyResponseDelegate {
    func surveyDidPresent(_ survey: Survey) {}
}
