# PasscodeLock
A Swift implementation of passcode lock for iOS with TouchID authentication.

Originally created by [@yankodimitrov](https://github.com/yankodimitrov/SwiftPasscodeLock), hope you're doing well.

<img src="https://raw.githubusercontent.com/yankodimitrov/SwiftPasscodeLock/master/passcode-lock.gif" height="386">

## Installation
PasscodeLock requires Swift 2.0 and Xcode 7

### [CocoaPods](http://cocoapods.org/)

#### Podfile

To integrate PasscodeLock into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'

pod 'PasscodeLock', '~> 1.0.2'
```

Then, run the following command:

```bash
$ pod install
```

### [Carthage](https://github.com/Carthage/Carthage)

Add the following line to your [Cartfile](https://github.com/carthage/carthage)
```swift
github "velikanov/SwiftPasscodeLock"
```
## Usage

- Create an implementation of the `PasscodeRepositoryType` protocol.

```swift
import UIKit
import PasscodeLock

class PasscodeRepository: PasscodeRepositoryType {
    
    var hasPasscode: Bool = true
    var passcode: [String]?
    
    func savePasscode(passcode: [String]) {}
    
    func deletePasscode() {}
    
}
```

- Create an implementation of the `PasscodeLockConfigurationType` protocol and set your preferred passcode lock configuration options. If you set the `maximumInccorectPasscodeAttempts` to a number greather than zero, when user will reach that number of incorrect passcode attempts a notification with name `PasscodeLockIncorrectPasscodeNotification` will be posted on the default `NSNotificationCenter`. 

```swift
import UIKit
import PasscodeLock

class PasscodeLockConfiguration: PasscodeLockConfigurationType {
    let repository: PasscodeRepositoryType
    var passcodeLength = 4 // Specify the required amount of passcode digits
    var isTouchIDAllowed = true // Enable Touch ID
    var shouldRequestTouchIDImmediately = true // Use Touch ID authentication immediately
    var maximumInccorectPasscodeAttempts = 3 // Maximum incorrect passcode attempts
    
    init(repository: PasscodeRepositoryType) {
        self.repository = repository
    }
    
    init() {
        self.repository = PasscodeRepository() // The repository that was created earlier
    }
}
```

- Create an instance of the `PasscodeLockPresenter` class. Next inside your `UIApplicationDelegate` implementation call it to present the passcode in `didFinishLaunchingWithOptions` and `applicationDidEnterBackground` methods. The passcode lock will be presented only if your user has set a passcode.

- Allow your users to set a passcode by presenting the `PasscodeLockViewController` in `.SetPasscode` state:
```swift
let configuration = ... // your implementation of the PasscodeLockConfigurationType protocol

let passcodeViewController = PasscodeLockViewController(state: .SetPasscode, configuration: configuration)

presentViewController(passcodeViewController, animated: true, completion: nil)
```

You can present the `PasscodeLockViewController` in one of the four initial states using the `LockState` enumeration options: `.EnterPasscode`, `.SetPasscode`, `.ChangePasscode`, `.RemovePasscode`.

Also you can set the initial passcode lock state to your own implementation of the `PasscodeLockStateType` protocol.

## Customization

### Custom Design

The PasscodeLock will look for `PasscodeLockView.xib` inside your app bundle and if it can't find it will load its default one, so if you want to have a custom design create a new `xib` with the name `PasscodeLockView` and set its owner to an instance of `PasscodeLockViewController` class.

Keep in mind that when using custom classes that are defined in another module, you'll need to set the Module field to that module's name in the Identity Inspector:

<img src="https://raw.githubusercontent.com/yankodimitrov/SwiftPasscodeLock/master/identity-inspector.png">

Then connect the `view` outlet to the view of your `xib` file and make sure to conenct the remaining `IBOutlet`s and `IBAction`s.

PasscodeLock comes with two view components: `PasscodeSignPlaceholderView` and `PasscodeSignButton` that you can use to create your own custom designs. Both classes are `@IBDesignable` and `@IBInspectable`, so you can see their appearance and change their properties right inside the interface builder:

<img src="https://raw.githubusercontent.com/yankodimitrov/SwiftPasscodeLock/master/passcode-view.png" height="270">

### Localization

Take a look at `PasscodeLock/en.lproj/PasscodeLock.strings` for the localization keys. Here again the PasscodeLock will look for the `PasscodeLock.strings` file inside your app bundle and if it can't find it will use the default localization file.

## Demo App

The demo app comes with a simple implementation of the `PasscodeRepositoryType` protocol that is using the **NSUserDefaults** to store and retrieve the passcode. In your real applications you will probably want to use the **Keychain API**. Keep in mind that the **Keychain** records will not be removed when your user deletes your app.
