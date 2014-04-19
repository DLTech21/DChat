//
//  ChattingViewController.m
//  chatview
//
//  Created by Donal on 14-3-24.
//  Copyright (c) 2014年 vikaa. All rights reserved.
//

#import "ChattingViewController.h"
#import "JSMessage.h"
#import "MessageManager.h"
#import "PomeloManager.h"
#import "UIImage+JSMessagesView.h"
#import "UIView+Utils.h"


#define PageSize 10
#define AvatarPlaceHolderImage [UIImage imageNamed:@"avatar-placeholder"]

@interface ChattingViewController () <JSMessagesViewDataSource, JSMessagesViewDelegate>
{
    int tableviewDataState;
}
@property (strong, nonatomic) NSMutableArray *messages;

@end

@implementation ChattingViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    self.delegate = self;
    self.dataSource = self;
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newMsgCome:) name:ChatNewMsgNotifaction object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMsg:) name:ChatUpdateMsgNotifaction object:nil];
    [[JSBubbleView appearance] setFont:[UIFont systemFontOfSize:16.0f]];
    
    [self setBackgroundColor:[UIColor whiteColor]];
    
    self.messages = [NSMutableArray array];
    [self handleArray:[MessageManager getMessageListByFrom:_roomId maxId:@"0"]];
    UITapGestureRecognizer *tapToHideKeyboard = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)];
    [self.tableView addGestureRecognizer:tapToHideKeyboard];
}

-(void)hideKeyboard:(UITapGestureRecognizer *)recognizer
{
    [self.view endEditing:YES];
}

-(void)handleArray:(NSArray *)array
{
    if (array.count >= PageSize) {
        tableviewDataState = TABLEVIEW_DATA_MORE;
    }
    else {
        tableviewDataState = TABLEVIEW_DATA_FULL;
    }
    [self.messages addObjectsFromArray:array];
    [self performSelector:@selector(reloadTable) withObject:nil afterDelay:0];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)reloadTable
{
    [self.tableView reloadData];
    [self scrollToBottomAnimated:NO];
}

-(void)dealloc
{
    [MessageManager updateMessagesReaded:_roomId];
    [self.chatDelegate updateConversationBadge];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ChatNewMsgNotifaction object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ChatUpdateMsgNotifaction object:nil];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        if (tableviewDataState == TABLEVIEW_DATA_FULL || tableviewDataState == TABLEVIEW_DATA_EMPTY) {
            return 0;
        }
        else
            return 1;
    }
    else {
        return self.messages.count;
    }
}

#pragma mark - Messages view delegate: REQUIRED

- (void)didSendText:(NSString *)text fromSender:(NSString *)sender onDate:(NSDate *)date
{
    if (![[PomeloManager sharedInstance] getIsPomeloConnected]) {
        [[PomeloManager sharedInstance] setupClient];
    }
    [[PomeloManager sharedInstance] sendMessage:_roomId
                                 messageContent:text
                                        success:^(NSDictionary *data) {
                                            NSString *openId = [data  objectForKey:@"sender"];
                                            NSString *roomId = _roomId;
                                            NSString *msgId  = [data  objectForKey:@"msg_id"];
                                            NSString *postAt = [data objectForKey:@"post_at"];
                                            //update ui
                                            for (IMMessage *immsg in self.messages) {
                                                if ([immsg.msgStatus integerValue] == JSBubbleMessageStatusDelivering && [immsg.time isEqualToString:msgId]) {
                                                    immsg.msgStatus = [NSNumber numberWithInteger:JSBubbleMessageStatusReaded];
                                                    immsg.time = postAt;
                                                    immsg.postAt = postAt;
                                                    immsg.chatId = [NSNumber numberWithInteger:1];
                                                    [MessageManager updateMessagesByroomId:roomId
                                                                                    openId:openId
                                                                                     msgId:msgId
                                                                                 imMessage:immsg];
                                                }
                                            }
                                            [self.tableView reloadData];
                                        }
                                        failure:^(NSString *errorMessage) {
                                            debugLog(@"%@", errorMessage);
                                        }];
    [self finishSend];
    [self scrollToBottomAnimated:YES];
}

- (JSBubbleMessageType)messageTypeForRowAtIndexPath:(NSIndexPath *)indexPath
{
    IMMessage *msg = [self.messages objectAtIndex:indexPath.row];
    return [msg.msgType integerValue];
}

- (UIImageView *)bubbleImageViewWithType:(JSBubbleMessageType)type
                       forRowAtIndexPath:(NSIndexPath *)indexPath
{
    IMMessage *msg = [self.messages objectAtIndex:indexPath.row];
    if ([msg.msgType integerValue] == JSBubbleMessageTypeIncoming) {
        return [JSBubbleImageViewFactory classicBubbleImageViewForType:JSBubbleMessageTypeIncoming
                                                                 style:JSBubbleImageViewStyleClassicSquareGray];
    }
    
    return [JSBubbleImageViewFactory classicBubbleImageViewForType:JSBubbleMessageTypeOutgoing
                                                             style:JSBubbleImageViewStyleClassicSquareBlue];
}

- (JSMessageInputViewStyle)inputViewStyle
{
    return JSMessageInputViewStyleFlat;
}

#pragma mark - Messages view delegate: OPTIONAL

- (BOOL)shouldDisplayTimestampForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row % 3 == 0) {
        return YES;
    }
    return NO;
}

//
//  *** Implement to customize cell further
//
- (void)configureCell:(JSBubbleMessageCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    IMMessage *msg = [self.messages objectAtIndex:indexPath.row];
    if ([msg.msgType integerValue] == JSBubbleMessageTypeOutgoing) {
        if ([cell.bubbleView.textView respondsToSelector:@selector(linkTextAttributes)]) {
            NSMutableDictionary *attrs = [cell.bubbleView.textView.linkTextAttributes mutableCopy];
            [attrs setValue:[UIColor blueColor] forKey:NSForegroundColorAttributeName];
            cell.bubbleView.textView.linkTextAttributes = attrs;
        }
    }
    
    if (cell.timestampLabel) {
        cell.timestampLabel.textColor = [UIColor lightGrayColor];
        cell.timestampLabel.shadowOffset = CGSizeZero;
    }
    
    if (cell.subtitleLabel) {
        cell.subtitleLabel.textColor = [UIColor lightGrayColor];
    }
    
    
    
#if TARGET_IPHONE_SIMULATOR
    cell.bubbleView.textView.dataDetectorTypes = UIDataDetectorTypeNone;
#else
    cell.bubbleView.textView.dataDetectorTypes = UIDataDetectorTypeAll;
#endif
}

//  *** Implement to use a custom send button
//
//  The button's frame is set automatically for you
//
//  - (UIButton *)sendButtonForInputView
//

//  *** Implement to prevent auto-scrolling when message is added
//
- (BOOL)shouldPreventScrollToBottomWhileUserScrolling
{
    return YES;
}

// *** Implemnt to enable/disable pan/tap todismiss keyboard
//
- (BOOL)allowsPanToDismissKeyboard
{
    return YES;
}

#pragma mark - Messages view data source: REQUIRED

- (JSMessage *)messageForRowAtIndexPath:(NSIndexPath *)indexPath
{
    IMMessage *msg = [self.messages objectAtIndex:indexPath.row];
    return [[JSMessage alloc] initWithText:msg.content sender:nil date:nil];
}

- (void)moreCell:(MoreCell *)cell
{
    cell.loadingIndicator.left = (cell.contentView.width-cell.loadingIndicator.width)/2;
    if (tableviewDataState == TABLEVIEW_DATA_EMPTY) {
        [cell.loadingIndicator setHidden:YES];
        [cell.loadingIndicator stopAnimating];
    }
    else if (tableviewDataState == TABLEVIEW_DATA_ERROR) {
        [cell.loadingLabel setText:@"网络不给力哦!"];
        [cell.loadingIndicator setHidden:YES];
        [cell.loadingIndicator stopAnimating];
    }
    else if (tableviewDataState == TABLEVIEW_DATA_MORE ) {
        cell.loadingLabel.text = @"";
        [cell.loadingIndicator setHidden:NO];
        [cell.loadingIndicator startAnimating];
    }
    else if (tableviewDataState == TABLEVIEW_DATA_LOADING ) {
        cell.loadingLabel.text = @"";
        [cell.loadingIndicator setHidden:NO];
        [cell.loadingIndicator startAnimating];
    }
    else if (TABLEVIEW_DATA_NORMAL == tableviewDataState) {
        cell.loadingLabel.text = @"";
        [cell.loadingIndicator setHidden:NO];
        [cell.loadingIndicator startAnimating];
    }
}

-(BOOL)displaySendingIndicatorForRowAtIndexPath:(NSIndexPath *)indexPath
{
    IMMessage *msg = [self.messages objectAtIndex:indexPath.row];
    return [msg.msgStatus integerValue] == JSBubbleMessageStatusDelivering;
}

-(void)avatarImageForMessage:(UIImageView *)imageView avatarUrlForRowAtIndexPath:(NSIndexPath *)indexPath
{
    IMMessage *msg = [self.messages objectAtIndex:indexPath.row];
    if ([msg.msgType integerValue] == JSBubbleMessageTypeIncoming) {
        [imageView setImage:AvatarPlaceHolderImage];
//        [self getChatterInfoby:msg.openId
//               toDisplayAvatar:imageView];
    }
    else {
        [imageView setImage:AvatarPlaceHolderImage];
        [self displayAvatar:getUserAvatar inImageView:imageView];
    }
}

#pragma mark get User Info by openId
//-(void)getChatterInfoby:(NSString *)openId toDisplayAvatar:(UIImageView *)imageView
//{
//    NSData *data = [[NSData alloc] initWithContentsOfFile:[Tool returnDataFilePath:[NSString stringWithFormat:@"%@-%@", [NSString stringWithFormat:@"%@-%@", ChatterInfo, openId], getUserID]]];
//    if(data) {
//        id dic = [NSJSONSerialization JSONObjectWithData:data
//                                                 options:NSJSONReadingAllowFragments error:nil];
//        Chatter *model = [Chatter handleJson:dic];
//        [self displayAvatar:model.avatar
//                inImageView:imageView];
//    }
//    else {
//        __weak id that = self;
//        [[AppClient sharedInstance] getChatterBy:openId
//                                         success:^(Chatter *model) {
//                                             [that displayAvatar:model.avatar
//                                                     inImageView:imageView];
//                                         }];
//    }
//}

-(void)displayAvatar:(NSString *)avatar inImageView:(UIImageView *)imageView
{
    __weak UIImageView * _imageView          = imageView;
    [imageView setImageWithURL:[NSURL URLWithString:avatar]
              placeholderImage:AvatarPlaceHolderImage
                       options:SDWebImageRetryFailed|SDWebImageLowPriority
                      progress:^(NSUInteger receivedSize, long long expectedSize) {
                          
                      }
                     completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                         if (error) {
                             return ;
                         }
                         [_imageView setImage:image];
                     }];
}

#pragma mark  接受新消息广播
-(void)newMsgCome:(NSNotification *)notifacation
{
    IMMessage *msg = (IMMessage *)notifacation.object;
    if (![msg.roomId isEqualToString:_roomId]) {
        return;
    }
    [self receivedMessage:msg];
}

-(void)receivedMessage:(IMMessage *)msg
{
//    if([msg.msgType integerValue] == JSBubbleMessageTypeIncoming) {
//        [JSMessageSoundEffect playMessageReceivedSound];
//    }
    [self.messages addObject:msg];
    [self.tableView reloadData];
    [self scrollToBottomAnimated:YES];
}

#pragma mark  接受更新UI消息广播
-(void)updateMsg:(NSNotification *)notifacation
{
    NSDictionary *data = (NSDictionary *)notifacation.object;
    NSString *roomId = [data  objectForKey:@"room_id"];
    NSString *msgId  = [data  objectForKey:@"msg_id"];
    NSString *postAt = [data objectForKey:@"post_at"];
    NSInteger chatId = [[data objectForKey:@"chat_id"] integerValue];
    if (![roomId isEqualToString:_roomId]) {
        return;
    }
    //update ui
    for (IMMessage *immsg in self.messages) {
        if ([immsg.msgStatus integerValue] == JSBubbleMessageStatusDelivering && [immsg.time isEqualToString:msgId]) {
            immsg.msgStatus = [NSNumber numberWithInteger:JSBubbleMessageStatusReaded];
            immsg.time = postAt;
            immsg.postAt = postAt;
            immsg.chatId = [NSNumber numberWithInteger:chatId];
        }
    }
    [self.tableView reloadData];
}

#pragma mark pull to get more history
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y < 20 && tableviewDataState == TABLEVIEW_DATA_MORE) {
        tableviewDataState = TABLEVIEW_DATA_LOADING;
        [self getHistory];
    }
}

-(void)getHistory
{
    if (self.messages.count) {
        NSString *maxId = [[self.messages objectAtIndex:0] time] ;
        [self handleHistory:[MessageManager getMessageListByFrom:_roomId maxId:maxId]];
    }
}

-(void)handleHistory:(NSArray *)tempArray
{
    if (tempArray.count == PageSize) {
        tableviewDataState = TABLEVIEW_DATA_MORE;
    }
    else {
        tableviewDataState = TABLEVIEW_DATA_FULL;
    }
    NSIndexSet * indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, tempArray.count)];
    [self.messages insertObjects:tempArray atIndexes:indexSet];
    [self.tableView reloadData];
    float height = 0.0f;
    float lastHeight = 0.0f;
    for (int i=0; i< tempArray.count; i++) {
        IMMessage *msg = [tempArray objectAtIndex:i];
        
        if([msg.mediaType integerValue] == JSBubbleMediaTypeText){
            lastHeight = [JSBubbleMessageCell neededHeightForBubbleMessageCellWithMessage:[[JSMessage alloc] initWithText:msg.content sender:nil date:nil]
                                                                           displaysAvatar:YES
                                                                        displaysTimestamp:NO];
            height += lastHeight;
        }
    }
    [self.tableView setContentOffset:CGPointMake(0, height-(lastHeight)) animated:NO];
}


@end
