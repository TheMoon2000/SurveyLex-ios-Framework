# SurveyLex iOS Survey-taking Framework

## Introduction
This Swift framework (iOS 11.0+) is designed to natively store, display and submit the most common components in a typical survey on mobile devices, and its precise architecture is engineered based on [SurveyLex](https://www.surveylex.com), a survey-taking platform developed by [NeuroLex Laboratories Inc](https://neurolex.ai). The types survey elements that are currently supported are:
- Consent form
- Multiple choice questions
- Checkbox questions
- Text response questions
- Audio response questions
- Rating questions
- Info screens

Once a component is completed, the next component will altomatically be focused, with the exception of checkbox questions (because we don't know when the user is done with the question).

<img src="Screenshots/overview.gif" width="240">

## Launching a Survey
To launch a survey, a you need to know the survey ID and the parent view controller on which the survey view controller is presenting. The survey ID of a SurveyLex survey is formatted as a UUID string, as in app.surveylex.com/surveys/**c741cba0-acca-11e9-aeb9-2b1c6d8db2a2**.

Within the view controller, a new `Survey` object can be easily configured and presented:

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
- `visibilityDifferentiation`: Whether the current item on a page of a survey has higher opacity than other elements. Default is `true`. <br>
  <img src="Screenshots/autofocus.png" width="240">
- `mode`: A `Survey.Mode` property that is either `submission` or `stealth`. In submission mode, the survey maintains an active connection with the server (i.e. a session is created on open, and responses are uploaded). The other mode is **stealth mode**, where no data ever leaves the device throughout the survey-taking process, a bit analogous to incognito mode in a web browser. Default is `submission`.
- `showLandingPage`: A boolean indicating whether a landing page is shown when a survey is launched. The landing page consists of the survey title, a built-in description, and shows a survey logo if the survey has one. Default is `true`.
- `showNavigationMenu`: A boolean indicating whether a navigation menu is shown at the bottom of the survey for flipping pages. *Note that you can always use swipe gestures to flip pages*. Default is `true`.
- `allowJumping`: Whether the user can see a 'Go to Page' button in the navigation menu that allows them to jump to any unlocked page. Default is `false`. See screenshots below for details.
    <img src="Screenshots/gotopage.png" width="240"> <img src="Screenshots/gotopage_menu.png" width="240"> <img src="Screenshots/gotopage_warning.png" width="240">
    As shown, the number entered must be a non-negative integer with 0 being the landing page (or a positive integer if the landing page is disabled) and the `Go` button will only be enabled if the page number points to a valid index. If the provided page is not yet unlocked, the alert on the last image will be shown.
- `useCache`: This framework has the ability to cache partial responses and show them when the server is re-presented. When set to `true`, This functionality is enabled. Default is `true`.
- `theme`: A `Survey.Theme` type variable containing the theme colors the survey should use. A few pre-defined themes are provided:
  - `Survey.Theme.blue` (Default)
  - `Survey.Theme.green`
  - `Survey.Theme.orange`
  - `Survey.Theme.cyan`
  - `Survey.Theme.purple`
  
  - You can built your own theme by using the `Survey.Theme()` constructor, specifying four colors: **dark**, **medium**, **light**, and **highlight**.
