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
#import "NSString+Wrapper.h"

@interface OnlineTableViewController () <UISearchDisplayDelegate, UISearchBarDelegate>
{
    NSMutableArray *users;
    NSMutableArray *searchResults;
}
@end

@implementation OnlineTableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        users = [NSMutableArray array];
        searchResults = [NSMutableArray array];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(allUser:) name:ChatAllUserNotifaction object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(newUser:) name:ChatNewUserNotifaction object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(leaveUser:) name:ChatLeaveUserNotifaction object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initUI];
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView setTableFooterView:v];
}

-(void)initUI
{
    self.title = @"在线";
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    
    titleView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    
    titleView.autoresizesSubviews = YES;
    
    titleView.backgroundColor = [UIColor clearColor];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    
    titleLabel.tag = 1;
    
    titleLabel.backgroundColor = [UIColor clearColor];
    
    titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:16];
    
    titleLabel.textAlignment = NSTextAlignmentCenter;
    
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    titleLabel.textColor = [UIColor whiteColor];
    
    titleLabel.lineBreakMode = NSLineBreakByClipping;
    
    titleLabel.textAlignment = NSTextAlignmentCenter;
    
    titleLabel.autoresizingMask = titleView.autoresizingMask;
    
    
    
    CGRect leftViewbounds = self.navigationItem.leftBarButtonItem.customView.bounds;
    
    CGRect rightViewbounds = self.navigationItem.rightBarButtonItem.customView.bounds;
    
    
    
    CGRect frame;
    
    CGFloat maxWidth = leftViewbounds.size.width > rightViewbounds.size.width ? leftViewbounds.size.width : rightViewbounds.size.width;
    
    maxWidth += 15;
    
    
    
    frame = titleLabel.frame;
    
    frame.size.width = 320 - maxWidth * 2;
    frame.origin.x = 5;
    titleLabel.frame = frame;
    
    
    
    frame = titleView.frame;
    
    frame.size.width = 320 - maxWidth * 2;
    
    titleView.frame = frame;
    
    titleLabel.text = @"在线";
    
    [titleView addSubview:titleLabel];
    
    self.navigationItem.titleView = titleView;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        return [searchResults count];
    }
	else
	{
        return [users count];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"user"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"user"];
    }
    NSString *name ;
    if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        name = [searchResults objectAtIndex:indexPath.row];
    }
	else
	{
        name = [users objectAtIndex:indexPath.row];
    }
    cell.textLabel.text = name;
    if (users.count-1 == indexPath.row) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    else {
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 15, 0, 0)];
    }
    return cell;
}


#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *name ;
    if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        name = [searchResults objectAtIndex:indexPath.row];
    }
	else
	{
        name = [users objectAtIndex:indexPath.row];
    }
    [self showChat:name];
}

-(void)showChat:(NSString *)user
{
    [self.tabBarController setSelectedIndex:0];
    CRNavigationController *nav = (CRNavigationController *)[self.tabBarController.viewControllers objectAtIndex:0];
    ConversationTableViewController *vc = (ConversationTableViewController *)[nav.viewControllers objectAtIndex:0];
    [vc chatSomebody:user];
}

#pragma mark   搜索
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    NSArray *temp = [users mutableCopy];
    [searchResults removeAllObjects];
    for (NSString *user in temp) {
        if ([user contains:searchString]) {
            [searchResults addObject:user];
        }
    }
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    NSString *searchString = [self.searchDisplayController.searchBar text];
    NSArray *temp = [users mutableCopy];
    [searchResults removeAllObjects];
    for (NSString *user in temp) {
        if ([user contains:searchString]) {
            [searchResults addObject:user];
        }
    }
    return YES;
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
