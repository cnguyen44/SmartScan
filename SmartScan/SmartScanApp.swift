//
//  SmartScanApp.swift
//  SmartScan
//
//  Created by Chien Nguyen on 3/22/24.
//

import SwiftUI
//import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    static var orientationLock = UIInterfaceOrientationMask.allButUpsideDown
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // enable and register push notification callback functions
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.alert, .sound, .badge, .provisional]) { granted, error in
            
            if (granted) {
                // Provisional authorization granted.
                print("UN enabled")
            }
            else if let error = error {
                // Handle the error here.
                print("UN error:", error)
            }
        }
        // register remote notifications
        UIApplication.shared.registerForRemoteNotifications()
        
        // Init Firebase
        //FirebaseApp.configure()
        
        return true
    }
    
    // Handle remote notification registration errors
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // The token is not currently available.
        print("Remote notification error: \(error.localizedDescription)")
    }
    
    // Handle remote notification registration success
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Forward the token to your provider, using a custom method.
        let tokenComponents = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let deviceTokenString = tokenComponents.joined()
        
        // The device token is received.
        print("Remote notification devToken: \(deviceTokenString)")
        
        //TODO: send token to server
    }
    
    // Handle remote notification
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        print("didReceiveRemoteNotification:", userInfo)
        //TODO: handle notification
        
        // call completion handler
        completionHandler(.newData)
    }
}

//MARK: Handle push notification when app is running in foreground
extension AppDelegate: UNUserNotificationCenterDelegate{
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("UN willPresent")
        let userInfo = notification.request.content.userInfo
        print("didReceiveRemoteNotification:", userInfo)
        //TODO: handle notification
    }
    //This function call when user tap on notification banner while app run in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        print("UN didReceive")
        let userInfo = response.notification.request.content.userInfo
        print("didReceiveRemoteNotification:", userInfo)
        //TODO: handle notification
    }
}

@main
struct SmartScanApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var appLockVM = AppLockViewModel()
    
    var body: some Scene {
        WindowGroup {
            AppView()
                .environmentObject(appLockVM)
        }
    }
}
