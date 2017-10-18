//
//  AppDelegate.swift
//  WeatherApp
//
//  Created by Jorge Orjuela on 10/18/17.
//

import CoreData.NSPersistentContainer
import GoogleMaps
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    private let persistentContainer: NSPersistentContainer = {
        let persistentContainer = NSPersistentContainer(name: "WeatherApp")
        persistentContainer.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        persistentContainer.loadPersistentStores { _, error in
            guard let error = error else { return }

            fatalError("Error loading the persistent store error: \(error)")
        }

        print(NSPersistentContainer.defaultDirectoryURL())
        return persistentContainer
    }()

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        GMSServices.provideAPIKey("AIzaSyAABSS-NR9cvG2q2a-yZ3Z_zUeK4PH4Nq8")

        let rootViewController = UIStoryboard.init(storyBoardName: .main).instantiateInitialViewController() as? UINavigationController
        (rootViewController?.viewControllers.first as? PersistentContainerSettable)?.persistentContainer = persistentContainer
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = rootViewController
        window?.makeKeyAndVisible()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
    }
}
