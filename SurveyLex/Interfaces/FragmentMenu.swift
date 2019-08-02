//
//  FragmentMenu.swift
//  SurveyLex Demo
//
//  Created by Jia Rui Shan on 2019/7/29.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//
// A navigation menu that appears at the bottom of every page.

import UIKit

class FragmentMenu: UIVisualEffectView {
    
    /// The universal height of a fragment menu.
    var height: CGFloat {
        return (parentVC?.survey.showNavigationMenu ?? true) ? 50 : 0
    }
    
    var parentVC: SurveyViewController!
    
    var backButton: UIButton!
    var nextButton: UIButton!
    var goToPageButton: UIButton!
    private var stealthModeLabel: UILabel!
    private var currentAlertVC: UIAlertController?

    required init(parentVC: SurveyViewController, allowJumping: Bool) {
        super.init(effect: UIBlurEffect(style: .regular))
        
        self.parentVC = parentVC
        
        backButton = {
            let button = UIButton(type: .system)
            button.setImage(#imageLiteral(resourceName: "previous_thin"), for: .normal)
            button.tintColor = parentVC.theme.medium
            button.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(button)
            
            button.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor).isActive = true
            button.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 10).isActive = true
            
            button.addTarget(self, action: #selector(flipBack), for: .touchUpInside)
            
            return button
        }()
        
        nextButton = {
            let button = UIButton(type: .system)
            button.setImage(#imageLiteral(resourceName: "next_thin"), for: .normal)
            button.tintColor = parentVC.theme.medium
            button.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(button)
            
            button.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor).isActive = true
            button.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -10).isActive = true
            
            button.addTarget(self, action: #selector(flipNext), for: .touchUpInside)
            
            return button
        }()
        
        for button in [backButton, nextButton] {
            button?.imageView?.contentMode = .scaleAspectFit
            button?.widthAnchor.constraint(equalToConstant: 50).isActive = true
            button?.heightAnchor.constraint(equalToConstant: 19).isActive = true
        }
        
        goToPageButton = {
            let button = UIButton(type: .system)
            button.tintColor = parentVC.survey.mode == .submission ? parentVC.theme.dark : .gray
            button.isHidden = !allowJumping
            button.setTitle("Go to Page", for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
            button.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(button)
            
            button.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor).isActive = true
            button.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor).isActive = true
            
            button.addTarget(self, action: #selector(goToPage), for: .touchUpInside)
            
            return button
        }()
        
        stealthModeLabel = {
            let label = UILabel()
            label.text = "Stealth Mode"
            label.isHidden = !(parentVC.survey.mode == .stealth && goToPageButton.isHidden) // The opposite condition of showing
            label.textColor = .darkGray
            label.font = .systemFont(ofSize: 17)
            label.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(label)
            
            label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            
            return label
        }()
        
        addLines()
    }
    
    private func addLines() {
        let line = UIView()
        line.backgroundColor = .init(white: 0.9, alpha: 1)
        line.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(line)
        
        line.heightAnchor.constraint(equalToConstant: 1).isActive = true
        line.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        line.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        line.topAnchor.constraint(equalTo: topAnchor).isActive = true
        
        let line2 = UIView()
        line2.backgroundColor = .init(white: 0.9, alpha: 1)
        line2.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(line2)
        
        line2.heightAnchor.constraint(equalToConstant: 1).isActive = true
        line2.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        line2.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        line2.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    private func numberOfFragments() -> Int {
        return parentVC.fragmentPages.count
    }
    
    @objc private func goToPage() {
        
        let lowerBound = parentVC.survey.showLandingPage ? 0 : 1
        
        let alert = UIAlertController(title: "Go to Page", message: "Please enter a page number between \(lowerBound) and \(numberOfFragments()).", preferredStyle: .alert)
        alert.view.tintColor = parentVC.theme.dark
        
        currentAlertVC = alert
        
        alert.addTextField { textfield in
            textfield.placeholder = "Page number"
            textfield.keyboardType = .numberPad
            textfield.autocorrectionType = .no
            
            textfield.addTarget(self, action: #selector(self.pageNumberTextFieldValueChanged), for: .editingChanged)
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { action in
            self.currentAlertVC = nil
        })
        alert.addAction(UIAlertAction(title: "Go", style: .default) {
            action in
            self.goToPageHandler(alert: alert)
        })
        
        // By default, the page number textfield is blank so we disable the 'Go' button.
        alert.actions.last?.isEnabled = false

        parentVC.present(alert, animated: true, completion: nil)
    }
    
    @objc private func pageNumberTextFieldValueChanged(_ sender: UITextField) {
        let alert = currentAlertVC!
        if let pageNumber = Int(sender.text!) {
            if parentVC.survey.showLandingPage {
                alert.actions.last?.isEnabled = pageNumber >= 0 && pageNumber <= numberOfFragments()
            } else {
                alert.actions.last?.isEnabled = pageNumber > 0 && pageNumber <= numberOfFragments()
            }
        } else {
            alert.actions.last?.isEnabled = false
        }
    }
    
    /// Handles the 'Go' action from the 'Go To Page' alert.
    private func goToPageHandler(alert: UIAlertController) {
        let rawInputText = alert.textFields![0].text ?? ""
        
        // Assert that the input text is a valid integer.
        guard let pageNumber = Int(rawInputText) else {
            preconditionFailure("Internal inconsistency in page number")
        }
        
        parentVC.goToPage(page: pageNumber - 1)
        
        currentAlertVC = nil
    }
    
    // Forward and backward buttons
    
    @objc private func flipBack() {
        backButton.isUserInteractionEnabled = false
        parentVC.goToPage(page: parentVC.fragmentIndex - 1)
    }
    
    @objc private func flipNext() {
        nextButton.isUserInteractionEnabled = false
        if parentVC.fragmentIndex == parentVC.fragmentPages.count { return }
        if !parentVC.flipPageIfNeeded() {
            if let nextVC = parentVC.pageViewController(parentVC, viewControllerAfter: parentVC.currentFragment!) {
                parentVC.setViewControllers([nextVC],
                                            direction: .forward,
                                            animated: true,
                                            completion: nil)
            } else {
                debugMessage("Cannot flip to next page.")
            }
        }
    }
    
    /// Shortcut for setting the user interaction status of the flip buttons.
    func enableUserInteractions(_ enable: Bool) {
        isUserInteractionEnabled = true
        backButton.isUserInteractionEnabled = enable
        nextButton.isUserInteractionEnabled = enable
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
