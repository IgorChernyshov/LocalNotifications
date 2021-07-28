//
//  ViewController.swift
//  LocalNotifications
//
//  Created by Igor Chernyshov on 27.07.2021.
//

import UIKit
import UserNotifications

final class ViewController: UIViewController {

	// MARK: - Properties
	private lazy var center: UNUserNotificationCenter = {
		let center = UNUserNotificationCenter.current()
		center.delegate = self
		return center
	}()

	// MARK: - Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()
		navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Register", style: .plain, target: self, action: #selector(registerLocal))
		navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Schedule", style: .plain, target: self, action: #selector(scheduleLocal))
	}

	// MARK: - Button Actions
	@objc func registerLocal() {
		center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
			if granted {
				print("Yay!")
			} else {
				print("D'oh")
			}
		}
	}

	@objc func scheduleLocal(isSnooze: Bool) {
		registerCategories()

		let content = UNMutableNotificationContent()
		content.title = "Late wake up call"
		content.body = "The early bird catches the worm, but the second mouse gets the cheese."
		content.categoryIdentifier = "alarm"
		content.userInfo = ["customData": "fizzbuzz"]
		content.sound = UNNotificationSound.default

		var dateComponents = DateComponents()
		dateComponents.hour = 10
		dateComponents.minute = 30
		let trigger = UNTimeIntervalNotificationTrigger(timeInterval: isSnooze ? 3600 : 5, repeats: false)
//		let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

		let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
		center.add(request)
	}

	// MARK: - Notification Actions
	private func registerCategories() {
		let show = UNNotificationAction(identifier: "show", title: "Tell me more…", options: .foreground)
		let snooze = UNNotificationAction(identifier: "snooze", title: "Remind me later", options: .foreground)
		let category = UNNotificationCategory(identifier: "alarm", actions: [show, snooze], intentIdentifiers: [])

		center.setNotificationCategories([category])
	}
}

// MARK: - UNUserNotificationCenterDelegate
extension ViewController: UNUserNotificationCenterDelegate {

	func userNotificationCenter(_ center: UNUserNotificationCenter,
								didReceive response: UNNotificationResponse,
								withCompletionHandler completionHandler: @escaping () -> Void) {
		defer { completionHandler() }
		let userInfo = response.notification.request.content.userInfo

		guard let customData = userInfo["customData"] as? String else { return }

		print("Custom data received: \(customData)")
		switch response.actionIdentifier {
		case UNNotificationDefaultActionIdentifier:
			let alertController = UIAlertController(title: "App started", message: "You've just opened the app", preferredStyle: .alert)
			alertController.addAction(UIAlertAction(title: "OK", style: .default))
			present(alertController, animated: UIView.areAnimationsEnabled)
		case "show":
			let alertController = UIAlertController(title: "App started", message: "You've tapped Show more info", preferredStyle: .alert)
			alertController.addAction(UIAlertAction(title: "OK", style: .default))
			present(alertController, animated: UIView.areAnimationsEnabled)
		case "snooze":
			scheduleLocal(isSnooze: true)
		default:
			break
		}
	}
}
