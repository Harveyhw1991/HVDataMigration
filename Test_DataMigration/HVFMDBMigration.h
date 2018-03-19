//
//  HVFMDBMigration.h
//  Test_DataMigration
//
//  Created by Harvey Huang on 2018/3/19.
//  Copyright © 2018年 Harvey Huang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDBMigrationManager.h>

@interface HVFMDBMigration : NSObject<FMDBMigrating>
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) uint64_t version;

+ (instancetype)migrationWithName:(NSString *)name
                          verison:(uint64_t )version
                   executeUpdates:(NSArray *)updateArr;

- (BOOL)migrateDatabase:(FMDatabase *)database error:(out NSError *__autoreleasing *)error;

@end
