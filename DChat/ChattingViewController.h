//
//  ChattingViewController.h
//  chatview
//
//  Created by Donal on 14-3-24.
//  Copyright (c) 2014年 vikaa. All rights reserved.
//

#import "JSMessagesViewController.h"

@protocol ChattingViewControllerDelegate <NSObject>

-(void)updateConversationBadge:(NSString *)roomId;

@end

@interface ChattingViewController : JSMessagesViewController

@property (nonatomic, strong) NSString *roomId;
@property (nonatomic, assign) id<ChattingViewControllerDelegate> chatDelegate;

@end
