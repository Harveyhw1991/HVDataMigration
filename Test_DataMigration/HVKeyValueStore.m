//
//  HVKeyValueStore.m
//  Test_DataMigration
//
//  Created by Harvey Huang on 14-11-11.
//  Copyright (c) 2014年 haifashion. All rights reserved.
//

#import "HVKeyValueStore.h"

@implementation HVKeyValueItem

- (NSString *)description
{
    return [NSString stringWithFormat:@"id=%@, value=%@,timeStamp=%@",_itemId,_itemObject,_createdTime];
}

@end


@interface HVKeyValueStore ()


@end


@implementation HVKeyValueStore

static NSString *const DEFAULT_DB_NAME = @"database.sqlite";

static NSString *const CREATE_TABLE_SQL =
@"CREATE TABLE IF NOT EXISTS %@ ( \
id TEXT NOT NULL, \
json TEXT NOT NULL, \
createdTime TEXT NOT NULL, \
PRIMARY KEY(id)) \
";

static NSString *const UPDATE_ITEM_SQL = @"REPLACE INTO %@ (id,json,createdTime) value (?,?,?)";

static NSString *const QUERY_ITEM_SQL = @"SELECT json, createdTime from %@ where id = ? Limit 1";

static NSString *const SELECT_ALL_SQL = @"SELECT * from %@";

static NSString *const CLEAR_ALL_SQL  = @"DELETE from %@";

static NSString *const DELETE_ITEM_SQL  = @"DELETE from %@ where id = ?";

static NSString *const DELETE_ITEMS_SQL = @"DELETE from %@ where id in ( %@ )";

static NSString *const DELETE_ITEMS_WITH_PREFIX_SQL = @"DELETE from %@ where id like ? ";

+ (BOOL)checkTableName:(NSString *)tableName
{
    if (tableName == nil || tableName.length == 0 || [tableName rangeOfString:@" "].location != NSNotFound) {
        
        debugLog(@"Error, table name: %@ format error.",tableName);
        return NO;
    }
    return YES;
}


- (id)init
{
    return [self initDBWithName:DEFAULT_DB_NAME];
}

- (id)initDBWithName:(NSString *)dbName
{
    self = [super init];
    
    if (self) {
        NSString *dbPath = [PATH_OF_DOCUMENT stringByAppendingPathComponent:dbName];
        debugLog(@"dbpath = %@",dbPath);
        
        if (_dbQueue) {
            [self close];
        }
        
        _dbQueue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
    }
    
    return self;
}

- (id)initWithDBWithPath:(NSString *)dbPath
{
    self = [super init];
    
    if (self) {
        
        debugLog(@"dbPath = %@",dbPath);
        
        if (_dbQueue) {
            [self close];
        }
        
        _dbQueue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
    }
    
    return self;
}

- (void)createTableWithName:(NSString *)tableName
{
    if (![HVKeyValueStore checkTableName:tableName]) {
        return;
    }
    NSString *sql = [NSString stringWithFormat:CREATE_TABLE_SQL,tableName];
    
    __block BOOL result;
    [_dbQueue inDatabase:^(FMDatabase *db) {
       
        result = [db executeUpdate:sql];
        
    }];
    
    if (!result) {
        debugLog(@" >> Error , failed to create table: %@",tableName);
    }
}

- (BOOL)createTable:(NSString *)SQLStr byTableName:(NSString *)tableName {
    
    if ([HVKeyValueStore checkTableName:tableName] == NO) {
        return NO;
    }
    
    NSString * sql = [NSString stringWithFormat:SQLStr, tableName];
    __block BOOL result;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        
        result = [db executeUpdate:sql];
        
    }];
    if (!result) {
        
        debugLog(@">>> ERROR, failed to create table: %@", tableName);
    }
    
    return result;
}



- (void)clearTable:(NSString *)tableName
{
    if (![HVKeyValueStore checkTableName:tableName]) {
        return;
    }
    NSString *sql = [NSString stringWithFormat:CLEAR_ALL_SQL,tableName];
    
    __block BOOL result;
    
    [_dbQueue inDatabase:^(FMDatabase *db) {
       
        result = [db executeUpdate:sql];
    }];
    if (!result) {
        debugLog(@" >> Error , failed to clear table :%@",tableName);
    }
}



- (void)close
{
    [_dbQueue close];
    _dbQueue = nil;
}

@end
