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
    
    /// The data for the survey that the controller is presenting.
    var surveyData: SurveyData!
    
    /// Optional handler for survey response, specified by the framework user.
    var completionHandler: ((Survey.Response) -> ())?
    
    /// The current page of the survey (a survey can have multiple pages).
    /// Updates the navigation bar according to the survey progress made by
    /// the user.
    var fragmentIndex = 0 {
        didSet {
            navigationItem.title = surveyData.title + " (\(fragmentIndex + 1)/\(fragmentTables.count))"
        }
    }
    
    /// Stores all the subviews for the survey elements, generated once
    /// before the survey is presented.
    private var fragmentTables = [UIViewController]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        precondition(surveyData != nil)
        
        fragmentTables = surveyData.fragments.map { $0.contentVC }
        fragmentIndex = 0
        
        view.backgroundColor = .white
        dataSource = self
        delegate = self
        
        setViewControllers([fragmentTables[0]],
                           direction: .forward,
                           animated: true,
                           completion: nil)
        
        // Setup navigation bar appearance
        let cancelButton = UIBarButtonItem(title: "Close",
                                           style: .done,
                                           target: self,
                                           action: #selector(surveyCancelled))
        navigationItem.rightBarButtonItem = cancelButton
    }
    
    @objc private func surveyCancelled() {
        completionHandler?(Survey.Response.cancelled)
        dismiss(animated: true, completion: nil)
    }
    
    // Datasource methods
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return surveyData.fragments.count
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        let index = fragmentTables.firstIndex(of: viewController) ?? 0
        
        if (index == 0) {
            return nil
        }
        
        return fragmentTables[index - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        let index = fragmentTables.firstIndex(of: viewController) ?? 0
        
        if (index + 1 == fragmentTables.count) {
            return nil
        }
        
        return fragmentTables[index + 1]
    }
    
    // Delegate method
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let frag = pageViewController.viewControllers?.last as? FragmentViewController {
            fragmentIndex = frag.fragmentIndex
        }
    }

}
