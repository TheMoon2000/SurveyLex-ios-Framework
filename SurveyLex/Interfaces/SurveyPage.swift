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
    
    /// Upload the survey taker's response for this fragment to the server. Each type of `SurveyPage` is responsible for uploading its own responses. Upon completing an upload, the page should send a notification of type `FRAGMENT_UPLOAD_COMPLETE`.
    func uploadResponse()
}

extension SurveyPage {
    
    /// A shortcut for referencing the current fragment index.
    var pageIndex: Int {
        return fragmentData.index
    }
    
    var theme: Survey.Theme {
        return surveyViewController?.theme ?? .blue
    }
        
    /// Broadcast a notification to the Notification Center that a fragment has been successfully submitted.
    func uploadCompleted() {
        fragmentData.needsReupload = false
        debugMessage("fragment \(self.pageIndex) uploaded")
        NotificationCenter.default.post(name: FRAGMENT_UPLOAD_COMPLETE, object: nil)
    }
    
    /// Broadcast a notification to the Notification Center that a fragment has failed to submit.
    func uploadFailed() {
        fragmentData.needsReupload = true
        NotificationCenter.default.post(name: FRAGMENT_UPLOAD_FAIL, object: nil)
    }
}
