//
//  LoginStep1ViewController.h
//  qunyou
//
//  Created by Donal on 13-12-3.
//  Copyright (c) 2013年 vikaa. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LoginStep1ViewControllerDelegate <NSObject>

-(void)vertifySuccess;

@end

@interface LoginStep1ViewController : UIViewController

@property (nonatomic, assign) id<LoginStep1ViewControllerDelegate> delegate;

@end
