//
//  PomeloManager.h
//  qunyou
//
//  Created by Donal on 14-3-13.
//  Copyright (c) 2014年 vikaa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Pomelo.h"

@interface PomeloManager : NSObject <PomeloDelegate>
{
//    Pomelo *pomeloChat;
    BOOL isPomeloConnected;
}

+(PomeloManager *)sharedInstance;

-(Pomelo *)getPomeloClient;
-(BOOL)getIsPomeloConnected;
-(void)setupClient;

-(void)sendMessage:(NSString *)target
    messageContent:(NSString *)messageContent
           success:(void (^) (NSDictionary *model))success
           failure:(void (^) (NSString *errorMessage))failure;

-(void)disconnectPomelo;
@end
