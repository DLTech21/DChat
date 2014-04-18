//
//  IMMessage.h
//  qunyou
//
//  Created by Donal on 14-3-13.
//  Copyright (c) 2014年 vikaa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IMMessage : NSObject

@property (nonatomic        ) NSNumber  * msgStatus;
@property (nonatomic        ) NSNumber  * msgType; //who owns
@property (nonatomic        ) NSNumber  * mediaType;
@property (nonatomic, strong) NSString  * content;
@property (nonatomic, strong) NSString  * time;
@property (nonatomic, strong) NSString  * openId;
@property (nonatomic, strong) NSString  * roomId;

@property (nonatomic, strong) NSNumber  * chatId;
@property (nonatomic, strong) NSString  * postAt;

@property (nonatomic, strong) NSString  * noticeSum;

+(IMMessage *)initIMMessage:(NSString *)roomId
                     openId:(NSString *)openId
                    content:(NSString *)content
                       time:(NSString *)time
                    msgType:(NSInteger)msgType
                  msgStatus:(NSInteger)msgStatus
                  mediaType:(NSInteger)mediaType
                     chatId:(NSInteger)chatId
                     postAt:(NSString *)postAt;

- (NSComparisonResult)compare:(IMMessage *)otherIMMessage;

+(NSMutableArray *)handleJson:(NSDictionary *)json;
@end
