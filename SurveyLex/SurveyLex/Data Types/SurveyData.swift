//
//  SurveyData.swift
//  SurveyLex
//
//  Created by Jia Rui Shan on 2019/5/9.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

public struct SurveyData: CustomStringConvertible {
    let title: String
    let creator: String
    let surveyId: String
    let published: Bool
    var fragments = [Fragment]()
    
    /// Creates a new survey form using a JSON summary of the survey from NeuroLex's api.
    public init(json: JSON) {
        let dictionary = json.dictionaryValue
        
        guard let title = dictionary["title"]?.string,
              let creator = dictionary["creator"]?.string,
              let surveyId = dictionary["surveyId"]?.string,
              let published = dictionary["published"]?.bool,
              let fragments = dictionary["fragments"]?.array
        else {
            print(json)
            preconditionFailure("Malformed survey data")
        }
        
        self.title = title
        self.creator = creator
        self.surveyId = surveyId
        self.published = published
        
        self.fragments = fragments.map {Fragment(json: $0)}
    }
    
    /// Constructs a blank SurveyData object
    public init() {
        self.title = ""
        self.surveyId = ""
        self.published = false
        self.creator = ""
    }
    
    public var description: String {
        let idParts = surveyId.components(separatedBy: "-")
        let fragmentDescription = fragments.map {
            $0.description.replacingOccurrences(of: "\n", with: "\n  ")
        }
        return "Survey <\(idParts[0])...\(idParts[4])> (\(fragments.count)): \n  " + fragmentDescription.joined(separator: "\n  ")
    }
    
}
