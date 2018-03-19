//
//  HVFMDBMigration.m
//  Test_DataMigration
//
//  Created by Harvey Huang on 2018/3/19.
//  Copyright © 2018年 Harvey Huang. All rights reserved.
//

#import "HVFMDBMigration.h"

@interface HVFMDBMigration ()
@property (nonatomic,copy) NSString *name;
@property (nonatomic,assign) uint64_t version;
@property (nonatomic,copy) NSArray *updatesArr;
@end

@implementation HVFMDBMigration

+ (instancetype)migrationWithName:(NSString *)name
                          verison:(uint64_t)version
                   executeUpdates:(NSArray *)updateArr
{
    HVFMDBMigration *dbMigration = [[HVFMDBMigration alloc]initWithName:name
                                                                verison:version
                                                         executeUpdates:updateArr];
    
    return dbMigration;
}

- (instancetype)initWithName:(NSString *)name
                     verison:(uint64_t)version
              executeUpdates:(NSArray *)updateArr
{
    self = [super init];
    if (self) {
        _name = name;
        _version = version;
        _updatesArr = updateArr;
    }
    return self;
}


- (BOOL)migrateDatabase:(FMDatabase *)database error:(out NSError *__autoreleasing *)error
{
    for (NSString *sqlStr in _updatesArr) {
        
        [database executeUpdate:sqlStr];
    }
    return YES;
}

@end
