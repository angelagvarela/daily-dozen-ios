//
//  MainViewController.swift
//  DailyDozen
//
//  Created by marc on 2019.12.14.
//  Copyright © 2019 Nutritionfacts.org. All rights reserved.
//

import UIKit
import UserNotifications

class MainViewController: UIViewController {
        
    let mainTabBarController = UITabBarController()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Global App Settings
        setupUnitsType()
        setupReminders()
        setupTabNaviation()
    }
    
    private func setupUnitsType() {
        // ----- Settings: Units Type -----
        if UserDefaults.standard.object(forKey: SettingsKeys.unitsTypePref) == nil {
            // :NYI:ToBeLocalized: set initial default based on device language
            UserDefaults.standard.set(UnitsType.imperial.rawValue, forKey: SettingsKeys.unitsTypePref)
        }
    }
    
    private func setupReminders() {
        // ----- Settings: Reminders -----
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()

        if UserDefaults.standard.object(forKey: SettingsKeys.reminderCanNotify) == nil {
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                UserDefaults.standard.set(settings.authorizationStatus == .authorized, forKey: SettingsKeys.reminderCanNotify)
            }
        }

        if UserDefaults.standard.object(forKey: SettingsKeys.reminderHourPref) == nil {
            UserDefaults.standard.set(8, forKey: SettingsKeys.reminderHourPref)
        }

        if UserDefaults.standard.object(forKey: SettingsKeys.reminderMinutePref) == nil {
            UserDefaults.standard.set(0, forKey: SettingsKeys.reminderMinutePref)
        }

        if UserDefaults.standard.object(forKey: SettingsKeys.reminderSoundPref) == nil {
            UserDefaults.standard.set(true, forKey: SettingsKeys.reminderSoundPref)
        }

        guard UserDefaults.standard.bool(forKey: SettingsKeys.reminderCanNotify) else { return }

        let content = UNMutableNotificationContent()
        content.title = "DailyDozen app." // :NYI:ToBeLocalized:
        content.subtitle = "Do you remember about the app?" // :NYI:ToBeLocalized:
        content.body = "Use this app on a daily basis!" // :NYI:ToBeLocalized:
        content.badge = 1

        if UserDefaults.standard.bool(forKey: SettingsKeys.reminderSoundPref) {
            content.sound = UNNotificationSound.default
        }

        var dateComponents = DateComponents()
        dateComponents.hour = UserDefaults.standard.integer(forKey: SettingsKeys.reminderHourPref)
        dateComponents.minute = UserDefaults.standard.integer(forKey: SettingsKeys.reminderMinutePref)

        let dateTrigget = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(identifier: "request", content: content, trigger: dateTrigget)

        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print(error.localizedDescription)
            }
        }

    }
    
    private func setupTabNaviation() {
        // ----- Tab Navigation Setup -----
        if UserDefaults.standard.bool(forKey: "hasSeenFirstLaunch") == false {
            UserDefaults.standard.set(false, forKey: "hasSeenFirstLaunch") // :!!!:DEBUG: default should be true
            UserDefaults.standard.set(true, forKey: "showTweaksTab")
        }
        
        print("\n## viewDidLoad ##")
        print("hasSeenFirstLaunch \(UserDefaults.standard.bool(forKey: "hasSeenFirstLaunch"))")
        print("showTweaksTab \(UserDefaults.standard.bool(forKey: "showTweaksTab"))")

        mainTabBarController.tabBar.tintColor = UIColor.black
        updateTabBarController()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateTabBarController(notification:)),
            name: NSNotification.Name(rawValue: "NoticeUpdatedShowTweaksTab"),
            object: nil)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    // MARK: - Navigation

    @objc
    func updateTabBarController(notification: Notification) {
        updateTabBarController()
    }

    func updateTabBarController() {
        print("\n## updateTabBarController ##")
        print("hasSeenFirstLaunch \(UserDefaults.standard.bool(forKey: "hasSeenFirstLaunch"))")
        print("showTweaksTab \(UserDefaults.standard.bool(forKey: "showTweaksTab"))")

        var controllerArray = [UIViewController]()
        
        // Daily Dozen Tab
        let tabDailyDozenStoryboard = UIStoryboard(name: "ServingsPager", bundle: nil) // :!!!: hard coded storyboard
        guard
            let tabDailyDozenViewController = tabDailyDozenStoryboard
                .instantiateInitialViewController() as? ServingsPagerViewController
            else { fatalError("Did not instantiate `ServingsPagerViewController`") }

        tabDailyDozenViewController.title = "Daily Dozen"
        tabDailyDozenViewController.view.backgroundColor =  UIColor.red // :!!!:DEBUG: should be a different color
        tabDailyDozenViewController.tabBarItem = UITabBarItem.init(
            title: "Daily Dozen",
            image: UIImage(named: "ic_tabapp_dailydozen"),
            tag: 0
        )
        controllerArray.append(tabDailyDozenViewController)

        // Tweaks Tab
        if UserDefaults.standard.bool(forKey: "showTweaksTab") {
            let tab2ndStoryboard = UIStoryboard(name: "TweaksPager", bundle: nil)  // :!!!: hard coded storyboard
            guard
                let tabTweaksViewController = tab2ndStoryboard
                    .instantiateInitialViewController() as? TweaksPagerViewController
                else { fatalError("Did not instantiate `TweaksPagerViewController`") }

            tabTweaksViewController.title = "21 Tweaks"
            tabTweaksViewController.view.backgroundColor =  UIColor.green
            tabTweaksViewController.tabBarItem = UITabBarItem.init(
                title: "21 Tweaks",
                image: UIImage(named: "ic_tabapp_21tweaks"),
                tag: 1
            )
            controllerArray.append(tabTweaksViewController)
        }
        
        // Info Tab
        let tabInfoStoryboard = UIStoryboard(name: "Menu", bundle: nil) // :!!!: hard coded storyboard
        guard
            let tabInfoViewController = tabInfoStoryboard
                .instantiateInitialViewController() as? MenuTableViewController
            else { fatalError("Did not instantiate Info `MenuTableViewController`") }

        tabInfoViewController.title = "Info"
        tabInfoViewController.view.backgroundColor =  UIColor.blue // :!!!:DEBUG: should be a different color
        tabInfoViewController.tabBarItem = UITabBarItem.init(
            title: "Info",
            image: UIImage(named: "ic_tabapp_info"),
            tag: 0
        )
        controllerArray.append(tabInfoViewController)

        // Settings Tab
        let tabSettingsStoryboard = UIStoryboard(name: "Settings", bundle: nil) // :!!!: hard coded storyboard
        guard
            let tabSettingsViewController = tabSettingsStoryboard
                .instantiateInitialViewController() as? SettingsViewController
            else { fatalError("Did not instantiate `SettingsViewController`") }

        tabSettingsViewController.title = "Settings"
        tabSettingsViewController.view.backgroundColor =  UIColor.magenta // :!!!:DEBUG: should be a different color
        tabSettingsViewController.tabBarItem = UITabBarItem.init(
            title: "Settings",
            image: UIImage(named: "ic_tabapp_settings"),
            tag: 0
        )
        controllerArray.append(tabSettingsViewController)

        // Main Nav Bar Controller
        var navControllerArray = [UINavigationController]()
        for vc in controllerArray {
            let navController = UINavigationController.init(rootViewController: vc)
            navControllerArray.append(navController)
        }
                
        mainTabBarController.viewControllers = navControllerArray
        self.view.addSubview(mainTabBarController.view)
    }

    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
}

extension MainViewController: UNUserNotificationCenterDelegate {

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

        completionHandler([.alert, .sound])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void) {

        completionHandler()
    }
}
