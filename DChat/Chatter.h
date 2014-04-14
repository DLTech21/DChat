//
//  Chatter.h
//  qunyou
//
//  Created by Donal on 14-3-17.
//  Copyright (c) 2014年 vikaa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Chatter : NSObject

@property (nonatomic, strong) NSString * openid;
@property (nonatomic, strong) NSString * assist_openid;
@property (nonatomic, strong) NSString * avatar;
@property (nonatomic, strong) NSString * sex;
@property (nonatomic, strong) NSString * state;
@property (nonatomic, strong) NSString * weibo;
@property (nonatomic, strong) NSString * realname;
@property (nonatomic, strong) NSString * font_family;
@property (nonatomic, strong) NSString * pinyin;
@property (nonatomic, strong) NSString * phone;
@property (nonatomic, strong) NSString * email;
@property (nonatomic, strong) NSString * department;
@property (nonatomic, strong) NSString * position;
@property (nonatomic, strong) NSString * birthday;
@property (nonatomic, strong) NSString * address;
@property (nonatomic, strong) NSString * hits;
@property (nonatomic, strong) NSString * certified;
@property (nonatomic, strong) NSString * privacy;
@property (nonatomic, strong) NSString * supply;
@property (nonatomic, strong) NSString * needs;
@property (nonatomic, strong) NSString * intro;
@property (nonatomic, strong) NSString * wechat;
@property (nonatomic, strong) NSString * nickname;
@property (nonatomic, strong) NSString * link;
@property (nonatomic, strong) NSString * code;
@property (nonatomic, strong) NSString * isfriend;
@property (nonatomic, strong) NSString * chathash;
@property (nonatomic, strong) NSString * phone_display;

+(Chatter *)handleJson:(NSDictionary *)json;

@end
