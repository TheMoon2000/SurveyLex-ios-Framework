//
//  Survey.swift
//  SurveyLex
//
//  Created by Jia Rui Shan on 2019/5/10.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

public class Survey {
    
    private static let BASE_URL = "https://api.neurolex.ai/1.0/object/surveys/"
    
    private(set) var surveyID = ""
    private var targetVC: UIViewController?
    private(set) var surveyData: SurveyData?
    
    /// Initializes a new Survey by providing a JSON data source
    public init(json: JSON) {
        self.surveyData = SurveyData(json: json)
        self.surveyID = self.surveyData!.surveyId
    }
    
    /// Initializes a new Survey by providing the SurveyLex survey ID
    /// Parameter completionHandler - Whether
    public init(surveyID: String, target: UIViewController) {
        self.surveyID = surveyID
        targetVC = target
    }
    
    
    /// Displays the survey to the user.
    ///
    /// - Parameters:
    ///    - handler: An optional function that handles the survey response.
    public func presentWhenReady(_ handler: ((_ status: Response) -> ())?) {
        let address = Survey.BASE_URL + surveyID
        let lookupURL = URL(string: address)!
        let task = URLSession.shared.dataTask(with: lookupURL) {
            data, response, error in
            
            guard error == nil else {
                print(error!)
                return
            }
            
            do {
                let json = try JSON(data: data!)
                self.surveyData = SurveyData(json: json)
                print(self.surveyData!.description)
                DispatchQueue.main.async {
                    self.presentSurvey(handler)
                }
            } catch let err {
                print(err)
                DispatchQueue.main.async {
                    handler?(.error)
                }
            }
        }
        
        task.resume()
    }
    
    private func presentSurvey(_ handler: ((Response) -> ())?) {
        // surveyData is guaranteed to be non-nil
        
        if surveyData?.fragments.count == 0 {
            handler?(.error)
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
        case cancelled = 0
        case submitted = 1
        case error = -1
    }
}
