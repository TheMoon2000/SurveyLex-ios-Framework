//
//  SurveyViewController.swift
//  SurveyLex
//
//  Created by Jia Rui Shan on 2019/5/10.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

/// A special subclass of `UIViewController` that displays a survey to the user.
class SurveyViewController: UIPageViewController,
                            UIPageViewControllerDataSource,
                            UIPageViewControllerDelegate {
    
    /// Stores the `Survey` instance that called this view controller.
    internal var survey: Survey!
    
    /// The data for the survey that the controller is presenting.
    var surveyData: SurveyData!
    
    /// The current page of the survey (a survey can have multiple pages).
    /// Updates the navigation bar according to the survey progress made by
    /// the user.
    var fragmentIndex = -1 {
        didSet (oldValue) {
            surveyData.fragmentIndex = fragmentIndex
            if fragmentIndex == -1 || fragmentIndex == oldValue { return }
            if fragmentIndex == fragmentPages.count {
                navigationItem.title = "Response Submission"
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
    private var fragmentPages = [SurveyPage]()
    
    /// Contains the set of `FragmentTableController`s that have already been displayed at least once to the user.
    var visited = Set<Int>()
    
    /// The top bar that displays the survey progress.
    var progressIndicator: UIProgressView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set start time
        surveyData.startTime = Date()
        
        // Set the `surveyViewController` attribute of every fragment to self.
        fragmentPages = surveyData.fragments.map { fragment in
            let page = fragment.contentVC
            page.surveyViewController = self
            return page
        }
        
        
        // Set up progress indicator in the navigation bar and load the first page.
        progressIndicator = addProgressBar()
        fragmentIndex = surveyData.fragmentIndex
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
                                           action: #selector(surveyCancelled))
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
    
    @objc private func surveyCancelled() {
        let alert = UIAlertController(title: "Are you sure?",
                                      message: "You are about the leave the survey. Any information you have entered will be discarded.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Exit", style: .destructive, handler: { action -> Void in
            self.survey.delegate?.surveyWillClose(self.survey, completed: false)
            self.dismiss(animated: true) {
                self.survey.delegate?.surveyDidClose(self.survey, completed: false)
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    // Datasource methods for UIPageController
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return surveyData.fragments.count
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        let index = (viewController as! SurveyPage).pageIndex
        
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
        if cond && fragmentIndex + 1 < fragmentPages.count {
//            fragmentIndex += 1
            self.setViewControllers([fragmentPages[fragmentIndex + 1]],
                                    direction: .forward,
                                    animated: true,
                                    completion: nil)
            return true
        } else if fragmentIndex + 1 == fragmentPages.count {
            let vc = SurveySubmission()
            vc.surveyViewController = self
            self.setViewControllers([vc],
                                    direction: .forward,
                                    animated: true,
                                    completion: nil)
        }
        return false
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
}
