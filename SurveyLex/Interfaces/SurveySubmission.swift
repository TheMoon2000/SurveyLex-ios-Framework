//
//  SurveySubmission.swift
//  SurveyLex Demo
//
//  Created by Jia Rui Shan on 2019/7/4.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

class SurveySubmission: UIViewController {

    var surveyViewController: SurveyViewController!
    
    private var titleLabel: UILabel!
    private var finishIcon: UIImageView!
    private var spinner: UIActivityIndicatorView!
    private var progressBar: UIProgressView!
    private var shareButton: UIButton!
    private var reviewResponse: UIButton!
    private var buttonStack: UIStackView!
    
    private var timeoutTimer: Timer?
    
    var percentageCompleted: Float = 0.0 {
        didSet {
            self.progressBar.setProgress(percentageCompleted, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        finishIcon = {
            let imageView = UIImageView()
            imageView.image = #imageLiteral(resourceName: "baseline-check")
            imageView.contentMode = .scaleAspectFit
            imageView.isHidden = true
            imageView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(imageView)
            
            imageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
            imageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
            imageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
            
            return imageView
        }()
        
        spinner = {
            let spinner = UIActivityIndicatorView(style: .whiteLarge)
            spinner.hidesWhenStopped = true
            spinner.color = .lightGray
            spinner.startAnimating()
            spinner.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(spinner)
            
            spinner.centerXAnchor.constraint(equalTo: finishIcon.centerXAnchor).isActive = true
            spinner.centerYAnchor.constraint(equalTo: finishIcon.centerYAnchor).isActive = true
            
            return spinner
        }()
        
        titleLabel = {
            let label = UILabel()
            label.text = "Submit"
            label.font = .systemFont(ofSize: 26)
            label.textColor = .darkGray
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            
            label.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: -20).isActive = true
            label.topAnchor.constraint(equalTo: finishIcon.bottomAnchor, constant: 12).isActive = true
            
            return label
        }()
        
        progressBar = {
            let bar = UIProgressView()
            bar.progressTintColor = BLUE_TINT
            bar.trackTintColor = .init(white: 0.91, alpha: 1)
            bar.progress = 0
            bar.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(bar)
            
            bar.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 40).isActive = true
            bar.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -40).isActive = true
            bar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 15).isActive = true
            
            return bar
        }()
        
        reviewResponse = {
            let button = UIButton(type: .system)
            
            button.addTarget(self, action: #selector(review), for: .touchUpInside)
            button.setTitle("Review", for: .normal)
            button.translatesAutoresizingMaskIntoConstraints = false
            
            return button
        }()
        
        shareButton = {
            let button = UIButton(type: .system)
            
            button.setTitle("Share", for: .normal)
            button.addTarget(self, action: #selector(shareSurvey), for: .touchUpInside)
            button.translatesAutoresizingMaskIntoConstraints = false
            
            return button
        }()
        
        buttonStack = {
            
            // Format the buttons in the same way
            for button in [reviewResponse!, shareButton!] {
                button.tintColor = .white
                button.backgroundColor = BLUE_TINT
                button.layer.cornerRadius = 5
                button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
            }
            
            let stack = UIStackView(arrangedSubviews: [reviewResponse, shareButton])
            stack.spacing = 20
            stack.distribution = .fillEqually
            stack.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(stack)
            
            stack.leftAnchor.constraint(equalTo: progressBar.leftAnchor).isActive = true
            stack.rightAnchor.constraint(equalTo: progressBar.rightAnchor).isActive = true
            stack.heightAnchor.constraint(equalToConstant: 40).isActive = true
            stack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20).isActive = true
            
            stack.isHidden = true
            
            return stack
        }()
        
        // Add self as an observer for upload responses.
        NotificationCenter.default.addObserver(self, selector: #selector(updateProgress), name: FRAGMENT_UPLOAD_COMPLETE, object: nil)
    }
    
    @objc private func review() {
        surveyViewController.setViewControllers([surveyViewController.fragmentPages[0]],
                                                direction: .reverse,
                                                animated: true,
                                                completion: nil)
    }
    
    @objc private func shareSurvey() {
        let shareItem = [URL(string: SURVEY_URL_PREFIX + "/" + surveyViewController.survey.surveyID)!]
        let ac = UIActivityViewController(activityItems: shareItem, applicationActivities: nil)
        present(ac, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        surveyViewController.fragmentIndex = surveyViewController.fragmentPages.count
        updateProgress()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateProgress()
    }
    
    /// Refreshes the upload progress and updates the front-end.
    @objc private func updateProgress() {
        let uploaded = surveyViewController.fragmentPages.filter { page in
            
            if page.needsReupload {
                page.uploadResponse()
            }
            
            return page.uploaded
        }.count
        
        DispatchQueue.main.async {
            self.percentageCompleted = Float(uploaded) / Float(self.surveyViewController.fragmentPages.count)
            if uploaded == self.surveyViewController.fragmentPages.count {
                self.spinner.stopAnimating()
                self.titleLabel.text = "Submitted"
                self.finishIcon.isHidden = false
                self.progressBar.isHidden = true
                self.buttonStack.isHidden = false
                self.surveyViewController.submittedOnce = true
            } else {
                self.spinner.startAnimating()
                self.titleLabel.text = "Submitting response..."
                self.progressBar.isHidden = false
                self.finishIcon.isHidden = true
                self.buttonStack.isHidden = true
                self.surveyViewController.submittedOnce = false
            }
        }
    }
}

