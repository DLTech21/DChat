//
//  DLAppUtil.h
//  qunyou
//
//  Created by Donal on 14-3-13.
//  Copyright (c) 2014年 vikaa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DLAppUtil : NSObject
#define ChatAllUserNotifaction @"ChatAllUserNotifaction"
#define ChatLeaveUserNotifaction @"ChatLeaveUserNotifaction"
#define ChatNewUserNotifaction @"ChatNewUserNotifaction"
#define ChatNewMsgNotifaction @"ChatNewMsgNotifaction"
#define ChatUpdateMsgNotifaction @"ChatUpdateMsgNotifaction"

//FMDB
#define FMDBQuickCheck(SomeBool) { if (!(SomeBool)) { NSLog(@"Failure on line %d", __LINE__); abort(); } }
#define DATABASE_PATH [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0]stringByAppendingString:[NSString stringWithFormat:@"/%@.db", getUserID]]

#ifdef DEBUG
//调试模式
#define debugLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)

//发布模式
#else

#define debugLog(...)

#endif

#define UIColorFromRGB(rgbValue,al) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:al]
#define IOS7 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
#define IS_IPHONE5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)

#define SYSTEM_VERSION_GREATER_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)

#define isGuided [[NSUserDefaults standardUserDefaults] boolForKey:IsGuide]
#define setIsGuided [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IsGuide];[[NSUserDefaults standardUserDefaults] synchronize];

#define setBaiduPushType(user) [[NSUserDefaults standardUserDefaults] setObject:(user) forKey:BaiduPushType];[[NSUserDefaults standardUserDefaults] synchronize];
#define getBaiduPushType [[NSUserDefaults standardUserDefaults] objectForKey:BaiduPushType]

#define setBaiduUserID(user) [[NSUserDefaults standardUserDefaults] setObject:(user) forKey:BaiduChannelId];[[NSUserDefaults standardUserDefaults] synchronize];
#define getBaiduUserID [[NSUserDefaults standardUserDefaults] objectForKey:BaiduChannelId]

#define setBaiduChannelID(user) [[NSUserDefaults standardUserDefaults] setObject:(user) forKey:BaiduUserId];[[NSUserDefaults standardUserDefaults] synchronize];
#define getBaiduChannelID [[NSUserDefaults standardUserDefaults] objectForKey:BaiduUserId]

#define IsNetwork [[NSUserDefaults standardUserDefaults] boolForKey:IsNetworking]
#define setIsNetwork(work) [[NSUserDefaults standardUserDefaults] setBool:work forKey:IsNetworking];[[NSUserDefaults standardUserDefaults] synchronize];

#define isLogin [[NSUserDefaults standardUserDefaults] boolForKey:IsUserLogin]
#define setIsLogin [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IsUserLogin];[[NSUserDefaults standardUserDefaults] synchronize];
#define setLogout [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:IsUserLogin];[[NSUserDefaults standardUserDefaults] synchronize];

#define setUserID(user) [[NSUserDefaults standardUserDefaults] setObject:(user) forKey:APPUserID];[[NSUserDefaults standardUserDefaults] synchronize];
#define getUserID [[NSUserDefaults standardUserDefaults] objectForKey:APPUserID]

#define setUserAvatar(user) [[NSUserDefaults standardUserDefaults] setObject:(user) forKey:APPUserAvatar];[[NSUserDefaults standardUserDefaults] synchronize];
#define getUserAvatar [[NSUserDefaults standardUserDefaults] objectForKey:APPUserAvatar]

#define setUserNickname(user) [[NSUserDefaults standardUserDefaults] setObject:(user) forKey:APPUserNickname];[[NSUserDefaults standardUserDefaults] synchronize];
#define getUserNickname [[NSUserDefaults standardUserDefaults] objectForKey:APPUserNickname]

#define setUserSign(user) [[NSUserDefaults standardUserDefaults] setObject:(user) forKey:APPUserSign];[[NSUserDefaults standardUserDefaults] synchronize];
#define getUserSign [[NSUserDefaults standardUserDefaults] objectForKey:APPUserSign]

#define setUserHash(user) [[NSUserDefaults standardUserDefaults] setObject:(user) forKey:APPUserHash];[[NSUserDefaults standardUserDefaults] synchronize];
#define getUserHash [[NSUserDefaults standardUserDefaults] objectForKey:APPUserHash]

#define setDeviceToken(user) [[NSUserDefaults standardUserDefaults] setObject:(user) forKey:DeviceToken];[[NSUserDefaults standardUserDefaults] synchronize];
#define getDeviceToken [[NSUserDefaults standardUserDefaults] objectForKey:DeviceToken]

#define setOauthType(oauthType) [[NSUserDefaults standardUserDefaults] setInteger:oauthType forKey:OauthType];[[NSUserDefaults standardUserDefaults] synchronize];
#define getOauthType [[NSUserDefaults standardUserDefaults] integerForKey:OauthType]


//nsuserdefault key
#define IsGuide @"isGuide"
#define BaiduPushType @"BaiduPushType"
#define BaiduUserId @"BaiduUserId"
#define BaiduChannelId @"BaiduChannelId"
#define IsNetworking @"IsNetwork"
#define IsUserLogin @"isUserLogin"
#define APPUserID @"app.user.id"
#define APPUserAvatar @"app.user.avatar"
#define APPUserNickname @"app.user.nickname"
#define APPUserSign @"app.user.sign"
#define APPUserHash @"app.user.hash"
#define OauthType @"OauthType"
#define DeviceToken @"DeviceToken"

//TABLEVIEW SCROLL STATE
#define TABLEVIEW_ACTION_NORMAL 0
#define TABLEVIEW_ACTION_INIT 1
#define TABLEVIEW_ACTION_REFRESH 2
#define TABLEVIEW_ACTION_SCROLL 3
//TABLEVIEW DATA STATE
#define TABLEVIEW_DATA_NORMAL 0
#define TABLEVIEW_DATA_MORE 1
#define TABLEVIEW_DATA_LOADING 2
#define TABLEVIEW_DATA_FULL 3
#define TABLEVIEW_DATA_EMPTY 4
#define TABLEVIEW_DATA_ERROR 5

#define PageCount 10

#define TableViewDragUpHeight 10

#define ButtonEnLargeEdge 40

#define StatusBarHeight 20
#define screenframe [[UIScreen mainScreen] bounds]

@end
