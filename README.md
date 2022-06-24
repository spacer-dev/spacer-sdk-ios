# SpacerSDK

![code](https://img.shields.io/badge/Swift-5.0%2B-orange)
![platforms](https://img.shields.io/badge/IOS-10.2%2B-orange)
![bluetooth](https://img.shields.io/badge/bluetooth-4.2%2B-brightgreen)
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
- Reserve an available locker
- Cancel the reserved locker
- Share your locker in use

### 3. SPR Locker Service

Provides basic locker information

- Get multiple locker basic information
- Get multiple locker unit basic information

### 4. Location Service

Provides basic location information

- Get multiple unit location basic information
  
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
    <key>NSBluetoothPeripheralUsageDescription</key>
    <string>Bluetooth is used to communicate with BLE devices.</string>
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

// Reserve an available locker
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
myLockerService.shareUrlKey(
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
    },
    failure: { error in
    }
)

```

### 4. Location Service

```swift
import SpacerSDK

let locationService = SPR.locationService()

// Get multiple unit location basic information
locationService.get(
    token: token,
    locationId: locationId,
    success: { sprLocation in
    },
    failure: { error in
    }
)
```

## Example

You can check the operation of Spacer SDK in the Example project. see [sample code](https://github.com/spacer-dev/spacer-sdk-ios/tree/master/Example/Sources)    

### How to use

1. Open the `Example` project
2. Set the values of `SDK_TOKEN` in Environment Variables
3. Build and Run on the iphone

### About `SDK_TOKEN`

Originally, the token issued by SPACER obtained from your server is set for testing.

How to get `sdk.token`, see [docs](https://rogue-flight-1e9.notion.site/SPACER-API-5d3f6b8831be484e94497ac822099270)


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
