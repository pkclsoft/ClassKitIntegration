//
//  AppDelegate.m
//  ClassKitIntegration
//
//  Created by Peter Easdown on 27/5/18.
//  Copyright © 2018 PKCLsoft. All rights reserved.
//

#import <ClassKit/ClassKit.h>
#import "AppDelegate.h"
#import "LessonDatabase.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    // Ensure that LessonDatabase has been initialized.  This will take care of telling ClassKit all about the activities that this
    // app has available.
    //
    [LessonDatabase sharedInstance];

    // If you want to test the launch of a specific activity within the simulator (where you don't have the SchoolWork app),
    // you can do so by uncommenting the following 4 lines, and altering the path of the activity to suit your needs.
    //
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [[LessonDatabase sharedInstance] appDidReceiveIdentifier:[@"appbundle.skillLevel-0.skillMaximum-150.puzzleCount-5.skill-15" componentsSeparatedByString:@"."]];
//        [[NSNotificationCenter defaultCenter] postNotificationName:SCHOOLWORK_ACTIVITY_LAUNCHED object:nil];
//    });


    return YES;
}

- (BOOL) application:(UIApplication *)application continueUserActivity:(nonnull NSUserActivity *)userActivity restorationHandler:(nonnull void (^)(NSArray * _Nullable))restorationHandler {

    // If ClassKit is available...
    //
    if (@available(iOS 11.3, *)) {
        // If the app has been launched by the SchoolWork app, there will be a deep link with the full identifier path of the
        // activity.
        //
        if (userActivity.isClassKitDeepLink == YES) {
            // Give the identifier to LessonDatabase, and if it is valid, then tell the app that an activity has been launched.
            //
            BOOL isOK =  [[LessonDatabase sharedInstance] appDidReceiveIdentifier:userActivity.contextIdentifierPath];

            if (isOK == YES) {
                [[NSNotificationCenter defaultCenter] postNotificationName:SCHOOLWORK_ACTIVITY_LAUNCHED object:nil];
            }

            return isOK;
        }
    } else {
        // Fallback on earlier versions
    }

    return NO;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.

    // Save the current state of the activity (if any).
    //
    [[LessonDatabase sharedInstance] saveActivityState];
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.

    // Save the current state of the activity (if any).
    //
    [[LessonDatabase sharedInstance] saveActivityState];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.

    // Save the current state of the activity (if any).  You may prefer to end the activity, depending on the app.
    //
    [[LessonDatabase sharedInstance] pauseActivity];
}


@end
