//
//  Chatter.m
//  qunyou
//
//  Created by Donal on 14-3-17.
//  Copyright (c) 2014年 vikaa. All rights reserved.
//

#import "Chatter.h"

@implementation Chatter

+(Chatter *)handleJson:(NSDictionary *)json
{
    Chatter *data = [[Chatter alloc] init];
    if ([[json objectForKey:@"status"] intValue] == 1) {
        NSDictionary *info = [json objectForKey:@"info"];
        data.avatar  = [info objectForKey:@"avatar"];
        data.realname        = [info objectForKey:@"realname"];
        data.nickname         = [info objectForKey:@"nickname"];
    }
    return data;
}

@end
