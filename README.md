#  Notification Pusher
 [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Installation

### Carthage
```ruby
github "godzapp/NotificationPusher" "1.0"
```

## Basic Usage

1. Set a notification identifier
2. Set an interval
3. Set a notification title
4. Set a body to the notification
5. Register the notification
```swift
NotificationPusher.shared.set(identifier: String)
NotificationPusher.shared.set(interval: TimeInterval)
NotificationPusher.shared.set(title: String)
NotificationPusher.shared.set(body: String)
NotificationPusher.shared.register(handler: (Bool, Error?) -> Void)
```

6. Repeat for every other notification !

## Existing methods

### Notification Configuration
> The notification will be send instantly
```swift
NotificationPusher.shared.instants = false
```
> The notification will be repeated
```swift
NotificationPusher.shared.repeats = false
```

> Set a specific sound for the notification
``` swift
NotificationPusher.set(sound: Sound)
```

> Set a subtitle to the notificiation
```swift
NotificationPusher.set(subtitle: String)
```

### Static Method
```swift
NotificationPusher.find(id: String, handler: (UNNotificationContent?) -> Void)
NotificationPusher.cancel(id: String)
NotificationPusher.cancelAll()
NotificationPusher.pendingCount(withIdentifier: String = nil, handler: ((Int) -> Void))
NotificationPusher.deliveredCount(withIdentifier: String = nil, handler: ((Int) -> Void))
NotificationPusher.clean()
```

# Author

DOUPAGNE Yoann [@godzapp](https://github.com/godzapp)
