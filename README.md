# SurveyLex iOS Survey-taking Framework

## Using the Framework
To launch a survey, a you need to know the survey ID and the parent view controller on which the survey view controller is presenting. The survey ID of a SurveyLex survey is formatted as a UUID string, as in app.surveylex.com/surveys/**c741cba0-acca-11e9-aeb9-2b1c6d8db2a2**.

Within the view controller, a new `Survey` object can be easily constructed and presented:

```swift
let survey = Survey(surveyID: "c741cba0-acca-11e9-aeb9-2b1c6d8db2a2", target: self)
survey.loadAndPresent() // Asynchronous method
```

To update the view controller when it's loading, you can implement the optional `SurveyResponseDelegate`.

```swift

func launchSurvey() {
    let survey = Survey(surveyID: "c741cba0-acca-11e9-aeb9-2b1c6d8db2a2", target: self)
    survey.delegate = self
    survey.load() // Asynchronous method
    // Code to update view controller here...
}

func surveyDidLoad(_ survey: Survey) {
    // Code to finish update view controller...
    
    survey.present() // Present survey to `target`.
}
```

## Environment variables
- `allowMenuCollapse`: A boolean indicating whether choices that are expanded can be folded up again. By default its false.
- `autofocus`
- `isSubmissionMode: Bool`
- `showLandingPage: Bool`
- `showNavigationMenu: Bool`
- `allowsJumping: Bool`
- `theme: Survey.Theme`
