//
//  HVUserStore.m
//  Test_DataMigration
//
//  Created by Harvey Huang on 16/5/5.
//  Copyright © 2016年 Harvey Huang. All rights reserved.
//

#import "HVUserStore.h"
#import <FMDatabaseAdditions.h>


#pragma mark - userModel

@implementation HVUserModel


- (NSString *)description
{
    return nil;
    //return [NSString stringWithFormat:<#(nonnull NSString *), ...#>]
}

@end



static NSString *const HV_DB_NAME = @"HV_DB.sqlite";

static NSString *const CREATE_USER_TABLE_SQL =
@"CREATE TABLE IF NOT EXISTS %@ ( \
uId    TEXT NOT NULL, \
uName  TEXT NOT NULL, \
PRIMARY KEY(uId)) \
";

static NSString *const REPLACE_USER_SQL = @"REPLACE INTO %@ VALUES(?,?)";


#pragma mark - userStore

@implementation HVUserStore

+ (instancetype)shareStore
{
    static HVUserStore *userStore = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        userStore = [[HVUserStore alloc]initDBWithName:HV_DB_NAME];
        
    });
    
    return userStore;
}


- (void)createTableWithName:(NSString *)tableName
{
    if (![HVKeyValueStore checkTableName:tableName]) {
        return;
    }
    
    NSString *sql = [NSString stringWithFormat:CREATE_USER_TABLE_SQL,tableName];
    
    __block BOOL result;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        result = [db executeUpdate:sql];
        
    }];
    
    if (!result) {
        debugLog(@" >> Error , failed to create table: %@",tableName);
    }
}



/**
 *  插入用户信息
 *
 *  @param user       用户信息模型
 *  @param completion 放回的error信息
 */
- (void)hv_insertUser:(HVUserModel *)user
           completion:(CompletionBlock)completion
{
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        [db beginTransaction];
        __block BOOL isRollBack = NO;
        
        @try {
            
            NSString *sql = [NSString stringWithFormat:REPLACE_USER_SQL,HV_TABLE_USER];
            
            BOOL result = [db executeUpdate:sql,user.uId,user.uName];
            
            if (!result)
            {
                isRollBack = YES;
                debugLog(@">>> Error insert to db failure <<<");
            }
            
        }
        @catch (NSException *exception) {
            [db rollback];
        }
        @finally {
            if (isRollBack)
            {
                [db rollback];
                
                NSError* error = [NSError errorWithDomain:@"插入用户信息失败" code:0 userInfo:nil];
                
                if (completion) {
                    completion(error);
                }
            }
            else
            {
                [db commit];
                if (completion) {
                    completion(nil);
                }
            }
        }
        
    }];
}



/**
 *  旧表增加新的字段
 *
 *  @param newFieldName 新字段名
 *  @param tableName    新增字段的表名
 *
 *  @return 结果
 */
- (BOOL)hv_addNewFieldName:(NSString *)newFieldName
               toTableName:(NSString *)tableName
{
    if (![HVKeyValueStore checkTableName:tableName]) {
        return NO;
    }
    
    __block BOOL result;
    NSString *sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN %@ TEXT",tableName,newFieldName];
    
    NSLog(@">>> add sql :%@",sql);
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
       
        //判断字段是否存在
        if (![db columnExists:newFieldName inTableWithName:tableName]) {
            
            result = [db executeUpdate:sql];
            
            if (!result) {
                NSLog(@">>> Error: add new field faild <<<");
            }
            
        }
    }];
    
    return result;
}


/**
 *  重命名表
 *
 *  @param oldTableName 旧表名
 *  @param newTableName 新表名
 *
 *  @return 结果
 */
- (BOOL)hv_renameTableName:(NSString *)oldTableName
            toNewTableName:(NSString *)newTableName
{
    if (![HVKeyValueStore checkTableName:oldTableName] ||
        ![HVKeyValueStore checkTableName:newTableName]) {
        return NO;
    }
    
    __block BOOL result;
    NSString *sql = [NSString stringWithFormat:@"ALTER TABLE %@ RENAME TO %@",oldTableName,newTableName];
    
    NSLog(@">>> rename sql :%@",sql);
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        result = [db executeUpdate:sql];
        
        if (!result) {
            NSLog(@">>> Error: rename TableName <<<");
        }
        
    }];
    
    return result;
    
}

@end
