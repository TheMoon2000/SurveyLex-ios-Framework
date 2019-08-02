//
//  SurveyData.swift
//  SurveyLex
//
//  Created by Jia Rui Shan on 2019/5/9.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

/// The root class of survey elements, which encapsulates the data for an entire survey form. A `SurveyData` object contains a list of `Fragment`s.
public class SurveyData: CustomStringConvertible {
    
    /// The title of the survey.
    let title: String
    // let creator: String
    
    /// The uuid of the survey.
    let surveyId: String
    
    /// Whether the survey is published.
    let published: Bool
    
    /// An array of survey fragments, each representing a page of the survey.
    var fragments = [Fragment]()
    
    /// The session ID.
    let sessionID = UUID().uuidString.lowercased()
    
    /// The same attribute as the `fragmentIndex` attribute in the survey view controller, but *DO NOT* modify this property. Instead, do it in the survey view controller.
    var fragmentIndex: Int
    
    /// Contains the set of `FragmentTableController`s that have already been displayed at least once to the user.
    var visited = Set<Int>()
    
    /// Whether the user has completed the first submission.
    var submittedOnce = false
    
    var logo: UIImage?
    
    var theme: Survey.Theme!
    
    /// Creates a new survey form using a JSON summary of the survey.
    required public init(json: JSON, theme: Survey.Theme, landingPage: Bool = true) throws {
        let dictionary = json.dictionaryValue
        
        guard let title = dictionary["title"]?.string,
              // let creator = dictionary["creator"]?.string,
              let surveyId = dictionary["surveyId"]?.string,
              let published = dictionary["published"]?.bool,
              let fragments = dictionary["fragments"]?.array
        else {
            print("Error parsing JSON survey data:", dictionary)
            throw Errors.invalid
        }
        
        self.title = title
        self.theme = theme
        self.surveyId = surveyId
        self.published = published
        
        fragmentIndex = landingPage ? -1 : 0
        
        for i in 0..<fragments.count {
            let newFragment = Fragment(json: fragments[i], index: i, parentSurvey: self)
            self.fragments.append(newFragment)
        }
    }
    
    /// Customized description that is more debug-friendly.
    public var description: String {
        let idParts = surveyId.components(separatedBy: "-")
        let fragmentDescription = fragments.map {
            $0.description.replacingOccurrences(of: "\n", with: "\n  ")
        }
        return "Survey <\(idParts[0])...\(idParts[4])> (\(fragments.count)): \n  " + fragmentDescription.joined(separator: "\n  ")
    }
    
}

extension SurveyData {
    /// All types errors that could be thrown from a failed SurveyData instantiation.
    enum Errors: Error {
        
        /// The provided JSON does not contain all the necessary attributes for a SurveyLex survey.
        case invalid
    }
}
