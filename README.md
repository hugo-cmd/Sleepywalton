# SleepyWalton (iOS) – MVP Scaffold

This repo contains a Swift/SwiftUI iOS app scaffold for an NFC-based alarm clock.

## Stack
- Swift 5.10+
- iOS 16+
- SwiftUI, Combine
- UserNotifications
- LocalAuthentication
- CoreNFC (guarded at runtime)
- JSON persistence

## Setup
- Install XcodeGen: `brew install xcodegen`
- cd into `app` and run: `xcodegen generate`
- Open `SleepyWalton.xcodeproj` and build/run on iPhone (sim OK; NFC disabled).

## Structure
- `Sources/Models`: `Alarm`, `RepeatRule`, `NFCTag`, `SleepLog`
- `Sources/Managers`: storage, scheduler, security, NFC
- `Sources/Views`: tabs for Alarms, Stats, NFC, Settings

## Notes
- Replace stubs with production implementations (Core Data, real NFC flows, onboarding).