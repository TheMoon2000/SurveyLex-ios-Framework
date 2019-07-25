//
//  SurveyViewController.swift
//  SurveyLex
//
//  Created by Jia Rui Shan on 2019/5/10.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

/// A subclass of `UIViewController` that displays a SurveyLex survey to the user.
class SurveyViewController: UIPageViewController,
                            UIPageViewControllerDataSource,
                            UIPageViewControllerDelegate {
    
    // MARK: - Instance variables
    
    /// Stores the `Survey` instance that called this view controller.
    var survey: Survey!
    
    /// The data for the survey that the controller is presenting.
    var surveyData: SurveyData!
    
    /// Whether the user has completed the first submission.
    var submittedOnce = false
    
    /**
     The current page of the survey (a survey can have multiple pages), indexed from 0. Updating its value will also update the navigation bar according to the survey progress made by the user.
     */
    var fragmentIndex = -1 {
        didSet (oldValue) {
            if fragmentIndex == -1 || fragmentIndex == oldValue { return }
            if fragmentIndex == fragmentPages.count {
                navigationItem.title = "Response Submission"
                progressIndicator.setProgress(1.0, animated: true)
            } else {
                navigationItem.title = surveyData.title + " (\(fragmentIndex + 1)/\(fragmentPages.count))"
                let percentage = Float(fragmentIndex + 1) / Float(fragmentPages.count)
                progressIndicator?.setProgress(percentage, animated: true)
            }
        }
    }
    
    /// Convenient shortcut for accessing the current fragment page.
    var currentFragment: SurveyPage {
        return fragmentPages[fragmentIndex]
    }
    
    /// Stores all the subviews for the survey elements, generated once
    /// before the survey is presented.
    var fragmentPages = [SurveyPage]()
    
    /// Contains the set of `FragmentTableController`s that have already been displayed at least once to the user.
    var visited = Set<Int>()
    
    /// The top bar that displays the survey progress.
    var progressIndicator: UIProgressView!
    
    /// Whether the user has already seen the submission notice dialog.
    var submissionNoticeShown = false
    
    
    // MARK: - UI Setup

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set start time
        surveyData.startTime = Date()
        
        // Generate the survey pages and set the `surveyViewController` attribute of every fragment to self.
        fragmentPages = surveyData.fragments.map { fragment in
            let page = fragment.contentVC
            page.surveyViewController = self
            return page
        }
        
        
        // Set up progress indicator in the navigation bar and load the first page.
        progressIndicator = addProgressBar()
        fragmentIndex = 0
        setViewControllers([fragmentPages[fragmentIndex]],
                           direction: .forward,
                           animated: false,
                           completion: nil)
                
        // Background color
        view.backgroundColor = .white
        
        // Set page view datasource and delegate
        dataSource = self
        delegate = self
        
        // Setup navigation bar appearance for cancel button
        let cancelButton = UIBarButtonItem(title: "Close",
                                           style: .done,
                                           target: self,
                                           action: #selector(closeSurvey))
        cancelButton.tintColor = DARKER_TINT
        navigationItem.rightBarButtonItem = cancelButton
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        survey.delegate?.surveyDidPresent(survey)
    }
    
    private func addProgressBar() -> UIProgressView {
        let bar = UIProgressView(progressViewStyle: .bar)
        bar.trackTintColor = UIColor(white: 0.9, alpha: 1)
        bar.progressTintColor = BUTTON_DEEP_BLUE
        bar.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(bar)
        bar.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        bar.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        bar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        
        return bar
    }
    
    @objc private func closeSurvey() {
        
        let updated = !fragmentPages.contains { !$0.uploaded }
                
        // Finished survey and everything is up to date, no message needs to be displayed
        if updated && submittedOnce {
            dismissSurvey()
            return
        }
        
        
        // Prepare an alert to display.
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        if submittedOnce {
            alert.title = "Unsaved Changes"
            alert.message = "You may have made unsaved changes to your response since your last submission. Do you want to first submit these changes, or discard them and leave?"
            alert.addAction(UIAlertAction(title: "Submit Changes", style: .default, handler: { action in
                let vc = SurveySubmission()
                vc.surveyViewController = self
                self.setViewControllers([vc],
                                        direction: .forward,
                                        animated: true,
                                        completion: nil)
            }))
            alert.addAction(UIAlertAction(title: "Discard and Leave", style: .destructive, handler: { action in self.dismissSurvey() }))
        } else {
            alert.title = "Are you sure?"
            alert.message = "You are about the leave the survey without submitting it. Any information you have entered will be discarded."
            alert.addAction(UIAlertAction(title: "Exit", style: submittedOnce ? .default : .destructive, handler: { action in self.dismissSurvey() }))
        }
        
        // Also dismiss the keyboard.
        self.currentFragment.view.endEditing(true)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func dismissSurvey() {
        self.survey.delegate?.surveyWillClose(self.survey, completed: false)
        
        // Clear cache
        try? FileManager.default.removeItem(at: AUDIO_CACHE_DIR)
        
        self.dismiss(animated: true) {
            self.survey.delegate?.surveyDidClose(self.survey, completed: false)
        }
    }
    
    // MARK: - Datasource methods for UIPageController
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return surveyData.fragments.count
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let index = (viewController as? SurveyPage)?.pageIndex else {
            return fragmentPages.last
        }
        
        if (index == 0) {
            return nil
        }
        
        return fragmentPages[index - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
    
        guard let index = (viewController as? SurveyPage)?.pageIndex else {
            return nil // There is no page after the submission page
        }
        
        // User has not yet completed the required questions on the current page, so do not proceed with the next one.
        if (!fragmentPages[index].unlocked) {
            return nil
        }
        
        if index + 1 < fragmentPages.count {
            return fragmentPages[index + 1]
        } else {
            let vc = SurveySubmission()
            vc.surveyViewController = self
            return vc
        }
    }
    
    /**
     Flips the page as long as the next page exists and all questions in the current fragment are completed.
     
     - Parameters:
        - allCompleted: Whether to require all questions to be completed in order for the page to flip (`true`) or only require required questions to be completed (`false`).
     
     - Returns: A boolean indicating whether the page was flipped.
    */
    
    func flipPageIfNeeded(allCompleted: Bool = true) -> Bool {
        let cond = allCompleted ? currentFragment.completed : currentFragment.unlocked

        if !cond {
            return false
        }
                
        if cond && fragmentIndex + 1 < fragmentPages.count {
//            fragmentIndex += 1
            self.setViewControllers([fragmentPages[fragmentIndex + 1]],
                                    direction: .forward,
                                    animated: true,
                                    completion: nil)
            return true
        } else if fragmentIndex + 1 == fragmentPages.count {
            submissionNotice()
        }
        return false
    }
    
    // MARK: - Page flip helper functions
    
    private func submissionNotice() {
        if submissionNoticeShown { return }
        
        submissionNoticeShown = true
        
        let alert = UIAlertController(title: "Survey Completed!", message: "You have already completed all the required questions in the survey. If you would like to submit now, please press 'Submit'. Alternatively, you can review your responses and submit later by swiping to the right.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Submit", style: .default) { action in
            
            let vc = SurveySubmission()
            vc.surveyViewController = self
            self.setViewControllers([vc],
                                    direction: .forward,
                                    animated: true,
                                    completion: nil)
        })
        
        alert.addAction(UIAlertAction(title: "Review", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    
    /**
     Flips the page only if the provided cell is the last cell in the current fragment and all questions in the current fragment are completed. Needs to be called before focus().
     
     - Returns: A boolean indicating whether the focus cell has changed.
     */
    
    func toNext(from cell: SurveyElementCell) -> Bool {
        reloadDatasource()

        if let fragmentTable = currentFragment as? FragmentTableController {
            var nextRow = fragmentTable.contentCells.firstIndex(of: cell)! + 1
            
            if nextRow % 2 == 1 { nextRow += 1 }
                        
            // Check if the next row exists and has not yet been completed
            let nextRowExists = nextRow < fragmentTable.contentCells.count
            if nextRowExists {
                let nextCell = fragmentTable.contentCells[nextRow]
                
                if fragmentTable.focusedRow == nextRow {
                    return false // The next row is the currently focused row.
                } else if !nextCell.completed {
                    fragmentTable.focusedRow = nextRow
                    return true
                } else {
                    return toNext(from: nextCell)
                }
            } else {
                return flipPageIfNeeded()
            }
        }
        
        return false
    }
    
    /// Reloads the datasource.
    func reloadDatasource() {
        dataSource = nil
        dataSource = self
    }
    
    func restartSurvey() {
        
    }
}
