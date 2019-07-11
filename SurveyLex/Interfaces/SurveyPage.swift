//
//  SurveyPage.swift
//  SurveyLex Demo
//
//  Created by Jia Rui Shan on 2019/7/11.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

/// A set of required variables required for a generic survey page, regardless of its type.
protocol SurveyPage: UIViewController {
    /// The native `Fragment` representation of the content of this fragment.
    var fragmentData: Fragment! { get set }
    
    /// The parent `SurveyViewController` which will display this fragment as one of its pages.
    var surveyViewController: SurveyViewController? { get set }
    
    /// Whether the user can swipe right and proceed with the next page. That is, all the required questions have been completed.
    var unlocked: Bool { get }
    
    /// Whether all questions (required and optional) are completed by the user.
    var completed: Bool { get }
}

extension SurveyPage {
    var pageIndex: Int {
        return fragmentData.index
    }
}
