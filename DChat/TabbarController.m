//
//  TabbarController.m
//  DChat
//
//  Created by Donal on 14-4-14.
//  Copyright (c) 2014年 DChat. All rights reserved.
//

#import "TabbarController.h"
#import "CRNavigationController.h"
#import "ConversationTableViewController.h"
#import "OnlineTableViewController.h"

@interface TabbarController ()

@end

@implementation TabbarController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self prepareVC];
}

-(void)prepareVC
{
    ConversationTableViewController *vc1      = [[ConversationTableViewController  alloc] initWithNibName:@"ConversationTableViewController" bundle:nil];
    CRNavigationController *nav1 = [[CRNavigationController alloc] initWithRootViewController:vc1];
    
    OnlineTableViewController *vc2        = [[OnlineTableViewController  alloc] initWithNibName:@"OnlineTableViewController" bundle:nil];
    CRNavigationController *nav2 = [[CRNavigationController alloc] initWithRootViewController:vc2];
    
    self.viewControllers = [[NSArray alloc] initWithObjects:nav1, nav2, nil];
    
    
    nav1.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"会话" image:[UIImage imageNamed:@"tab_friend_unselected"] selectedImage:[UIImage imageNamed:@"tab_friend_selected"]];
    nav2.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"在线" image:[UIImage imageNamed:@"tab_me_unselected"] selectedImage:[UIImage imageNamed:@"tab_me_selected"]];
}

@end
