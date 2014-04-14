//
//  MessageManager.h
//  qunyou
//
//  Created by Donal on 14-3-13.
//  Copyright (c) 2014年 vikaa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMMessage.h"
#import "FMDatabase.h"

@interface MessageManager : NSObject

+(BOOL)saveIMMessage:(IMMessage *)imMessage;

+(void)getFirstMessageListByFrom:(NSString *)roomId
                        callback:(void (^) (NSArray *array))callback;

+(void)getMessageListByFrom:(NSString *)roomId
                      maxId:(NSString *)maxId
                   callback:(void (^) (NSArray *array))callback;

+(NSArray *)getMessageListByFrom:(NSString *)roomId
                           maxId:(NSString *)maxId;


+(NSArray *)getSendingMessages:(NSString *)roomId;
+(NSArray *)getSendingMessages;

+(void)updateMessagesByroomId:(NSString *)roomId
                       openId:(NSString *)openId
                        msgId:(NSString *)msgId
                    imMessage:(IMMessage *)imMessage;

+(void)updateMessagesByroomId:(NSString *)roomId
                       openId:(NSString *)openId
                        msgId:(NSString *)msgId
                       chatId:(NSNumber *)chatId
                       postAt:(NSString *)postAt;

+(BOOL)updateChatIdBy:(IMMessage *)immsg;

+(BOOL)isIMMessageExist:(IMMessage *)immsg;
@end
