//
//  AppDelegate.m
//  DChat
//
//  Created by Donal on 14-4-14.
//  Copyright (c) 2014年 DChat. All rights reserved.
//

#import "AppDelegate.h"
#import "TabbarController.h"
#import "ConversationTableViewController.h"
#import "CRNavigationController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    TabbarController *tab = [[TabbarController alloc] init];
    self.window.rootViewController = tab;
    if (IOS7) {
        [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:62.0f/255.0f green:103.0f/255.0f blue:144.0f/255.0f alpha:0.9f]];
        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
    else {
        [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:62/255.0 green:103/255.0 blue:144/255.0 alpha:0.9]];
    }
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    TabbarController *tab = (TabbarController *)self.window.rootViewController;
    [application setApplicationIconBadgeNumber:[[[[tab.viewControllers objectAtIndex:0] tabBarItem] badgeValue] integerValue]];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    if (isLogin) {
        TabbarController *tab = (TabbarController *)self.window.rootViewController;
        CRNavigationController *nav = tab.viewControllers[0];
        ConversationTableViewController *vc = (ConversationTableViewController *)nav.viewControllers[0];
        [vc registerPomelo];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
