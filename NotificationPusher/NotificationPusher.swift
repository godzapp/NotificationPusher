//
//  NotificationPusher.swift
//  NotificationPusher
//
//  Created by godZmac on 02/01/2020.
//  Copyright © 2020 dyoann. All rights reserved.
//

import NotificationCenter

public class NotificationPusher {
  private var identifier: String
  private var notification: UNMutableNotificationContent
  
  public static var shared: NotificationPusher = NotificationPusher()
  
  // By default a notification will not be repeated
  private var repeated: Bool = false
  
  // By default a notification will not be send instantly
  private var instantly: Bool = false
  
  // User defined time interval
  private var interval: Double
  
  // Allow the notification to be repeated
  public var repeats: Bool {
    get { return repeated }
    set(bool) { repeated = bool }
  }
  
  // Allow the notification to be send immediately
  public var instants: Bool {
    get { return instantly }
    set(bool) { instantly = bool }
  }
  
  // Flag the notification as registered when done
  private var registered: Bool = false
  
  init() {
    self.identifier = ""
    self.interval = 0.0
    
    // Initialize my local notification
    notification = UNMutableNotificationContent()
    notification.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: Sound.Default.rawValue))
  }
  
  // MARK: Reset Content
  private func reset() {
    // Replace the existing notification content
    notification = UNMutableNotificationContent()
    notification.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: Sound.Default.rawValue))
    
    // By default the notification will not be repeated
    repeated = false
  }
  
  // MARK: Register Notification
  /// This method is called to register the notification locally when the configuration is done.
  /// When this method is called, the notification is not mutable anymore
  public func register(handler: @escaping ((Bool, Error?) -> Void)) {
    
    // Assert that the user authorize notification
    UNUserNotificationCenter.current().getNotificationSettings {[unowned self] settings in
      guard settings.authorizationStatus == .authorized else {
        handler(false, NPError.WrongAuthorization)
        return
      }
      
      // Assert that the notification wasn't already registered
      guard !self.registered else {
        handler(false, NPError.AlreadyRegister)
        return
      }
      
      var trigger: UNTimeIntervalNotificationTrigger?
      if !self.instantly {
        trigger = UNTimeIntervalNotificationTrigger(timeInterval: self.interval, repeats: self.repeated)
        // Assert that the trigger interval is higher than 0
        guard trigger != nil, self.interval > 0 else {
          handler(false, NPError.IncorrectInterval(Int(self.interval)))
          return
        }
      }
      
      // Assert that the title as been defined
      guard self.notification.title != "" else {
        handler(false, NPError.MissingTitle)
        return
      }
      
      // Create the notification request
      let request = UNNotificationRequest(
        identifier: self.identifier,
        content: self.notification,
        trigger: self.instantly ? nil : trigger ?? nil
      )
      
      // Attempt to register the notification into the center
      UNUserNotificationCenter.current().add(request) { e in
        if let error = e {
          handler(false, error)
        } else {
          handler(true, nil)
        }
        
        // Once the notification as been registered, reset the content
        self.reset()
      }
    }
  }
  
  // MARK: Retreive a Notification
  public static func find(id: String, handler: @escaping ((UNNotificationContent?) -> Void)) {
    UNUserNotificationCenter.current().getPendingNotificationRequests { request in
      for notification in request {
        guard let dict = notification.content.userInfo as? [String: Any] else {
          continue
        }
        
        if let notifId = dict["id"] as? String {
          if notifId.lowercased() == id.lowercased() {
            handler(notification.content)
          }
        }
      }
      
      // Notification wasn't found
      handler(nil)
    }
  }
  
  // MARK: Cancel a Notification
  public static func cancel(id: String) {
    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
    debugPrint("The notification with id '\(id)' as been cancelled.")
  }
  
  // MARK: Cancel all Notification
  public static func cancelAll() {
    UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    debugPrint("All pending notification have been cleared.")
  }
  
  // MARK: Count Pending Notification
  public static func pendingCount(withIdentifier: String? = nil, handler: @escaping ((Int) -> Void)) {
    UNUserNotificationCenter.current().getPendingNotificationRequests { pending in
      if let identifier = withIdentifier {
        var count: Int = 0
        for notification in pending {
          count += notification.identifier == identifier ? 1 : 0
        }
        
        // Return the total of pending notification with specified thread identifier
        handler(count)
      } else {
        // Return the total of pending notification
        handler(pending.count)
      }
    }
  }
  
  // MARK: Count Delivered Notification
  public static func deliveredCount(withIdentifier: String? = nil, handler: @escaping ((Int) -> Void)) {
    UNUserNotificationCenter.current().getDeliveredNotifications { delivered in
      if let identifier = withIdentifier {
        var count: Int = 0
        for notification in delivered {
          count += notification.request.identifier == identifier ? 1 : 0
        }
        
        // Return the total of delivered notification with specified thread identifier
        handler(count)
      } else {
        // Return the total of delivered settings
        handler(delivered.count)
      }
    }
  }
  
  // MARK: Clean all Delivered
  /// This method will help you clean delivered notification, you should use it to avoid flooding the notification center
  public static func clean() {
    UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    debugPrint("All delivered notification have been cleared.")
  }
  
  // MARK: Setter
  public func set(sound: Sound) {
    notification.sound = UNNotificationSound(named: UNNotificationSoundName(sound.rawValue))
  }
  
  public func set(title: String) {
    notification.title = title
  }
  
  public func set(body: String) {
    notification.body = body
  }
  
  public func set(subtitle: String) {
    notification.subtitle = subtitle
  }
  
  public func set(identifier: String) {
    self.identifier = identifier
  }
  
  public func set(interval: TimeInterval) {
    self.interval = interval
  }
  
}

// MARK: Sound Enum
public enum Sound: String {
  case Default              = "1020"
  case MailReceived         = "new-mail.caf"
  case MailSent             = "mail-sent.caf"
  case VoicemailReceived    = "Voicemail.caf"
  case SMSReceived          = "ReceivedMessage.caf"
  case SMSSent              = "SentMessage.caf"
  case CalendarAlert        = "alarm.caf"
  case LowPower             = "low_power.caf"
}

// MARK: Error Enum
private enum NPError: Error {
  case AlreadyRegister
  case IncorrectInterval(Int)
  case MissingTitle
  case WrongAuthorization
}

extension NPError: LocalizedError {
  var errorDescription: String? {
    switch self {
      case .AlreadyRegister:
      return "This notification as already been registered!"
      
      case .IncorrectInterval(let interval):
      return "Your time interval is incorrect. The value can't be 0 or under (given interval: \(interval))"
      
      case .MissingTitle:
      return "You can't register a notification without specifying a title..."
      
      case .WrongAuthorization:
      return "You don't have the requested authorisation..."
    }
  }
}
