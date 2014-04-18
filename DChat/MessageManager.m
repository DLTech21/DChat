//
//  MessageManager.m
//  qunyou
//
//  Created by Donal on 14-3-13.
//  Copyright (c) 2014年 vikaa. All rights reserved.
//

#import "MessageManager.h"
#import "JSBubbleView.h"

@implementation MessageManager

+(BOOL)saveIMMessage:(IMMessage *)imMessage
{
    FMDatabase *db = [FMDatabase databaseWithPath:DATABASE_PATH];
    if (![db open]) {
        return NO;
    };
    NSString *createStr=@"CREATE TABLE IF NOT EXISTS [im_msg] ([_id] INTEGER NOT NULL  PRIMARY KEY AUTOINCREMENT, [content] NVARCHAR, [openid] NVARCHAR, [room_id] NVARCHAR, [msg_time] TEXT, [msg_type] INTEGER, [msg_status] INTEGER, [media_type] INTEGER, [chat_id] INTEGER, [post_at] TEXT);";
    BOOL worked = [db executeUpdate:createStr];
    FMDBQuickCheck(worked);
    NSString *insertStr=@"INSERT INTO [im_msg] ([content], [openid], [msg_type], [msg_status], [msg_time], [room_id], [media_type], [post_at], [chat_id]) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?);";
    worked      = [db executeUpdate:insertStr, imMessage.content, imMessage.openId, imMessage.msgType, imMessage.msgStatus, imMessage.time, imMessage.roomId, imMessage.mediaType, imMessage.postAt, imMessage.chatId];
    FMDBQuickCheck(worked);
    [db close];
    [[NSNotificationCenter defaultCenter] postNotificationName:ChatNewMsgNotifaction object:imMessage ];
    return worked;
}

+(BOOL)saveIMMessageOutNoti:(IMMessage *)imMessage
{
    FMDatabase *db = [FMDatabase databaseWithPath:DATABASE_PATH];
    if (![db open]) {
        return NO;
    };
    NSString *createStr=@"CREATE TABLE IF NOT EXISTS [im_msg] ([_id] INTEGER NOT NULL  PRIMARY KEY AUTOINCREMENT, [content] NVARCHAR, [openid] NVARCHAR, [room_id] NVARCHAR, [msg_time] TEXT, [msg_type] INTEGER, [msg_status] INTEGER, [media_type] INTEGER, [chat_id] INTEGER, [post_at] TEXT);";
    BOOL worked = [db executeUpdate:createStr];
    FMDBQuickCheck(worked);
    NSString *insertStr=@"INSERT INTO [im_msg] ([content], [openid], [msg_type], [msg_status], [msg_time], [room_id], [media_type], [post_at], [chat_id]) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?);";
    worked      = [db executeUpdate:insertStr, imMessage.content, imMessage.openId, imMessage.msgType, imMessage.msgStatus, imMessage.time, imMessage.roomId, imMessage.mediaType, imMessage.postAt, imMessage.chatId];
    FMDBQuickCheck(worked);
    [db close];
    return worked;
}

//本地数据库
+(NSArray *)getMessageListByFrom:(NSString *)roomId
                           maxId:(NSString *)maxId
{
    FMDatabase *db = [FMDatabase databaseWithPath:DATABASE_PATH];
    [db open];
    NSString *createStr=@"CREATE TABLE IF NOT EXISTS [im_msg] ([_id] INTEGER NOT NULL  PRIMARY KEY AUTOINCREMENT, [content] NVARCHAR, [openid] NVARCHAR, [room_id] NVARCHAR, [msg_time] TEXT, [msg_type] INTEGER, [msg_status] INTEGER, [media_type] INTEGER, [chat_id] INTEGER, [post_at] TEXT);";
   [db executeUpdate:createStr];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    if ([db open]) {
        NSString *sql ;
        FMResultSet *rs ;
        if ([maxId isEqualToString:@"0"]) {
			sql = @"select * from im_msg where room_id=? and msg_status!=? order by msg_time desc limit ? ";
			rs = [db executeQuery:sql, roomId, [NSNumber numberWithInteger:JSBubbleMessageStatusDelivering], [NSNumber numberWithInt:10]];
		}
		else {
			sql = @"select * from im_msg where room_id=? and msg_status!=? and msg_time<? order by msg_time desc limit ? ";
			rs = [db executeQuery:sql, roomId, [NSNumber numberWithInteger:JSBubbleMessageStatusDelivering], maxId, [NSNumber numberWithInt:10]];
		}
        while ([rs next]) {
            NSString *content    = [rs stringForColumn:@"content"];
            NSString *openId     = [rs stringForColumn:@"openid"];
            NSString *msg_time   = [rs stringForColumn:@"msg_time"];
            NSString *roomId     = [rs stringForColumn:@"room_id"];
            NSInteger msg_type   = [rs intForColumn:@"msg_type"];
            NSInteger status     = [rs intForColumn:@"msg_status"];
            NSInteger mediaType  = [rs intForColumn:@"media_type"];
            NSInteger chatId     = [rs intForColumn:@"chat_id"];
            NSString *postAt     = [rs stringForColumn:@"post_at"];
            IMMessage *imMessage = [IMMessage initIMMessage:roomId
                                                     openId:openId
                                                    content:content
                                                       time:msg_time
                                                    msgType:msg_type
                                                  msgStatus:status
                                                  mediaType:mediaType
                                                     chatId:chatId
                                                     postAt:postAt];
            [array addObject:imMessage];
        }
        [db close];
    }
    NSMutableArray *sortArray = [NSMutableArray array];
    [sortArray addObjectsFromArray:[array sortedArrayUsingSelector:@selector(compare:)]];
    if ([maxId isEqualToString:@"0"]) {
        [sortArray addObjectsFromArray:[self getSendingMessages:roomId]];
    }
    return sortArray;
}

//本地数据库
+(NSArray *)getSendingMessages:(NSString *)roomId
{
    FMDatabase *db = [FMDatabase databaseWithPath:DATABASE_PATH];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    if ([db open]) {
//        NSString *sql = @"update im_msg set post_at=?, msg_time=? where room_id=? and msg_status=? and chat_id=-1;";
//        NSString *time = [Tool getTimeStamp];
//        [db executeUpdate:sql, time, time, roomId, [NSNumber numberWithInt:JSBubbleMessageStatusDelivering]];
        NSString *sql = @"select * from im_msg where room_id=? and msg_status=? order by msg_time desc";
		FMResultSet	*rs = [db executeQuery:sql, roomId, [NSNumber numberWithInt:JSBubbleMessageStatusDelivering]];
        while ([rs next]) {
            NSString *content    = [rs stringForColumn:@"content"];
            NSString *openId     = [rs stringForColumn:@"openid"];
            NSString *msg_time   = [rs stringForColumn:@"msg_time"];
            NSString *roomId     = [rs stringForColumn:@"room_id"];
            NSInteger msg_type   = [rs intForColumn:@"msg_type"];
            NSInteger status     = [rs intForColumn:@"msg_status"];
            NSInteger mediaType  = [rs intForColumn:@"media_type"];
            NSInteger chatId     = [rs intForColumn:@"chat_id"];
            NSString *postAt     = [rs stringForColumn:@"post_at"];
            IMMessage *imMessage = [IMMessage initIMMessage:roomId
                                                     openId:openId
                                                    content:content
                                                       time:msg_time
                                                    msgType:msg_type
                                                  msgStatus:status
                                                  mediaType:mediaType
                                                     chatId:chatId
                                                     postAt:postAt];
            [array addObject:imMessage];
        }
        [db close];
    }
    return array;
}

//本地数据库
+(NSArray *)getSendingMessages
{
    FMDatabase *db = [FMDatabase databaseWithPath:DATABASE_PATH];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    if ([db open]) {
//        NSString *sql = @"update im_msg set post_at=?, msg_time=? where msg_status=? and chat_id=-1;";
//        NSString *time = [Tool getTimeStamp];
//        [db executeUpdate:sql, time, time, [NSNumber numberWithInt:JSBubbleMessageStatusDelivering]];
        NSString *sql = @"select * from im_msg where msg_status=? order by msg_time desc";
		FMResultSet	*rs = [db executeQuery:sql, [NSNumber numberWithInt:JSBubbleMessageStatusDelivering]];
        while ([rs next]) {
            NSString *content    = [rs stringForColumn:@"content"];
            NSString *openId     = [rs stringForColumn:@"openid"];
            NSString *msg_time   = [rs stringForColumn:@"msg_time"];
            NSString *roomId     = [rs stringForColumn:@"room_id"];
            NSInteger msg_type   = [rs intForColumn:@"msg_type"];
            NSInteger status     = [rs intForColumn:@"msg_status"];
            NSInteger mediaType  = [rs intForColumn:@"media_type"];
            NSInteger chatId     = [rs intForColumn:@"chat_id"];
            NSString *postAt     = [rs stringForColumn:@"post_at"];
            IMMessage *imMessage = [IMMessage initIMMessage:roomId
                                                     openId:openId
                                                    content:content
                                                       time:msg_time
                                                    msgType:msg_type
                                                  msgStatus:status
                                                  mediaType:mediaType
                                                     chatId:chatId
                                                     postAt:postAt];
            [array addObject:imMessage];
        }
        [db close];
    }
    return array;
}


+(void)updateMessagesByroomId:(NSString *)roomId
                            openId:(NSString *)openId
                             msgId:(NSString *)msgId
                         imMessage:(IMMessage *)imMessage
{
    FMDatabase *db = [FMDatabase databaseWithPath:DATABASE_PATH];
    if ([db open]) {
        NSString *sql = @"update im_msg set chat_id=?, msg_time=?, msg_status=?, post_at=? where room_id=? and openid=? and msg_time=?;";
        
        [db executeUpdate:sql, imMessage.chatId, imMessage.time, imMessage.msgStatus, imMessage.postAt, roomId, openId, msgId];
        [db close];
    }
}

+(void)updateMessagesByroomId:(NSString *)roomId
                       openId:(NSString *)openId
                        msgId:(NSString *)msgId
                       chatId:(NSNumber *)chatId
                       postAt:(NSString *)postAt
{
    FMDatabase *db = [FMDatabase databaseWithPath:DATABASE_PATH];
    if ([db open]) {
        NSString *sql = @"update im_msg set chat_id=?, msg_time=?, msg_status=?, post_at=? where room_id=? and openid=? and msg_time=?;";
        
        [db executeUpdate:sql, chatId, postAt, [NSNumber numberWithInteger:JSBubbleMessageStatusReaded], postAt, roomId, openId, msgId];
        [db close];
    }
}

+(BOOL)updateChatIdBy:(IMMessage *)immsg
{
    FMDatabase *db = [FMDatabase databaseWithPath:DATABASE_PATH];
    BOOL worked = false;
    if ([db open]) {
        NSString *sql = @"update im_msg set chat_id=? where room_id=? and openid=? and post_at=?;";
        worked = [db executeUpdate:sql, immsg.chatId, immsg.roomId, immsg.openId, immsg.postAt];
        [db close];
    }
    return worked;
}

+(BOOL)isIMMessageExist:(IMMessage *)immsg
{
    FMDatabase *db = [FMDatabase databaseWithPath:DATABASE_PATH];
    BOOL worked = false;
    if ([db open]) {
        NSString *sql = @"select * from im_msg where room_id=? and openid=? and post_at=?;";
        FMResultSet *rs = [db executeQuery:sql, immsg.roomId, immsg.openId, immsg.postAt];
        worked = rs.next;
        [db close];
    }
    return worked;
}

//本地数据库
+(NSArray *)getConversations
{
    FMDatabase *db = [FMDatabase databaseWithPath:DATABASE_PATH];
    [db open];
    NSString *createStr=@"CREATE TABLE IF NOT EXISTS [im_msg] ([_id] INTEGER NOT NULL  PRIMARY KEY AUTOINCREMENT, [content] NVARCHAR, [openid] NVARCHAR, [room_id] NVARCHAR, [msg_time] TEXT, [msg_type] INTEGER, [msg_status] INTEGER, [media_type] INTEGER, [chat_id] INTEGER, [post_at] TEXT);";
    [db executeUpdate:createStr];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    if ([db open]) {
        NSString *sql ;
        FMResultSet *rs ;
        sql = @"SELECT a.room_id,a.counts,b.content,b.msg_time,max(b.msg_time),b.openid,b.msg_type,b.msg_status,b.chat_id,b.post_at,b.media_type FROM (SELECT	room_id, count(content) as counts FROM `im_msg` WHERE msg_status = 1 GROUP BY room_id order by msg_time) AS a LEFT JOIN (SELECT room_id,* FROM `im_msg` order by msg_time desc) as b on a.room_id = b.room_id group by a.room_id;";
        rs = [db executeQuery:sql];
        while ([rs next]) {
            NSString *content    = [rs stringForColumn:@"content"];
            NSString *openId     = [rs stringForColumn:@"openid"];
            NSString *msg_time   = [rs stringForColumn:@"msg_time"];
            NSString *roomId     = [rs stringForColumn:@"room_id"];
            NSInteger msg_type   = [rs intForColumn:@"msg_type"];
            NSInteger status     = [rs intForColumn:@"msg_status"];
            NSInteger mediaType  = [rs intForColumn:@"media_type"];
            NSInteger chatId     = [rs intForColumn:@"chat_id"];
            NSString *postAt     = [rs stringForColumn:@"post_at"];
            IMMessage *imMessage = [IMMessage initIMMessage:roomId
                                                     openId:openId
                                                    content:content
                                                       time:msg_time
                                                    msgType:msg_type
                                                  msgStatus:status
                                                  mediaType:mediaType
                                                     chatId:chatId
                                                     postAt:postAt];
            imMessage.noticeSum = [rs stringForColumn:@"counts"];
            [array addObject:imMessage];
        }
        [db close];
    }
    NSMutableArray *sortArray = [NSMutableArray array];
    [sortArray addObjectsFromArray:[array sortedArrayUsingSelector:@selector(compare:)]];
    return sortArray;
}
@end
