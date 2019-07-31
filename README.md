# SurveyLex iOS Survey-taking Framework

## Introduction
This Swift framework (iOS 11.0+) is designed to natively store, display and submit the most common elements in a typical online survey, and its precise architecture is engineered based on  [SurveyLex](https://www.surveylex.com), a survey-taking platform developed by [NeuroLex Laboratories Inc](https://neurolex.ai). The types survey elements that are currently supported are:
- Consent form
- Multiple choice questions
- Checkbox questions
- Text response questions
- Audio response questions
- Rating questions
- Info screens

## Launching a Survey
To launch a survey, a you need to know the survey ID and the parent view controller on which the survey view controller is presenting. The survey ID of a SurveyLex survey is formatted as a UUID string, as in app.surveylex.com/surveys/**c741cba0-acca-11e9-aeb9-2b1c6d8db2a2**.

Within the view controller, a new `Survey` object can be easily constructed and presented:

```swift
let survey = Survey(surveyID: "c741cba0-acca-11e9-aeb9-2b1c6d8db2a2", target: self)
survey.loadAndPresent() // Asynchronous method
```

To update the view controller when the survey is loading up, you can implement the optional `SurveyResponseDelegate`.

```swift

func launchSurvey() {
    let survey = Survey(surveyID: "c741cba0-acca-11e9-aeb9-2b1c6d8db2a2", target: self)
    survey.delegate = self
    survey.load() // Asynchronous method
    // Code to update view controller here...
}


// MARK: - Survey Response delegate

func surveyDidLoad(_ survey: Survey) {
    // Code to finish update view controller...

    survey.present() // Present survey to `target`.
}
```

## Environment variables
- `allowMenuCollapse`: A boolean indicating whether choices that are expanded can be folded up again. Default is `false`.
- `autofocus`: Whether the current item on a page of a survey has higher opacity than other elements. Default is `true`. <br>
  <img src="Screenshots/autofocus.png" width="250" style="border: 1px dashed #e5e5e5">
- `isSubmissionMode`: A boolean indicating whether the survey maintains an active connection with the server (i.e. a session is created on open, and responses are uploaded). The opposite of submission mode is **stealth mode**, where no data ever leaves the device throughout the survey-taking process. Default is `true`.
- `showLandingPage`: A boolean indicating whether a landing page is shown when a survey is launched. The landing page consists of the survey title, a built-in description, and shows a survey logo if the survey has one. Default is `true`.
- `showNavigationMenu`: A boolean indicating whether a navigation menu is shown at the bottom of the survey for flipping pages. <u>Note that you can always use swipe gestures to flip pages</u>. Default is `true`.
- `allowsJumping`: Whether the user can see a 'Go to Page' button in the navigation menu that allows them to jump to any unlocked page. Default is `false`.
- `theme`: A `Survey.Theme` type variable containing the theme colors the survey should use. A few pre-defined themes are provided:
  - `Survey.Theme.blue` (Default)
  - `Survey.Theme.green`
  - `Survey.Theme.cyan`
  - `Survey.Theme.purple`
  - You can built your own theme by using the `Survey.Theme()` constructor, specifying four colors: **dark**, **medium**, **light**, and **highlight**.
