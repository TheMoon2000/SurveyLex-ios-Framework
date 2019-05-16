//
//  Survey.swift
//  SurveyLex
//
//  Created by Jia Rui Shan on 2019/5/10.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

/// An interactive interface that presents a survey (powered by SurveyLex) for the user to fill.
public class Survey {
    
    /// The NeuroLex API URL prefix
    private static let BASE_URL = "https://api.neurolex.ai/1.0/object/surveys/"
    
    private(set) var surveyID = ""
    private var targetVC: UIViewController?
    private(set) var surveyData: SurveyData?
    
    /**
     Initializes a new `Survey` front-end by providing a JSON data source.
    
     - Parameters:
        - json: The input json source object to display.
     */
    public init(json: JSON) {
        self.surveyData = SurveyData(json: json)
        self.surveyID = self.surveyData!.surveyId
    }
    
    /**
     Initializes a new `Survey` by providing the SurveyLex survey ID.
     
     - Parameters:
        - surveyID: The identifier string associated with the survey (for lookup)
        - target: The view controller instance that will present the survey
    */
    public init(surveyID: String, target: UIViewController) {
        self.surveyID = surveyID
        targetVC = target
    }
    
    
    /**
     Displays the survey to the user.
    
     - Parameters:
        - handler: An optional function that handles the survey status.
    */
    public func presentWhenReady(_ handler: ((_ status: Response) -> ())?) {
        let address = Survey.BASE_URL + surveyID
        let lookupURL = URL(string: address)!
        let task = URLSession.shared.dataTask(with: lookupURL) {
            data, response, error in
            
            guard error == nil else {
                handler?(.connectionError)
                return
            }
            
            do {
                let json = try JSON(data: data!)
                self.surveyData = SurveyData(json: json)
                DispatchQueue.main.async {
                    self.presentSurvey(handler)
                }
            } catch let err {
                // Unable to parse JSON from url data
                DispatchQueue.main.async {
                    handler?(.serverError)
                }
            }
        }
        
        task.resume()
    }
    
    /// Private method to present the survey.
    private func presentSurvey(_ handler: ((Response) -> ())?) {
        // surveyData is guaranteed to be non-nil
        
        if surveyData?.fragments.count == 0 {
            handler?(.emptySurvey)
        }
        
        let mySurvey = SurveyViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        mySurvey.surveyData = self.surveyData!
        mySurvey.completionHandler = handler
        let nav = SurveyNavigationController(rootViewController: mySurvey)
        self.targetVC?.present(nav, animated: true, completion: nil)
    }
    
}


extension Survey {
    
    /// The response status of the survey.
    public enum Response : Int {
        
        /// The survey was closed before the user submitted their response.
        case cancelled = 0
        
        /// The survey was successfully submitted.
        case submitted = 1
        
        /// Invalid survey ID or some other server-side errors.
        case serverError = -1
        
        /// The user does not have a valid internet connection.
        case connectionError = -2
        
        /// The survey has no content.
        case emptySurvey = -3
    }
}
