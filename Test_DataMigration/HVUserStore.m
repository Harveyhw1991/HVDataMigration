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

@interface HVUserStore ()

@property (nonatomic, strong) FMDatabase *db;
@property (nonatomic, assign) NSInteger dbVersion;
@end



static NSString *const HV_DB_NAME = @"HV_DB.sqlite";
static NSInteger const HV_DB_DEFAULT_VERSION = 1000;
static NSInteger const HV_DB_CURRENT_VERSION = 4000;

static NSString *const CREATE_DB_INFO_SQL =
@"CREATE TABLE IF NOT EXISTS %@ ( \
version INTERGER NOT NULL, \
PRIMARY KEY(version)) \
";
static NSString *const REPLACE_DBVERSON_SQL  = @"REPLACE INTO %@ VALUES(%ld)";
static NSString *const SELECT_ALL_SQL = @"SELECT * from %@";


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
        
        if (![HVUserStore hv_checkDB])
        {
            userStore = [[HVUserStore alloc]initDBWithName:HV_DB_NAME];
            [userStore createTableWithName:HV_TABLE_INFO bySQL:CREATE_DB_INFO_SQL];
            [userStore createTableWithName:HV_TABLE_USER bySQL:CREATE_USER_TABLE_SQL];
        }else
        {
            userStore = [[HVUserStore alloc]initDBWithName:HV_DB_NAME];
        }
        [userStore hv_addDBVersion:HV_DB_DEFAULT_VERSION completion:nil];
        [userStore hv_updateDBVerson];
    });
    
    return userStore;
}


#pragma mark - private method

+ (NSString *)hv_dbPath
{
    NSString *dbPath = [PATH_OF_DOCUMENT stringByAppendingPathComponent:HV_DB_NAME];
    return dbPath;
}

+ (BOOL)hv_checkDB
{
    NSString *filePath = [HVUserStore hv_dbPath];
    BOOL result = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    return result;
}


- (NSInteger)dbVersion
{
    if (_dbVersion <=0) {
        _dbVersion = [self hv_fetchDBVersion];
        return _dbVersion;
    }
    return _dbVersion;
}

- (NSInteger)hv_fetchDBVersion
{
    __block NSInteger version = 0;
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        
        NSString *sql = [NSString stringWithFormat:SELECT_ALL_SQL,HV_TABLE_INFO];
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {
            version = [rs intForColumn:@"version"];
            NSLog(@">>>>>>>");
        }
        [rs close];
        
        if (version <= 0) {
            version = HV_DB_DEFAULT_VERSION;
        }
    }];
    
    return version;
}

- (void)hv_addDBVersion:(NSInteger)version
             completion:(CompletionBlock)completion
{
    if (version <=0) {
        return;
        debugLog(@">>> Please enter the right version.");
    }
    
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        
        NSString *sql = [NSString stringWithFormat:REPLACE_DBVERSON_SQL,HV_TABLE_INFO,version];
    
        BOOL result   = [db executeUpdate:sql];
        if (!result) {
            debugLog(@">>> db[%@] add vesion faild.",HV_TABLE_INFO);
        }
    }];
}

- (void)hv_updateDBVerson
{
    debugLog(@">>>>>11 %ld",self.dbVersion);
    self.dbVersion = [self hv_fetchDBVersion];
    
    debugLog(@">>>>>22 %ld",self.dbVersion);
    if (self.dbVersion != HV_DB_CURRENT_VERSION) {
        
        // 1).旧表增加新的字段
        
        // ALTER TABLE 表名 ADD 字段名 字段类型;
        
        [self hv_addNewColumn:@"uEmail" toTableName:HV_TABLE_USER];
        
        [self hv_addNewColumn:@"uRemark" toTableName:HV_TABLE_USER];
        
        
        // 2).重命名表
        
//        // ALTER TABLE 表名 RENAME TO 新表名;
//        [self hv_renameTableName:HV_TABLE_USER toNewTableName:HV_TABLE_NEWUSER];
//
//
        // 更新数据库的最新版本号
        [self hv_addDBVersion:HV_DB_CURRENT_VERSION completion:nil];
    }
}

- (void)createTableWithName:(NSString *)tableName
                      bySQL:(NSString *)sqlStr
{
    if (![HVKeyValueStore checkTableName:tableName]) {
        return;
    }
    
    NSString *sql = [NSString stringWithFormat:sqlStr,tableName];
    
    __block BOOL result;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        if (![db tableExists:tableName]) {
            result = [db executeUpdate:sql];
        }
    }];
    
    if (!result) {
        debugLog(@">>> Error , failed to create table: %@",tableName);
    }else {
        debugLog(@">>> DB:[%@] is ready",tableName);
    }
}





#pragma mark - public method

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
- (BOOL)hv_addNewColumn:(NSString *)newColumnName
            toTableName:(NSString *)tableName
{
    if (![HVKeyValueStore checkTableName:tableName]) {
        return NO;
    }
    
    __block BOOL result;
    NSString *sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN %@ TEXT",tableName,newColumnName];
    
    NSLog(@">>> add sql :%@",sql);
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
       
        //判断字段是否存在
        if (![db columnExists:newColumnName inTableWithName:tableName]) {
            
            result = [db executeUpdate:sql];
            
            if (!result) {
                NSLog(@">>> Error: add new Column faild <<<");
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
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        if (![db tableExists:newTableName]) {
            result = [db executeUpdate:sql];
            
            if (!result) {
                NSLog(@">>> Error: rename TableName <<<");
            }
        }
    }];
    
    return result;
}

@end
