//
//  HVKeyValueStore.h
//  Test_DataMigration
//
//  Created by Harvey Huang on 14-11-11.
//  Copyright (c) 2014年 haifashion. All rights reserved.
//

#import <Foundation/Foundation.h>
//@class FMDatabase,FMDatabaseQueue;
#import <FMDatabase.h>
#import <FMDatabaseQueue.h>



#ifdef DEBUG
#define debugLog(...)   NSLog(__VA_ARGS__)
#define debugMethod()   NSLog(@"%s", __func__)
#define debugError()    NSLog(@"Error at %s Line:%d", __func__, __LINE__);
#else
#define debugLog(...)
#define debugMethod()
#define debugError()
#endif


#define PATH_OF_DOCUMENT  [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]

@interface HVKeyValueItem : NSObject

@property (strong , nonatomic) NSString *itemId;
@property (strong , nonatomic) id itemObject;
@property (strong , nonatomic) NSDate *createdTime;

@end

@interface HVKeyValueStore : NSObject

@property (strong, nonatomic, readonly) FMDatabaseQueue *dbQueue;

+ (BOOL)checkTableName:(NSString *)tableName;

- (id)initDBWithName:(NSString *)dbName;

- (id)initWithDBWithPath:(NSString *)dbPath;

- (void)createTableWithName:(NSString *)tableName;

- (BOOL)createTable:(NSString *)SQLStr byTableName:(NSString *)tableName;

- (void)clearTable:(NSString *)tableName;

- (void)close;


@end
