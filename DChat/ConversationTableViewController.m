//
//  ConversationTableViewController.m
//  DChat
//
//  Created by Donal on 14-4-14.
//  Copyright (c) 2014年 DChat. All rights reserved.
//

#import "ConversationTableViewController.h"
#import "LoginStep1ViewController.h"
#import "CRNavigationController.h"
#import "PomeloManager.h"
#import "ChattingViewController.h"
#import "MessageManager.h"
#import "TDBadgedCell.h"
#import "NSString+Wrapper.h"

@interface ConversationTableViewController () <LoginStep1ViewControllerDelegate, ChattingViewControllerDelegate, UISearchDisplayDelegate, UISearchBarDelegate>
{
    UIActivityIndicatorView *loadingIndicator;
    NSMutableArray *conversations;
    NSInteger badge;
    NSMutableArray *searchResults;
}
@end

@implementation ConversationTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initUI];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newMsgCome:) name:ChatNewMsgNotifaction object:nil];
    conversations = [NSMutableArray array];
    searchResults = [NSMutableArray array];
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView setTableFooterView:v];
    if (!isLogin) {
        [self showLogin];
    }
    else {
        [self registerPomelo];
    }
    [conversations removeAllObjects];
    [conversations addObjectsFromArray:[MessageManager getConversations]];
    [self setBadge];
    [self.tableView reloadData];
}

-(void)initUI
{
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
    
    titleLabel.text = @"会话";
    
    loadingIndicator                  = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [loadingIndicator setFrame:CGRectMake(titleView.frame.size.width-35, 10, 25, 25)];
    loadingIndicator.hidden           = NO;
    loadingIndicator.hidesWhenStopped = YES;
    
    [titleView addSubview:titleLabel];
    [titleView addSubview:loadingIndicator];
    
    self.navigationItem.titleView = titleView;
}

-(void)setBadge
{
    badge = 0;
    for (IMMessage *conversation in conversations) {
        badge += [conversation.noticeSum integerValue];
    }
    if (badge != 0) {
        [[[self.tabBarController.viewControllers objectAtIndex:0] tabBarItem] setBadgeValue:[NSString stringWithFormat:@"%i", badge]];
    }
    else {
        [[[self.tabBarController.viewControllers objectAtIndex:0] tabBarItem] setBadgeValue:nil];
    }
}

#pragma mark pomelomanager
-(void)registerPomelo
{
    if (![[PomeloManager sharedInstance] getIsPomeloConnected]) {
        [[PomeloManager sharedInstance] setupClient];
    }
}

#pragma mark chat somebody
-(void)chatSomebody:(NSString *)user
{
    ChattingViewController *vc = [[ChattingViewController alloc] init];
    vc.roomId = user;
    vc.hidesBottomBarWhenPushed = YES;
    vc.chatDelegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark chat delegate
-(void)updateConversationBadge
{
    [conversations removeAllObjects];
    [conversations addObjectsFromArray:[MessageManager getConversations]];
    [self setBadge];
    [self.tableView reloadData];
}

#pragma mark login
-(void)showLogin
{
    setLogout;
    LoginStep1ViewController *vc = [[LoginStep1ViewController alloc] initWithNibName:@"LoginStep1ViewController" bundle:nil];
    vc.delegate                  = self;
    CRNavigationController *nav  = [[CRNavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:NO completion:nil];
}

#pragma mark login delegate
-(void)vertifySuccess
{
    [self dismissViewControllerAnimated:NO completion:nil];
    if (![[PomeloManager sharedInstance] getIsPomeloConnected]) {
        [[PomeloManager sharedInstance] setupClient];
    }
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
        return [conversations count];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier;
    CellIdentifier = @"conversationcell";
    TDBadgedCell *cell = [[TDBadgedCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] ;
    IMMessage *conversation;
    if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        conversation = [searchResults objectAtIndex:indexPath.row];
    }
	else
	{
        conversation = [conversations objectAtIndex:indexPath.row];
    }
    
    cell.textLabel.text = conversation.roomId;
    cell.detailTextLabel.text = conversation.content;
    cell.badgeString = [conversation.noticeSum isEqualToString:@"0"]?nil:conversation.noticeSum;
    cell.badgeColor = UIColorFromRGB(0xff3b30, 1.0);
    cell.badge.fontSize = 16;
    if (conversations.count-1 == indexPath.row) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    else {
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 15, 0, 0)];
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView) {
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            IMMessage *conversation = [conversations objectAtIndex:indexPath.row];
            badge -= [conversation.noticeSum integerValue];
            if (badge != 0) {
                [[[self.tabBarController.viewControllers objectAtIndex:0] tabBarItem] setBadgeValue:[NSString stringWithFormat:@"%i", badge]];
            }
            else {
                [[[self.tabBarController.viewControllers objectAtIndex:0] tabBarItem] setBadgeValue:nil];
            }
            [MessageManager deleteMessages:conversation.roomId];
            [conversations removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        } else if (editingStyle == UITableViewCellEditingStyleInsert) {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/
#pragma mark   搜索
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    NSArray *temp = [MessageManager getConversations];
    [searchResults removeAllObjects];
    for (IMMessage *im in temp) {
        if ([im.roomId contains:searchString]) {
            [searchResults addObject:im];
        }
    }
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    NSString *searchString = [self.searchDisplayController.searchBar text];
    NSArray *temp = [MessageManager getConversations];
    [searchResults removeAllObjects];
    for (IMMessage *im in temp) {
        if ([im.roomId contains:searchString]) {
            [searchResults addObject:im];
        }
    }
    return YES;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view endEditing:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    IMMessage *user = [conversations objectAtIndex:indexPath.row];
    user.noticeSum = @"0";
    [self chatSomebody:user.roomId];
}

#pragma mark  接受更新UI消息广播
-(void)newMsgCome:(NSNotification *)notifacation
{
    IMMessage *msg = (IMMessage *)notifacation.object;
    NSString *roomId = msg.roomId;
    //update ui
    for (IMMessage *immsg in conversations) {
        if ([roomId isEqualToString:immsg.roomId]) {
            NSInteger num = [immsg.noticeSum integerValue];
            num++;
            immsg.noticeSum = [NSString stringWithFormat:@"%i", num];
            break;
        }
    }
    [self setBadge];
    [self.tableView reloadData];
}
@end
