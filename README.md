# Deliver iOS SDK

`DeliverSDK`

![](https://deliverapp.io/wp-content/uploads/2024/10/logo-deliver-1.png)

## Features

- Logger
- Issue reporting
- Live application log
- Live network

## Requirements

- iOS 14.0+ /
- Swift 5.8+

## Installation

`DeliverSDK` is distributed using [Swift Package Manager (SPM)](https://swift.org/package-manager/). To integrate it into your project, follow these steps:

### Adding via Xcode

1. Open your project in Xcode.
2. Go to **File > Add Packages...**.
3. In the search bar, enter the repository URL for `DeliverSDK`:
   ```
   https://github.com/DeliverApp/Deliver-iOS-SDK.git
   ```
4. Choose the `0.0.1-beta` version, then click **Add Package**.

## Usage

To get started with `DeliverSDK`, import it in your `AppDelegate`:

```swift
import DeliverSDK
```

Then setup Deliver with your `appKey`.
`appKey` can be found in https://store.deliverapp.io/settings/apps

```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    /// Start Deliver
    Deliver.setup(key: "80fbe1a5-3159-4d62-9f55-507155d05b80")
....
}
```

## Notes

1. This version of DeliverSDK automatically starts logging and observing network traffic. Future releases will include options for developers to customize these features.
2. The next release will be deployed as a dynamic framework to simplify production deployment.

---

Happy coding! 🚀
