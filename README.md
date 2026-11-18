# Learning Journey

An iOS app that helps you build a daily learning habit. Pick something to learn, choose how long you want to stick with it, and log a day whenever you study. Miss a day and you can use a Freeze to keep your streak alive.

Built with SwiftUI.


## Features

- **Set a goal:** what you want to learn and for how long (a week, a month, or a year).
- **Log as Learned:** one tap per day. The button unlocks again at the start of the next day.
- **Freeze for a day:** keeps your streak alive on a day you can't study, without adding to it. Changed your mind? Undo it within 24 hours.
- **Calendar:** every month from the start of your goal, with the same colors.
- **Goal result:** a "Well done!" screen when you finish, or a prompt to start again if you don't.
- **Edit your goal:** changing a running goal asks for confirmation, because the streak starts over.

## How it works

- Every Learned day adds one to your streak (one per calendar day).
- A Freeze keeps the streak alive but does not add to it. It stays active for 24 hours, during which logging is blocked.
- If more than **32 hours** pass without a log or a Freeze, the streak resets and the goal is marked as failed.
- The goal is completed when the days covered (Learned or Freezed) reach the number needed. Completed wins over failed.
- Updating the goal restarts the streak and the Freezes. Only logs made after the goal started are counted.

## Project structure


Model/        Goal, DayLog, LearningDuration, GoalProgress, StreakCalculator
ViewModel/    ActivityViewModel (state, actions, persistence)
View/
  Calendar/   LearningCalendarView, WeekStripView
  Components/ Theme, StatCardView and shared styles
  GoalPage/   Goal form, duration picker, goal editor
  LogPage/    ActivityView, LogButton, FreezeButton, GoalResultView
  Onboardingview, ContentView

  
The streak and goal logic lives in plain functions in `Model/` that take the current time as an input, so it can be tested without waiting for real days to pass.

## Requirements

- Xcode 26 or later (the Liquid Glass APIs need the iOS 26 SDK)
- iOS device or simulator

## Run it

1. Clone the repository.
2. Open the `.xcodeproj` in Xcode.
3. Pick a simulator or a connected device and press `Cmd + R`.


## Data

Everything is stored locally on the device with `UserDefaults`. There is no account and no network access.

## Author
Rifal Aloufi
