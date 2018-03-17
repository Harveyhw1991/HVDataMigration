//
//  ViewController.m
//  Test_DataMigration
//
//  Created by Harvey Huang on 16/5/5.
//  Copyright © 2016年 Harvey Huang. All rights reserved.
//

#import "ViewController.h"
#import "HVUserStore.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    

    HVUserStore *userStore = [HVUserStore shareStore];
    
    [userStore createTableWithName:HV_TABLE_USER];
    
    
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
    

    /****  2.sqlite 增加新的字段,重命名表 ****/
     
    
    // 1).旧表增加新的字段
    
    // ALTER TABLE 表名 ADD 字段名  字段类型;
    
    [userStore hv_addNewFieldName:@"uEmail" toTableName:HV_TABLE_USER];
    
    [userStore hv_addNewFieldName:@"uRemark" toTableName:HV_TABLE_USER];
    
    
    // 2).重命名表
    
    // ALTER TABLE 表名 RENAME TO 新表名;
    
    [userStore hv_renameTableName:HV_TABLE_USER toNewTableName:HV_TABLE_NEWUSER];
    
 
    
#pragma mark - sqlite 在数据迁移中的局限
    
    /*
     
     SQLite supports a limited subset of ALTER TABLE. The ALTER TABLE command in SQLite allows the user to rename a table or to add a new column to an existing table. It is not possible to rename a column, remove a column, or add or remove constraints from a table.
     
     SQLite 中的 ALERT TABLE 命令
     
     * 只能允许用户重命名表，或者添加新的字段到已有的表中，
     * 不能重命名字段，或者删除字段，或者删除约束。
     * 并且只能在表的末尾添加
     
     */
    
    

    
    
#pragma mark - Coredata 在数据迁移中的简单和灵活性
    
     /*** coredata 数据库迁移 *****/
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
