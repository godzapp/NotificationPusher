#  Notification Pusher

### Installation

```
pod "NotificationPusher"
```

### Usage

1. Set a title to the notification
```
NotificationPusher.shared.set(title: String)
```

2. Set a body to the notification
```
NotificationPusher.shared.set(body: String)
```

3. Register the notification
  - When the notification as been register the object reset itself and can be reuse
```
NotificationPusher.shared.register((Bool, Error?) -> Void)
```

4. Repeat for every other notification !

### Existing methods


