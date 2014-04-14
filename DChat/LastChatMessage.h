//
//  LastChatMessage.h
//  qunyou
//
//  Created by Donal on 14-3-13.
//  Copyright (c) 2014年 vikaa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LastChatMessage : NSObject

@property (nonatomic, strong) NSString  * lid;
@property (nonatomic, strong) NSString  * title;
@property (nonatomic, strong) NSString  * content;
@property (nonatomic, strong) NSString  * from;
@property (nonatomic, strong) NSString  * to;
@property (nonatomic, strong) NSString  * noticeTime;
@property (nonatomic        ) NSInteger status; // 0已读 1未读
@property (nonatomic        ) NSInteger noticeSum;
@property (nonatomic        ) NSInteger noticeType;

@end
