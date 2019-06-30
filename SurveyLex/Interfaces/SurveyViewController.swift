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
        didSet {
            if fragmentIndex == -1 { return }
            navigationItem.title = surveyData.title + " (\(fragmentIndex + 1)/\(fragmentTables.count))"
            let percentage = Float(fragmentIndex + 1) / Float(self.fragmentTables.count)
            progressIndicator?.setProgress(percentage, animated: true)
        }
    }
    
    /// Convenient shortcut for accessing the current fragment table.
    var currentFragment: FragmentTableController {
        return fragmentTables[fragmentIndex]
    }
    
    /// Stores all the subviews for the survey elements, generated once
    /// before the survey is presented.
    private var fragmentTables = [FragmentTableController]()
    
    /// Contains the set of `FragmentTableController`s that have already been displayed at least once to the user.
    var visitedFragments = Set<FragmentTableController>()
    
    /// The top bar that displays the survey progress.
    var progressIndicator: UIProgressView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        precondition(surveyData != nil)
        
        fragmentTables = surveyData.fragments.map { fragment in
            let fragmentTableController = fragment.contentVC
            fragmentTableController.surveyViewController = self
            return fragmentTableController
        }
        
        progressIndicator = addProgressBar()
        fragmentIndex = 0
        
        view.backgroundColor = .white
        dataSource = self
        delegate = self
        
        setViewControllers([fragmentTables[0]],
                           direction: .forward,
                           animated: true,
                           completion: nil)

        visitedFragments.insert(fragmentTables[0])
        
        // Setup navigation bar appearance
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
        survey.delegate?.surveyReturnedResponse(survey, response: .cancelled, message: nil)
        dismiss(animated: true, completion: nil)
    }
    
    // Datasource methods for UIPageController
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return surveyData.fragments.count
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        let index = fragmentTables.firstIndex(of: viewController as! FragmentTableController) ?? 0
        
        if (index == 0) {
            return nil
        }
        
        return fragmentTables[index - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
    
        guard let index = fragmentTables.firstIndex(of: viewController as! FragmentTableController) else {
            preconditionFailure("View controller not found")
        }
        
        if (index + 1 == fragmentTables.count) {
            return nil
        } else if (!fragmentTables[index].unlocked) {
            return nil
        }
                
        return fragmentTables[index + 1]
    }
    
    // Delegate method for UIPageController
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        // newFragment only exists if the page flip is complete.
        if let newFragment = pageViewController.viewControllers?.last as? FragmentTableController {
            fragmentIndex = newFragment.fragmentIndex
        }
    }
    
    /**
     Flip the page as long as the next page exists and all questions in the current fragment are completed.
     
     - Parameters:
        - allCompleted: Whether to require all questions to be completed in order for the page to flip (`true`) or only require required questions to be completed (`false`).
     
     - Returns: A boolean indicating whether the page was flipped.
    */
    
    func flipPageIfNeeded(allCompleted: Bool = true) -> Bool {
        let cond = allCompleted ? currentFragment.allCompleted : currentFragment.unlocked
        if cond && fragmentIndex + 1 < fragmentTables.count {
            fragmentIndex += 1
            self.setViewControllers([fragmentTables[fragmentIndex]],
                                    direction: .forward,
                                    animated: true,
                                    completion: nil)
            return true
        } else if fragmentIndex + 1 == fragmentTables.count {
            print("reached the end of survey")
        }
        return false
    }
    
    
    /**
     Flip the page only if the provided cell is the last cell in the current fragment and all questions in the current fragment are completed. Needs to be called before focus().
     
     - Returns: A boolean indicating whether the focus cell has changed.
     */
    
    func toNext(from cell: SurveyElementCell) -> Bool {
        reloadDatasource()
        var focusChanged = false
        let nextRow = currentFragment.contentCells.firstIndex(of: cell)! + 1
        if nextRow < currentFragment.contentCells.count && !currentFragment.contentCells[nextRow].completed {
            currentFragment.focusedRow = nextRow
            focusChanged = true
        } else if currentFragment.contentCells.last == cell {
            focusChanged = flipPageIfNeeded()
        }
        
        return focusChanged
    }
    
    /// Reload the datasource.
    func reloadDatasource() {
        dataSource = nil
        dataSource = self
    }
    
    /// Flip back to the previous page.
    func previousPage() {
        if fragmentIndex > 0 {
            fragmentIndex -= 1
            self.setViewControllers([fragmentTables[fragmentIndex]],
                                    direction: .reverse,
                                    animated: true,
                                    completion: nil)
        }
    }

}
