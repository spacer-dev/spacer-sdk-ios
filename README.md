# SpacerSDK

![code](https://img.shields.io/badge/Swift-5.0%2B-orange)
![platforms](https://img.shields.io/badge/Platforms-iOS10.2%2B-green)
![license](https://img.shields.io/github/license/spacer-dev/spacer-sdk-ios)


Provides operations for using the SPACER locker.

For more information, see [docs](https://rogue-flight-1e9.notion.site/SPACER-API-5d3f6b8831be484e94497ac822099270)

## Features

### 1. CB Locker Service

Provides locker operation using BLE

- Scan lockers
- Deposit your luggage in the locker
- Take your luggage out of the locker

### 2. My Locker Service

Provides operation of the locker you are using

- Get a locker in use
- Reserve available lockers
- Cancel the reserved locker
- Share your locker in use

### 3. SPR Locker Service

Provides basic locker information

- Get multiple locker basic information
- Get multiple locker unit basic information  
  
## Requirement

- iOS 10.2+
- Bluetooth Low Energy (BLE) 4.2+

## Usage

### Bluetooth permission settings

「info.plist」→「Open As」 →「source code」　　

Add the following Key and Value           
Please change the wording of value to your company's appropriate wording　　

```
<dict>
    <key>NSBluetoothAlwaysUsageDescription</key>
    <string>Used to detect lockers.</string>
```

### 1. CB Locker Service

```swift
import SpacerSDK

let cbLockerService = SPR.cbLockerService()

// Scan lockers
cbLockerService.scan(
    token: token,
    success: { sprLockers in
    },
    failure: { error in
    }
)
   
// Deposit your luggage in the locker    
cbLockerService.put(
    token: token,
    spacerId: spacerId,
    success: {
    },
    failure: { error in
    }
)

// Take your luggage out of the locker   
cbLockerService.take(
    token: token,
    spacerId: spacerId,
    success: {
    },
    failure: { error in
    }
)
```

### 2. My Locker Service

```swift
import SpacerSDK

let myLockerService = SPR.myLockerService()

// Get a locker in use
myLockerService.get(
    token: token,
    success: { myLockers in
    },
    failure: { error in
    }
)

// Reserve available lockers
myLockerService.reserve(
    token: token,
    spacerId: spacerId,
    success: { myLocker in
    },
    failure: { error in
    }
)

// Cancel the reserved locker
myLockerService.reserveCancel(
    token: token,
    spacerId: spacerId,
    success: {
    },
    failure: { error in
    }
)

// Share your locker in use
myLockerService.shared(
    token: token,
    urlKey: urlKey,
    success: { myLocker in
    },
    failure: { error in
    }
)
```

### 3. SPR Locker Service

```swift
import SpacerSDK

let sprLockerService = SPR.sprLockerService()

// Get multiple locker basic information
sprLockerService.get(
    token: token,
    spacerIds: spacerIds,
    success: { sprLockers in
    },
    failure: { error in
    }
)

// Get multiple locker unit basic information
sprLockerService.get(
    token: token,
    unitIds: unitIds,
    success: { sprUnits in
        AppControl.shared.hideLoading()
        showingAlert = AlertItem.SPRUnitGetSuccess(sprUnits)
    },
    failure: { error in
    }
)

```

## Example

You can check the operation of Spacer SDK in the Example project. see [sample code](https://github.com/spacer-dev/spacer-sdk-ios/tree/master/Example/Sources)    

### How to use

1. Open the `Example` project
2. Set the values of `SPR_API_BASE_URL`,`SPR_API_KEY`, and `SPR_API_USER_ID` in Environment Variables
3. Build and Run on the iphone

- About Environment Variables
    - SPR_API_BASE_URL: https://ex-api.spacer.co.jp
    - SPR_API_KEY: Published by ownerConsocle
    - SPR_API_USER_ID: Published by ownerConsocle

For more information, see [docs](https://rogue-flight-1e9.notion.site/SPACER-API-5d3f6b8831be484e94497ac822099270)

### Precautions

The `Example` project is connected to `ex-api.spacer.co.jp` from the client application to check the operation,
Originally, `SPR_API_KEY` should be set to a white IP so that it can only be accessed from your server.

Temporarily set the `SPR_API_KEY` limit to `any` or `client ip` to check the operation.
After checking the operation, cancel the `any` setting from the viewpoint of security.

## Installation

### CocoaPods

```
pod 'SpacerSDK'
```

### Swift Package Manager

```
dependencies: [
    .package(url: "https://github.com/spacer-dev/spacer-sdk-ios.git", .upToNextMajor(from: "1.0.0"))
]
```

### License
This software is released under the MIT License, see [LICENSE.](https://github.com/spacer-dev/spacer-sdk-ios/blob/master/LICENSE)
