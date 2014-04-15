//
//  OnlineTableViewController.m
//  DChat
//
//  Created by Donal on 14-4-14.
//  Copyright (c) 2014年 DChat. All rights reserved.
//

#import "OnlineTableViewController.h"
#import "CRNavigationController.h"
#import "ConversationTableViewController.h"

@interface OnlineTableViewController ()
{
    NSMutableArray *users;
}
@end

@implementation OnlineTableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        users = [NSMutableArray array];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(allUser:) name:ChatAllUserNotifaction object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(newUser:) name:ChatNewUserNotifaction object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(leaveUser:) name:ChatLeaveUserNotifaction object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return users.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"user"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"user"];
    }
    cell.textLabel.text = [users objectAtIndex:indexPath.row];
    return cell;
}


#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *user = [users objectAtIndex:indexPath.row];
    [self showChat:user];
}

-(void)showChat:(NSString *)user
{
    [self.tabBarController setSelectedIndex:0];
    CRNavigationController *nav = (CRNavigationController *)[self.tabBarController.viewControllers objectAtIndex:0];
    ConversationTableViewController *vc = (ConversationTableViewController *)[nav.viewControllers objectAtIndex:0];
    [vc chatSomebody:user];
}

#pragma mark user notification
-(void)allUser:(NSNotification *)notifacation
{
    NSArray *usersOnline = (NSArray *)notifacation.object;
    for (NSString *user in usersOnline) {
        if (![user isEqualToString:getUserID]) {
            [users addObject:user];
        }
    }
    [self.tableView reloadData];
}

-(void)newUser:(NSNotification *)notifacation
{
    NSString *user = (NSString *)notifacation.object;
    [self.tableView beginUpdates];
    [users addObject:user];
    NSArray *paths = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:[users count]-1 inSection:0]];
    [self.tableView insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationRight];
    [self.tableView endUpdates];
}

-(void)leaveUser:(NSNotification *)notifacation
{
    NSString *user = (NSString *)notifacation.object;
    if ([users containsObject:user]) {
        NSUInteger index = [users indexOfObject:user];
        [users removeObjectAtIndex:index];
        NSArray *paths = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]];
        [self.tableView deleteRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationLeft];
    }
}
@end
