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
    
    static let BASE_URL = "https://api.neurolex.ai/1.0/object/surveys/"
    
    private(set) var surveyData: SurveyData?
    
    /// Initializes a new Survey by providing a JSON data source
    public init(json: JSON) {
        self.surveyData = SurveyData(json: json)
    }
    
    /// Initializes a new Survey by providing the SurveyLex survey ID
    /// Parameter completionHandler - Whether
    public init(surveyID: String, completionHandler: ((Bool) -> ())?) {
        let address = Survey.BASE_URL + surveyID
        let lookupURL = URL(string: address)!
        let task = URLSession.shared.dataTask(with: lookupURL) { [weak self]
            data, response, error in
            
            if (error != nil) {
                print(error!)
            }
            
            do {
                let json = try JSON(data: data!)
                self?.surveyData = SurveyData(json: json)
                print(SurveyData(json: json))
                completionHandler?(true)
            } catch let err {
                print(err)
                completionHandler?(false)
            }
        }
        
        task.resume()
    }
    
}
