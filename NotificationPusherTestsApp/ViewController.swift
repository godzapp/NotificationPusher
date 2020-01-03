//
//  ViewController.swift
//  NotificationPusherTest
//
//  Created by godZmac on 02/01/2020.
//  Copyright © 2020 dyoann. All rights reserved.
//

import UIKit
import NotificationPusher

class ViewController: UIViewController {
  
  // UIButton
  private var addButton: UIButton!
  private var cancelButton: UIButton!
  
  // UILabel
  private var countPendingLabel: UILabel!
  private var countDeliveredLabel: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    
    addButton = UIButton(frame: CGRect(x: 100, y: 200, width: 200, height: 30))
    addButton.setTitle("Add Notification", for: .normal)
    addButton.backgroundColor = .blue
    addButton.addTarget(self, action: #selector(registerNotification), for: .touchDown)
    view.addSubview(addButton)

    countPendingLabel = UILabel(frame: CGRect(x: 100, y: 250, width: 200, height: 30))
    countPendingLabel.text = "Counting..."
    view.addSubview(countPendingLabel)
    
    countDeliveredLabel = UILabel(frame: CGRect(x: 100, y: 300, width: 200, height: 30))
    countDeliveredLabel.text = "Counting..."
    view.addSubview(countDeliveredLabel)
    
    // Update the notification counting
    updateNotificationCount()
  }
  
  @objc private func registerNotification() {
    toggleSchedule()
    // Program a notification with random interval from 1 to 5 minute
    let random = Double.random(in: 60.0...360.0)
    
    // Configure the notification
    NotificationPusher.shared.repeats = false
    NotificationPusher.shared.instants = false
    NotificationPusher.shared.set(identifier: "random-notification-\(random)")
    NotificationPusher.shared.set(interval: random)
    NotificationPusher.shared.set(title: "This is a randomize notification...")
    NotificationPusher.shared.set(body: "Which should appear in \(random) second on my screen !")
    NotificationPusher.shared.set(sound: .CalendarAlert)
    
    // Register the notification
    // When a notification is register she will be reset later
    NotificationPusher.shared.register {[unowned self] success, err in
      self.toggleSchedule()
      guard success == true else {
        debugPrint("Something wen't wrong ! Wasn't able to register notification...")
        debugPrint("Reason: \(err!.localizedDescription)")
        return
      }
      
      debugPrint("The notification was successfuly registered with \(round(random)) second interval !")
      // Update my counter to keep track...
      self.updateNotificationCount()
    }
  }
  
  private func toggleSchedule() {
    DispatchQueue.main.async {
      self.addButton.isEnabled = !self.addButton.isEnabled
    }
  }

  private func updateNotificationCount() {
    debugPrint("Updating notification count...")
    // Update pending count
    NotificationPusher.pendingCount { count in
      DispatchQueue.main.async {[weak self] in
        self?.countPendingLabel.text = "Pending Notification: \(count)"
      }
    }
    
    // Update delivered count
    NotificationPusher.deliveredCount { count in
      DispatchQueue.main.async {[weak self] in
        self?.countDeliveredLabel.text = "Delivered Notification: \(count)"
      }
    }
    
    UNUserNotificationCenter.current().getPendingNotificationRequests { (request) in
      debugPrint("\(request.count)")
    }
  }

}

