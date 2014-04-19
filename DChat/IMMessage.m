//
//  IMMessage.m
//  qunyou
//
//  Created by Donal on 14-3-13.
//  Copyright (c) 2014年 vikaa. All rights reserved.
//

#import "IMMessage.h"
#import "JSBubbleView.h"

@implementation IMMessage

+(IMMessage *)initIMMessage:(NSString *)roomId
                     openId:(NSString *)openId
                    content:(NSString *)content
                       time:(NSString *)time
                    msgType:(NSInteger)msgType
                  msgStatus:(NSInteger)msgStatus
                  mediaType:(NSInteger)mediaType
                     chatId:(NSInteger)chatId
                     postAt:(NSString *)postAt
{
    IMMessage *data = [[IMMessage alloc] init];
    data.roomId     = roomId;
    data.openId     = openId;
    data.content    = content;
    data.time       = time;
    data.msgType    = [NSNumber numberWithInteger:msgType];
    data.msgStatus  = [NSNumber numberWithInteger:msgStatus];
    data.mediaType  = [NSNumber numberWithInteger:mediaType];
    data.chatId     = [NSNumber numberWithInteger:chatId];
    data.postAt     = postAt;
    data.noticeSum  = @"0";
    return data;
}

- (NSComparisonResult)compare:(IMMessage *)otherIMMessage
{
    return [self.time compare:otherIMMessage.time];
}

+(NSMutableArray *)handleJson:(NSDictionary *)json
{
    NSMutableArray *data = [NSMutableArray array];
    if ([[json objectForKey:@"status"] intValue] == 1) {
        NSArray *owned = [json objectForKey:@"info"];
        for (NSDictionary *message in owned) {
            NSString *roomId = [message objectForKey:@"hash"];
            NSString *openId = [message objectForKey:@"openid"];
            NSString *content = [message objectForKey:@"message"];
            NSString *time = [message objectForKey:@"post_at"];
            NSInteger msgType = [openId isEqualToString:getUserID]? JSBubbleMessageTypeOutgoing: JSBubbleMessageTypeIncoming;
            NSInteger msgStatus = JSBubbleMessageStatusReaded;
            NSInteger mediaType = JSBubbleMediaTypeText;
            NSInteger chatId = [[message objectForKey:@"chat_id"] integerValue];
            IMMessage *immsg = [self initIMMessage:roomId
                                            openId:openId
                                           content:content
                                              time:time
                                           msgType:msgType
                                         msgStatus:msgStatus
                                         mediaType:mediaType
                                            chatId:chatId
                                            postAt:time];
            [data addObject:immsg];
        }
    }
    else {
        
    }
    return data;
}

@end
