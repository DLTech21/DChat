//
//  Tool.h
//  VPlus
//
//  Created by Donal on 13-5-22.
//  Copyright (c) 2013年 vikaa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "AppDelegate.h"
#import "RegexKitLite.h"

@interface Tool : NSObject


+(int)getViewHeightWithUIFont:(UIFont *)font andText:(NSString *)txt andFixedWidth:(int)width minHeight:(int)minHeight;
+(int)getViewWidthWithUIFont:(UIFont *)font andText:(NSString *)txt andFixedHeigth:(int)height minWidth:(int)minWidth;

+ (void)playSoundIDwithFileID:(NSString *)FileId inDirectory:(NSString *)Directory withType:(NSString *)type;

+ (NSString *)sha1:(NSString *)str;
+ (NSString *)md5:(NSString *)str;
//16位MD5加密方式
+ (NSString *)getMd5_16Bit_String:(NSString *)srcString;
//32位MD5加密方式
+ (NSString *)getMd5_32Bit_String:(NSString *)srcString;

+ (NSString*)getTimeStamp;
+ (NSString*)phplong2Data:(NSString*)dateNumber;//将php的时间戳转换为date
+(NSString*)phpBirthday2Data:(NSString *)dateNumber;
+ (NSString *)intervalSinceNow: (NSString *) theDate;//友好时间
+ (UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize;
+ (NSString*)resolveSinaWeiboDate:(NSString*)date;

+(NSString*)returnDataFilePath:(NSString*)fileName;
+(BOOL)saveDataIntoFile:(NSObject*)obj key:(NSString*)key fileName:(NSString*)fileName;
+(NSObject*)readDataFromFile:(NSString*)fileName key:(NSString*)key;

+(NSString*)returnRecordFilePath:(NSString*)fileName;
+(NSString*)returnCompressedPhotoFilePath:(NSString*)fileName;
+(NSString*)returnImageFilePath;

+ (long)fileSizeForDir:(NSString*)path;//计算文件夹下文件的总大小

+(NSString *) platformString;

+(void)showCompletedTextOnStatusBar:(NSString *)text;
+(void)showLoadingTextOnStatuBar:(NSString *)text;
+(void)showErrorTextOnStatusBar:(NSString *)text;
+(void)showNothingOnStatuBar;

+(NSString *)getAlpha:(NSString *)str;
@end
