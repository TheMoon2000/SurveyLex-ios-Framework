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

Once a component is completed for the first time, the next component will altomatically be focused, with the exception of checkbox questions (because we don't know when the user is done with the question). When the last question is done and all required questions are complete, the page is automatically flipped. If a user comes back to a question that they have already modified, the survey will not jump to the next question.

<img src="Screenshots/overview.gif" width="240">

(**Note**: The bottom navigation menu seems pixelated in this GIF because it's built out of a `UIVisualEffectView`).

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

    <img src="Screenshots/collapse.gif" width="240">
    <img src="Screenshots/no_collapse.png" width="240">

- `visibilityDifferentiation`: Whether the current item on a page of a survey has higher opacity than other elements. Default is `true`. <br>

    <img src="Screenshots/autofocus.png" width="240">
  
- `mode`: A `Survey.Mode` property that is either `submission` or `stealth`. In submission mode, the survey maintains an active connection with the server (i.e. a session is created on open, and responses are uploaded). The other mode is **stealth mode**, where no data ever leaves the device throughout the survey-taking process, a bit analogous to incognito mode in a web browser (see image below). Default is `submission`.

    <img src="Screenshots/stealth_mode.png" width="240">
    
    In stealth mode, all the features work the same, except the framework will not attempt to submit anything. This mode is good for testing the behavior or display of a survey without “spamming” responses to the server and messing up with the existing, probably authentic, submission records.

- `showLandingPage`: A boolean indicating whether a landing page is shown when a survey is launched. The landing page consists of the survey title, a built-in description, and shows a survey logo if the survey has one. An example of a landing page without a logo is shown in the GIF above. Below is an example of a landing page for a survey with a logo (displayed using **aspect fit**). Default is `true`.

    <img src="Screenshots/landing_page.png" width="240">

- `showNavigationMenu`: A boolean indicating whether a navigation menu is shown at the bottom of the survey for flipping pages (see the bottom of most screenshot). *Note that you can always use swipe gestures to flip pages*. Default is `true`.
- `allowJumping`: Whether the user can see a 'Go to Page' button in the navigation menu that allows them to jump to any unlocked page. Default is `false`. See screenshots below for details.
    
    <img src="Screenshots/gotopage.png" width="240">
    <img src="Screenshots/gotopage_menu.png" width="240">
    <img src="Screenshots/gotopage_warning.png" width="240">
    
    As shown, the number entered must be a non-negative integer with 0 being the landing page (or a positive integer if the landing page is disabled) and the `Go` button will only be enabled if the page number points to a valid index. If the provided page number is in bounds but the page is not yet unlocked, the alert on the last image is shown.
- `useCache`: This framework has the ability to cache partial responses and show them when the servey is re-presented. When set to `true`, This functionality is enabled. Default is `true`.
- `theme`: A `Survey.Theme` type variable containing the theme colors the survey should use. A few pre-defined themes are provided:
  - `Survey.Theme.blue` (Default)
  - `Survey.Theme.green`
  
    <img src="Screenshots/green_1.png" width="240">
    <img src="Screenshots/green_2.png" width="240">
  
  - `Survey.Theme.orange`
  
    <img src="Screenshots/orange_1.png" width="240">
    <img src="Screenshots/orange_2.png" width="240">
  
  - `Survey.Theme.cyan`
  
    <img src="Screenshots/cyan_1.png" width="240">
    <img src="Screenshots/cyan_2.png" width="240">
  
  - `Survey.Theme.purple`
  
    <img src="Screenshots/purple_1.png" width="240">
    <img src="Screenshots/purple_2.png" width="240">
  
  - You can built your own theme by using the `Survey.Theme()` constructor, specifying four colors: **dark**, **medium**, **light**, and **highlight**.

### Audio Questions
A unique feature in SurveyLex surveys is that you can submit audio responses. The interface for audio questions can be seen in many screenshots. When you first arrive at the screen, you will have the option to record (some audio questions start automatically depending on how it was configured). Once done, you will be able to playback the recording (same button), or clear the previous recording. For required audio questions, you must have a valid recording before moving to the next page.
