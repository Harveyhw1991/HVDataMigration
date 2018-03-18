//
//  ViewController.m
//  Test_DataMigration
//
//  Created by Harvey Huang on 16/5/5.
//  Copyright © 2016年 Harvey Huang. All rights reserved.
//

#import "ViewController.h"
#import "HVUserStore.h"
#import <FMDBMigrationManager.h>


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    /*
     数据库的迁移无非是：
     
     1.新增数据库（没有路径的情况）
     
     2.新增表
     
     3.增加字段
     
     4.删除字段（sqlit3不支持字段的删除）
     
     */
    
    

    HVUserStore *userStore = [HVUserStore shareStore];
    
    //**** 1. sqlite 插入模拟数据 *****
    
    for (NSInteger i = 0; i < 6; i ++) {
        
        HVUserModel *user = [[HVUserModel alloc]init];
        
        user.uId    = [NSString stringWithFormat:@"800%ld",(long)i];
        user.uName  = [NSString stringWithFormat:@"程序猿111_%ld",(long)i];
        //user.uEmail = [NSString stringWithFormat:@"hhhh_%ld@163.com",(long)i];
    
        [userStore hv_insertUser:user  completion:^(NSError *error) {
           
            if (!error) {
                NSLog(@">>> inser user success <<<");
            }
        }];
    }
    

//    /****  2.sqlite 增加新的字段,重命名表 ****/
//     
//    // 1).旧表增加新的字段
//    
//    // ALTER TABLE 表名 ADD 字段名 字段类型;
//    
//    [userStore hv_addNewColumn:@"uEmail" toTableName:HV_TABLE_USER];
//    
//    [userStore hv_addNewColumn:@"uRemark" toTableName:HV_TABLE_USER];
//    
//    
//    // 2).重命名表
//    
//    // ALTER TABLE 表名 RENAME TO 新表名;
//    
//    [userStore hv_renameTableName:HV_TABLE_USER toNewTableName:HV_TABLE_NEWUSER];
    
 
    
#pragma mark - sqlite 在数据迁移中的局限
    
    /*
     
     SQLite supports a limited subset of ALTER TABLE. The ALTER TABLE command in SQLite allows the user to rename a table or to add a new column to an existing table. It is not possible to rename a column, remove a column, or add or remove constraints from a table.
     
     SQLite 中的 ALERT TABLE 命令
     
     * 只能允许用户重命名表，或者添加新的字段到已有的表中，
     * 不能重命名字段，或者删除字段，或者删除约束。
     * 并且只能在表的末尾添加
     
     */
    

#pragma mark - 使用FMDBMigrationManager 进行数据库迁移
    
//    FMDBMigrationManager *dbManager = [FMDBMigrationManager managerWithDatabaseAtPath:PATH_OF_DOCUMENT migrationsBundle:[NSBundle mainBundle]];
//
//    BOOL resultState = NO;
//    NSError *error = nil;
//    if (!dbManager.hasMigrationsTable) {
//        resultState = [dbManager createMigrationsTable:&error];
//        debugLog(@">>> resultState %d",resultState);
//    }
//
//    resultState = [dbManager migrateDatabaseToVersion:UINT64_MAX progress:nil error:&error];
//
//    debugLog(@"Has `schema_migrations` table?: %@", dbManager.hasMigrationsTable ? @"YES" : @"NO");
//    debugLog(@"Origin Version: %llu", dbManager.originVersion);
//    debugLog(@"Current version: %llu", dbManager.currentVersion);
//    debugLog(@"All migrations: %@", dbManager.migrations);
//    debugLog(@"Applied versions: %@", dbManager.appliedVersions);
//    debugLog(@"Pending versions: %@", dbManager.pendingVersions);
    

    
    
#pragma mark - Coredata 在数据迁移中的简单和灵活性
    
     /*** coredata 数据库迁移 *****/
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
