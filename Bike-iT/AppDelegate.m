//
//  AppDelegate.m
//  Bike-iT
//
//  Created by Jamaal Sedayao on 3/31/16.
//  Copyright © 2016 Jamaal Sedayao. All rights reserved.
//

#import "AppDelegate.h"
#import <INTULocationManager/INTULocationManager.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [GMSServices provideAPIKey:@"AIzaSyDc8NpBDrE8tNI_bDcr5mOWnEldg6pG_wI"];
    
    //[GMSServices provideAPIKey:@"AIzaSyAeSU0Tub_0xQvz2KGf2_VErF1qP69yAoo"];
    
    if ([launchOptions objectForKey:UIApplicationLaunchOptionsLocationKey]) {
        INTULocationManager *locMgr = [INTULocationManager sharedInstance];
        [locMgr subscribeToSignificantLocationChangesWithBlock:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
            // This block will be executed with the details of the significant location change that triggered the background app launch,
            // and will continue to execute for any future significant location change events as well (unless canceled).
        }];
    }
    return YES;
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
