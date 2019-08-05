//
//  SurveyViewController.swift
//  SurveyLex
//
//  Created by Jia Rui Shan on 2019/5/10.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

/// A subclass of `UIViewController` that displays a SurveyLex survey to the user.
class SurveyViewController: UIPageViewController {
    
    // MARK: - Instance variables
    
    /// Stores the `Survey` instance that called this view controller.
    var survey: Survey!
    
    /// The data for the survey that the controller is presenting.
    var surveyData: SurveyData!
    
    var theme: Survey.Theme {
        return survey.theme
    }
    
    var navigationMenu: FragmentMenu!
    
    /**
     The current page of the survey (a survey can have multiple pages), indexed from 0. Updating its value will also update the navigation bar according to the survey progress made by the user.
     */
    var fragmentIndex = -1 {
        didSet (oldValue) {
            
            // We always keep a copy of the current fragment index in `surveyData` because `surveyData` is preserved between different launches of the same survey and is used to recover the current page.
            surveyData.fragmentIndex = fragmentIndex
            
            // Fragment index -1 is reserved for the landing page.
            if fragmentIndex == -1 {
                navigationItem.title = surveyData.title
                UIView.animate(withDuration: 0.35) {
                    self.progressIndicator?.setProgress(0, animated: true)
                }
            // Fragment `fragmentPages.count` is reserved for the submission page.
            } else if fragmentIndex == fragmentPages.count {
                navigationItem.title = "Response Submission"
                UIView.animate(withDuration: 0.35) {
                    self.progressIndicator.setProgress(1.0, animated: true)
                }
            } else {
                navigationItem.title = surveyData.title + " (\(fragmentIndex + 1)/\(fragmentPages.count))"
                let percentage = Float(fragmentIndex + 1) / Float(fragmentPages.count)
                UIView.animate(withDuration: 0.35) {
                    self.progressIndicator?.setProgress(percentage, animated: true)
                }
            }
        }
    }
    
    /// Convenient shortcut for accessing the current fragment page.
    var currentFragment: SurveyPage? {
        if fragmentIndex == -1 || fragmentIndex == fragmentPages.count { return nil }
        return fragmentPages[fragmentIndex]
    }
    
    /// Stores all the subviews for the survey elements, generated once before the survey is presented.
    var fragmentPages = [SurveyPage]()
    
    /// The top bar that displays the survey progress.
    var progressIndicator: UIProgressView!
    
    /// Whether the user has already seen the submission notice dialog.
    var submissionNoticeShown = false
    
    /// Records the progress of the user's current swipe gesture. Negative values indicate a backward swipe.
    var transitionProgress: CGFloat = 0.0 {
        didSet {
            // Update bar percentage
            let barPercentage = (Float(fragmentIndex + 1) + Float(transitionProgress)) / Float(fragmentPages.count)
            progressIndicator.setProgress(barPercentage, animated: true)
            
            if (currentFragment?.fixScreen ?? false) {
                return
            }
            
            // Update navigation menu
            if transitionProgress < 0 {
                // Case 1: swiping back from the first page
                if fragmentIndex == 0 && survey.showLandingPage {
                    navigationMenu.alpha = 1.0 + transitionProgress
                // Case 2: swiping back from the submission page
                } else if fragmentIndex == fragmentPages.count {
                    navigationMenu.alpha = -transitionProgress
                }
            } else if transitionProgress > 0 {
                // Case 1: swiping forward from the landing page
                if fragmentIndex == -1 {
                    navigationMenu.alpha = transitionProgress
                // Case 2: swiping forward from the last survey page
                } else if fragmentIndex == fragmentPages.count - 1 {
                    navigationMenu.alpha = 1 - transitionProgress
                }
            }
        }
    }
    
    
    // MARK: - UI Setup

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Generate the survey pages and set the `surveyViewController` attribute of every fragment to self.
        fragmentPages = surveyData.fragments.map { fragment in
            let page = fragment.contentVC
            page.surveyViewController = self
            return page
        }
        
        // Detect keyboard show & hide events
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
        
        // Set up progress indicator in the navigation bar and load the first page.
        progressIndicator = {
            let bar = UIProgressView(progressViewStyle: .bar)
            bar.trackTintColor = survey.mode == .submission ? theme.highlight : .init(white: 0.9, alpha: 1)
            bar.progressTintColor = survey.mode == .submission ? theme.medium : .lightGray
            bar.translatesAutoresizingMaskIntoConstraints = false
            
            view.addSubview(bar)
            bar.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            bar.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            bar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
            
            return bar
        }()
        
        // Setup navigation menu
        navigationMenu = {
            let menu = FragmentMenu(parentVC: self, allowJumping: survey.allowJumping)
            menu.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(menu)
            
            menu.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            menu.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            menu.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -menu.height).isActive = true
            menu.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

            return menu
        }()
        
        // Load up the landing page or first page of the survey
        
        fragmentIndex = surveyData.fragmentIndex
        
        let page: UIViewController
        if fragmentIndex == -1 {
            // Landing page
            let landingPage = LandingPage()
            landingPage.surveyViewController = self
            page = landingPage
        } else {
            // There is no landing page
            page = fragmentPages[fragmentIndex]
        }
        
        // If `showNavigationMenu` is false, hide the menu completely.
        navigationMenu.isHidden = !survey.showNavigationMenu
        
        setViewControllers([page],
                           direction: .forward,
                           animated: false,
                           completion: nil)
        
        
        // Background color
        view.backgroundColor = .white
        
        // Set page view datasource and delegate
        dataSource = self
        
        // Setup navigation bar appearance for cancel button
        let cancelButton = UIBarButtonItem(title: "Close",
                                           style: .done,
                                           target: self,
                                           action: #selector(closeSurvey))
        cancelButton.tintColor = theme.dark
        navigationItem.rightBarButtonItem = cancelButton
        
        // Prepare for transition progress detection
        view.subviews.forEach { ($0 as? UIScrollView)?.delegate = self }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Call delegate method
        survey.delegate?.surveyDidPresent(survey)
    }
    
    /// Method linked with the close button.
    @objc private func closeSurvey() {
        
        let updated = !fragmentPages.contains { !$0.fragmentData.uploaded }
                
        // Finished survey and everything is up to date, no message needs to be displayed.
        if updated && surveyData.submittedOnce {
            clearCache()
            dismissSurvey()
            return
        }
        
        
        // Prepare an alert to display.
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        alert.view.tintColor = theme.dark
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        if surveyData.submittedOnce {
            // If the user has made their first submission, then display the following dialog.
            alert.title = "Unsaved Changes"
            alert.message = "You may have made unsaved changes to your response since your last submission. Do you want to submit these changes now?"
            alert.addAction(UIAlertAction(title: "Submit Changes", style: .default, handler: { action in
                let vc = SurveySubmission()
                vc.surveyViewController = self
                self.setViewControllers([vc],
                                        direction: .forward,
                                        animated: true,
                                        completion: nil)
            }))
            alert.addAction(UIAlertAction(title: "Leave", style: .default, handler: { action in self.dismissSurvey() }))
        } else {
            
            // If the user hasn't yet submitted anything, then warn them.
            alert.title = "Are you sure?"
            
            if survey.useCache {
                alert.message = "You are about the leave the survey without submitting it."
                alert.addAction(UIAlertAction(title: "Save and Exit", style: surveyData.submittedOnce ? .default : .default, handler: { action in self.dismissSurvey() }))
            } else {
                alert.message = "You are about to leave the survey and discard all changes."
            }
            alert.addAction(UIAlertAction(title: "Discard Changes and Exit", style: .destructive, handler: { action in
                self.clearCache()
                self.dismissSurvey()
            }))
        }
        
        // Also dismiss the keyboard
        self.currentFragment?.view.endEditing(true)
        
        // Show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    // Call delegate methods
    private func dismissSurvey() {
        self.survey.delegate?.surveyWillClose(self.survey, completed: false)
        
        self.dismiss(animated: true) {
            self.survey.delegate?.surveyDidClose(self.survey, completed: false)
        }
    }
    
    /// Clears the cache of a survey. This involves deleting any WAV recordings and removing the survey data object from memory.
    private func clearCache() {
        try? FileManager.default.removeItem(at: AUDIO_CACHE_DIR)
        Survey.cached.removeValue(forKey: surveyData.surveyId)
    }
    
    /**
     Flips the page as long as the next page exists and all questions in the current fragment are completed.
     
     - Parameters:
        - allCompleted: Whether to require all questions to be completed in order for the page to flip (`true`) or only require required questions to be completed (`false`).
     
     - Returns: A boolean indicating whether the page was flipped.
    */
    
    func flipPageIfNeeded(allCompleted: Bool = true) -> Bool {
        
        if fragmentIndex == -1 {
            self.setViewControllers([fragmentPages[0]],
                                    direction: .forward,
                                    animated: true,
                                    completion: nil)
            return true
        } else if fragmentIndex == fragmentPages.count {
            return false // There is no next page after submission page
        }
        
        let cond = allCompleted ? currentFragment!.completed : currentFragment!.unlocked

        guard cond else { return false }
        
        if fragmentIndex + 1 < fragmentPages.count {
            DispatchQueue.main.async {
                self.setViewControllers([self.fragmentPages[self.fragmentIndex + 1]],
                                        direction: .forward,
                                        animated: true,
                                        completion: nil)
            }
            return true
        } else if fragmentIndex + 1 == fragmentPages.count && !submissionNoticeShown {
            submissionNotice()
            return true
        }
        return false
    }
    
    /// Animate to the specific page (indexed at 0).
    func goToPage(page: Int) {
        
        // If the given page number is the same as that of the current page number, no work needs to be done.
        if page == fragmentIndex { return }
        
        // If the given page is -1, then it's going to be the landing page
        if page == -1 {
            if survey.showLandingPage {
                let landingPage = LandingPage()
                landingPage.surveyViewController = self
                setViewControllers([landingPage], direction: .reverse, animated: true, completion: nil)
            }
            return
        }
        
        // If out of bounds, do nothing (theoretically, page should already be checked before passing into this method).
        if page >= fragmentPages.count || page < -1 {
            debugMessage("WARNING: 'goToPage(:_)' method in SurveyViewController received out-of-bounds page number!")
            return
        }
        
        // Verify that every page is unlocked leading up to the provided page.
        var canVisitPage = true
        
        for i in 0..<page {
            if !fragmentPages[i].unlocked {
                canVisitPage = false
            }
        }
        
        // If the provided page is still locked, then give a warning.
        guard canVisitPage else {
            let warning = UIAlertController(title: "Cannot Visit Page", message: "One or more of the intermediate pages are not yet completed. Please complete these pages first.", preferredStyle: .alert)
            warning.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            present(warning, animated: true, completion: nil)
            return
        }
        
        // Decide which animation to use (forward / reverse) and present the new page.
        let direction: UIPageViewController.NavigationDirection = page > fragmentIndex ? .forward : .reverse
        
        // Present the new page using an animation
        let newPage = fragmentPages[page]
        setViewControllers([newPage], direction: direction, animated: true, completion: nil)
        
    }
    
    // MARK: - Page flip helper functions
    
    private func submissionNotice() {
        
        submissionNoticeShown = true
        
        let alert = UIAlertController(title: "Survey Completed!", message: "You have already completed all the required questions in the survey. If you would like to submit now, please press 'Submit'. Alternatively, you can review your responses and submit later by swiping to the right.", preferredStyle: .alert)
        
        alert.view.tintColor = theme.dark
        
        alert.addAction(UIAlertAction(title: "Submit Now", style: .default) { action in
            
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
     Flips the page only if the provided cell is the last cell in the current fragment and all questions in the current fragment are completed. This method should be called every time the user finished a question.
     
     - Returns: A boolean indicating whether the focus cell has changed.
     */
    
    func toNext(from cell: SurveyElementCell) -> Bool {
        
        // (1) Datasource is reloaded
        DispatchQueue.main.async {
            self.reloadDatasource()
        }

        if let fragmentTable = currentFragment as? FragmentTableController {
            var nextRow = fragmentTable.contentCells.firstIndex(of: cell)! + 1
            
            if nextRow % 2 == 1 { nextRow += 1 }
            
            // Check if the next row exists and has not yet been completed
            let nextRowExists = nextRow < fragmentTable.contentCells.count
            if nextRowExists {
                let nextCell = fragmentTable.contentCells[nextRow]
                if !nextCell.completed {
                    fragmentTable.focusedRow = nextRow
                    // (2) We must focus on the cell asynchronously because (1) needs to happen first, otherwise keyboard will be hidden for text questions.
                    DispatchQueue.main.async {
                        nextCell.focus()
                        fragmentTable.scrollToRow(row: nextRow)
                    }
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

// MARK: - Scrolling progress detection

extension SurveyViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        // Only update the `transitionProgress` if the menu is enabled to save CPU.
        if survey.showNavigationMenu {
            let point = scrollView.contentOffset
            let percentComplete = (point.x - view.frame.size.width) / view.frame.size.width
            transitionProgress = percentComplete
        }
    }
}

// MARK: - Datasource methods for UIPageController

extension SurveyViewController: UIPageViewControllerDataSource {
    
    /// Here, we would like to figure out what the previous page of the page view controller will be, based on what the current page is.
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        // First page has no previous page.
        if viewController is LandingPage {
            return nil
        }
        
        // A submission page's last page is the last page of the survey.
        if viewController is SurveySubmission {
            return fragmentPages.last
        }
        
        // Otherwise, we know that the current page must be a page of the survey, so it must have an index!
        let index = (viewController as! SurveyPage).pageIndex
        
        // Landing page only exists if `showLandingPage` is set to true. Otherwise, we cannot go left on the first page of the survey.
        if index == 0 {
            if survey.showLandingPage {
                let landingPage = LandingPage()
                landingPage.surveyViewController = self
                return landingPage
            } else {
                return nil
            }
        }
        
        // Special case for audio questions during recording.
        if let a = (fragmentPages[index] as? AudioPage), a.recordButton.isRecording {
            return nil
        }
        
        // Otherwise, the previous page is nothing more than the previous item in the array of survey pages.
        return fragmentPages[index - 1]
    }
    
    /// Here, we would like to figure out what the next page of the page view controller will be, based on what the current page is.
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        // The next page for a landing page is always the first page of the survey.
        if viewController is LandingPage {
            return fragmentPages.first
        }
        
        // There is no next page for a submission page.
        if viewController is SurveySubmission {
            return nil
        }
        
        // Otherwise, the current page must be a subclass of `SurveyPage` and so we have an index for it!
        let index = (viewController as! SurveyPage).pageIndex
        
        // Special case for consent page - only allow page flip is user agreed to the consent form.
        if let c = (fragmentPages[index] as? FragmentTableController)?.contentCells.first as? ConsentCell {
            if !c.completed {
                return nil
            }
        }
        
        // If the screen is fixed, then do not allow page flip.
        if fragmentPages[index].fixScreen {
            return nil
        }
        
        // User has not yet completed the required questions on the current page, so do not proceed with the next one.
        if (!fragmentPages[index].unlocked) {
            return nil
        }
        
        // If the current index points to the last page of the survey, the next page will be a submission page.
        if index + 1 == fragmentPages.count {
            let vc = SurveySubmission()
            vc.surveyViewController = self
            return vc
        }
        
        // Otherwise, the next page is simply the next item in the array of survey pages.
        return fragmentPages[index + 1]

    }
}

// MARK: - Adjust scroll view inset depending on the keyboard status

extension SurveyViewController {

    /// If the keyboard is showing, then the navigation menu is covered by the keyboard, so any bottom inset should be set to 0. Remember, the whole point of insetting the bottom of a scroll view is to make room for the navigation menu.
    @objc private func keyboardWillShow(_ notification: Notification) {
        if let tblvc = currentFragment as? FragmentTableController {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                tblvc.tableView.contentInset.bottom = 0
                tblvc.tableView.scrollIndicatorInsets.bottom = 0
            }, completion: nil)
        }
    }
    
    /// If the keyboard is hidden, then we need to pad some extra space for the navigation menu at the bottom of the scroll view. The height of the navigation menu is 0 if `showNavigation = false` for the survey.
    @objc private func keyboardWillHide(_ notification: Notification) {
        if let tblvc = currentFragment as? FragmentTableController {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                tblvc.tableView.contentInset.bottom = self.navigationMenu.height
                tblvc.tableView.scrollIndicatorInsets.bottom = self.navigationMenu.height
            }, completion: nil)
        }
    }
}
