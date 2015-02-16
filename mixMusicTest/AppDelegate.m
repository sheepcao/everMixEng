//
//  AppDelegate.m
//  mixMusicTest
//
//  Created by Eric Cao on 12/9/14.
//  Copyright (c) 2014 Eric Cao. All rights reserved.
//

#import "AppDelegate.h"
#import "myIAPHelper.h"

#import "Flurry.h"
#import <Crashlytics/Crashlytics.h>
#import <FacebookSDK/FacebookSDK.h>
#import "LARSAdController.h"
#import "TOLAdAdapter.h"
#import "TOLAdAdapteriAds.h"
#import "TOLAdAdapterGoogleAds.h"



@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [myIAPHelper sharedInstance];
    
    [MobClick startWithAppkey:@"54c46ea7fd98c5071d000668" reportPolicy:REALTIME   channelId:nil];
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [MobClick setAppVersion:version];

    //social share




    
    [Flurry setCrashReportingEnabled:YES];
    [Flurry startSession:@"M3THR4J6RYNGWCP4PJWR"];

    
    [Crashlytics startWithAPIKey:@"bc367a445f88cf5a5c02a54966d1432f00fe93f0"];
    
    [[LARSAdController sharedManager] registerAdClass:[TOLAdAdapteriAds class]];
   [[LARSAdController sharedManager] registerAdClass:[TOLAdAdapterGoogleAds class] withPublisherId:ADMOB];


    [NSThread sleepForTimeInterval:1.0];

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
    [FBAppEvents activateApp];

}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    // attempt to extract a token from the url
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
}

@end
