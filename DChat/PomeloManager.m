//
//  PomeloManager.m
//  qunyou
//
//  Created by Donal on 14-3-13.
//  Copyright (c) 2014年 vikaa. All rights reserved.
//

#import "PomeloManager.h"
#import "MessageManager.h"
#import "JSBubbleView.h"
#import "Tool.h"

@implementation PomeloManager

static PomeloManager *sharedManager;
static Pomelo *pomeloChat;

+(PomeloManager *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager=[[PomeloManager alloc] init];
        [sharedManager initPomeloClient];
    });
    return sharedManager;
}

-(void)initPomeloClient
{
    pomeloChat = [[Pomelo alloc] initWithDelegate:self];
}

-(void)setupClient
{
    if (!isPomeloConnected) {
        [self queryEntry];
    }
}

-(void)queryEntry
{
    __weak id that = self;
    [pomeloChat connectToHost:@"192.168.1.147" onPort:3014 withCallback:^(Pomelo *p){
        NSDictionary *params = [NSDictionary dictionaryWithObject:getUserID forKey:@"uid"];
        [pomeloChat requestWithRoute:@"gate.gateHandler.queryEntry" andParams:params andCallback:^(NSDictionary *result){
            [pomeloChat disconnectWithCallback:^(Pomelo *p){
                [that entryWithData:result];
            }];
        }];
    }];
}


- (void)entryWithData:(NSDictionary *)data
{
    @synchronized(data) {
        NSString *host = [data objectForKey:@"host"];
        NSInteger port = [[data objectForKey:@"port"] intValue];
        __weak id that = self;
        [pomeloChat connectToHost:host onPort:port withCallback:^(Pomelo *p){
            NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                    getUserID, @"username",
                                    @"wechatim", @"rid",
                                    nil];
            [p requestWithRoute:@"connector.entryHandler.enter" andParams:params andCallback:^(NSDictionary *result){
                debugLog(@"%@", result);
                NSArray *users = [result objectForKey:@"users"];
                [[NSNotificationCenter defaultCenter] postNotificationName:ChatAllUserNotifaction object:users ];
                [that initEvents];
                [that findUnSendMessage];
            }];
        }];
    }
    
}

-(void)reconnectPomelo
{
    [self queryEntry];
}

-(void)findUnSendMessage
{
    NSArray *array = [MessageManager getSendingMessages];
    for (IMMessage *immsg in array) {
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                immsg.roomId, @"roomId",
                                immsg.content, @"content",
                                immsg.time, @"msgId",
                                nil];
        @try {
            [[[PomeloManager sharedInstance] getPomeloClient] requestWithRoute:@"chat.chatHandler.send"
                                                                     andParams:params
                                                                   andCallback:^(NSDictionary * data) {
                                                                       NSString *openId = [data  objectForKey:@"sender"];
                                                                       NSString *roomId = [data  objectForKey:@"room_id"];
                                                                       NSString *msgId  = [data  objectForKey:@"msg_id"];
                                                                       NSString *postAt = [data objectForKey:@"post_at"];
                                                                       NSInteger chatId = [[data objectForKey:@"chat_id"] integerValue];
                                                                       [MessageManager updateMessagesByroomId:roomId
                                                                                                       openId:openId
                                                                                                        msgId:msgId
                                                                                                       chatId:[NSNumber numberWithInteger:chatId]
                                                                                                       postAt:postAt];
                                                                       [[NSNotificationCenter defaultCenter] postNotificationName:ChatUpdateMsgNotifaction
                                                                                                                           object:data];
                                                                   }];
        }
        @catch (NSException *exception) {
        }
    }
}

- (void)initEvents
{
    __weak id that = self;
    [pomeloChat onRoute:@"onChat"
           withCallback:^(NSDictionary *data){
               debugLog(@"%@", data);
               NSString *openId  = [[data objectForKey:@"body"] objectForKey:@"sender"];
               NSString *roomId  = [[data objectForKey:@"body"] objectForKey:@"room_id"];
               NSString *content = [[data objectForKey:@"body"] objectForKey:@"msg"];
               NSString *postAt  = [[data objectForKey:@"body"] objectForKey:@"post_at"];
               NSInteger chatId  = [[[data objectForKey:@"body"] objectForKey:@"chat_id"] integerValue];
               [that saveMessage:content
                            time:postAt
                          roomId:roomId
                          openId:openId
                         msgType:JSBubbleMessageTypeIncoming
                       msgStatus:JSBubbleMessageStatusReceiving
                          chatId:chatId
                          postAt:postAt];
           }];
    [pomeloChat onRoute:@"onLeave"
           withCallback:^(NSDictionary *data) {
               debugLog(@"%@", data);
               NSString *user = [[data objectForKey:@"body"] objectForKey:@"user"];
               [[NSNotificationCenter defaultCenter] postNotificationName:ChatLeaveUserNotifaction object:user ];
           }];
    [pomeloChat onRoute:@"onAdd"
           withCallback:^(NSDictionary *data) {
               debugLog(@"%@", data);
               NSString *user = [[data objectForKey:@"body"] objectForKey:@"user"];
               [[NSNotificationCenter defaultCenter] postNotificationName:ChatNewUserNotifaction object:user ];
           }];
}

-(void)sendMessage:(NSString *)roomId
    messageContent:(NSString *)messageContent
           success:(void (^) (NSDictionary *model))success
           failure:(void (^) (NSString *errorMessage))failure
{
    NSString *time = [Tool getTimeStamp];
    [self saveMessage:messageContent
                 time:time
               roomId:roomId
               openId:getUserID
              msgType:JSBubbleMessageTypeOutgoing
            msgStatus:JSBubbleMessageStatusDelivering
               chatId:-1
               postAt:time];
//    if (![[PomeloManager sharedInstance] getIsPomeloConnected]) {
//        
//        return;
//    }
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            roomId, @"roomId",
                            messageContent, @"content",
                            [Tool getTimeStamp], @"msgId",
                            nil];
    @try {
        [[[PomeloManager sharedInstance] getPomeloClient] requestWithRoute:@"chat.chatHandler.send"
                                                                 andParams:params
                                                               andCallback:^(NSDictionary * data) {
                                                                   if (success) {
                                                                       success(data);
                                                                   }
                                                               }];
    }
    @catch (NSException *exception) {
        if (failure) {
            failure(exception.description);
        }
    }
}

-(Pomelo *)getPomeloClient
{
    return pomeloChat;
}

-(BOOL)getIsPomeloConnected
{
   return [[pomeloChat socketIO] isConnected];
//    return isPomeloConnected;
}

-(void)disconnectPomelo
{
    [pomeloChat disconnect];
}

-(void)saveMessage:(NSString *)content
              time:(NSString *)time
            roomId:(NSString *)roomId
            openId:(NSString *)openId
           msgType:(NSInteger)msgType
         msgStatus:(NSInteger)msgStatus
            chatId:(NSInteger)chatId
            postAt:(NSString *)postAt
{
    IMMessage *immsg = [IMMessage initIMMessage:roomId
                                         openId:openId
                                        content:content
                                           time:time
                                        msgType:msgType
                                      msgStatus:msgStatus
                                      mediaType:JSBubbleMediaTypeText
                                         chatId:chatId
                                         postAt:postAt];
    [MessageManager saveIMMessage:immsg];
}


#pragma mark pomelo delegate
-(void)Pomelo:(Pomelo *)pomelo didReceiveMessage:(NSArray *)message
{
    
}

-(void)PomeloDidConnect:(Pomelo *)pomelo
{
    debugLog(@"connect");
    isPomeloConnected = YES;
}

-(void)PomeloDidDisconnect:(Pomelo *)pomelo withError:(NSError *)error
{
    debugLog(@"disconnect");
    isPomeloConnected = NO;
    //schedule reconnect scheme
}

@end
