//
//  HVUserStore.h
//  HVDataMigration
//
//  Created by Harvey Huang on 16/5/5.
//  Copyright © 2016年 Harvey Huang. All rights reserved.
//

#import "HVKeyValueStore.h"

@interface HVUserModel : NSObject

@property (nonatomic, copy) NSString *uId;
@property (nonatomic, copy) NSString *uName;
@property (nonatomic, copy) NSString *uEmail;

@end

static NSString *const HV_TABLE_USER    = @"UserInfo";
static NSString *const HV_TABLE_NEWUSER = @"User_Infos";

typedef void(^CompletionBlock)(NSError *error);

@interface HVUserStore : HVKeyValueStore

+ (instancetype)shareStore;
+ (NSString *)hv_dbPath;


/**
 *  插入用户信息
 *
 *  @param user       用户信息模型
 *  @param completion 放回的error信息
 */
- (void)hv_insertUser:(HVUserModel *)user
           completion:(CompletionBlock)completion;


/**
 *  旧表增加新的字段
 *
 *  @param newFieldName 新字段名
 *  @param tableName    新增字段的表名
 *
 *  @return 结果
 */
- (BOOL)hv_addNewColumn:(NSString *)newFieldName
               toTableName:(NSString *)tableName;



/**
 *  重命表的名称
 *
 *  @param oldTableName 旧表名
 *  @param newTableName 新表名
 *
 *  @return 结果
 */
- (BOOL)hv_renameTableName:(NSString *)oldTableName
            toNewTableName:(NSString *)newTableName;

@end
