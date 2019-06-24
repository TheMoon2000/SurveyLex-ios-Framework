//
//  SurveyViewController.swift
//  SurveyLex
//
//  Created by Jia Rui Shan on 2019/5/10.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//
//  This is the main View Controller that displays the survey to the user.

import UIKit

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
    var fragmentIndex = 0 {
        didSet {
            navigationItem.title = surveyData.title + " (\(fragmentIndex + 1)/\(fragmentTables.count))"
        }
    }
    
    /// Convenient shortcut for accessing the current fragment table.
    var currentFragment: FragmentTableController {
        return fragmentTables[fragmentIndex]
    }
    
    /// Stores all the subviews for the survey elements, generated once
    /// before the survey is presented.
    private var fragmentTables = [FragmentTableController]()
    
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
        fragmentIndex = 0
        
        view.backgroundColor = .white
        dataSource = self
        delegate = self
        
        setViewControllers([fragmentTables[0]],
                           direction: .forward,
                           animated: true,
                           completion: nil)
        
        progressIndicator = addProgressBar()
        
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
        bar.progress = 0
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
    
    // Datasource methods
    
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
    
        let index = fragmentTables.firstIndex(of: viewController as! FragmentTableController) ?? 0
        
        if (index + 1 == fragmentTables.count) {
            return nil
        } else if (!fragmentTables[index].unlocked) {
            return nil
        }
        
        return fragmentTables[index + 1]
    }
    
    // Delegate method
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let frag = pageViewController.viewControllers?.last as? FragmentTableController {
            if frag.fragmentIndex > fragmentIndex {
                updateCompletionRate(true)
            }
            fragmentIndex = frag.fragmentIndex
        }
    }
    
    /// Keeps track of the proportion of questions the user has completed
    ///
    /// - Parameters:
    ///    - treatOptionalAsCompleted: Whether we consider the current fragment
    ///      as completed if it is not a required question
    
    func updateCompletionRate(_ treatOptionalAsCompleted: Bool) {
        var completionTotal = 0
        
        if treatOptionalAsCompleted && currentFragment.unlocked {
            currentFragment.completed = true
        } else {
            currentFragment.updateCompletionStatusByQuestions()
        }
        
        fragmentTables.forEach {
            if $0.completed { completionTotal += 1 }
        }
        
        UIView.animate(withDuration: 0.15) {
            self.progressIndicator?.setProgress(Float(completionTotal) / Float(self.fragmentTables.count), animated: true)
        }
    }
    
    func nextPage() {
        updateCompletionRate(true)
        if fragmentIndex + 1 < fragmentTables.count && currentFragment.unlocked {
            fragmentIndex += 1
        self.setViewControllers([fragmentTables[fragmentIndex]],
                                direction: .forward,
                                animated: true, completion: nil)
        } else if fragmentIndex + 1 == fragmentTables.count {
            print("reached the end of survey")
        }
    }
    
    func previousPage() {
        if fragmentIndex > 0 {
            self.setViewControllers([fragmentTables[fragmentIndex]],
                                    direction: .reverse,
                                    animated: true,
                                    completion: nil)
        }
    }

}
