//
//  Student+CoreDataProperties.h
//  HVDataMigration
//
//  Created by Harvey Huang on 2018/3/20.
//  Copyright © 2018年 Harvey Huang. All rights reserved.
//
//

#import "Student+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Student (CoreDataProperties)

+ (NSFetchRequest<Student *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *sName;
@property (nonatomic) int64_t sAge;
@property (nonatomic) int16_t sNumber;
@property (nullable, nonatomic, copy) NSString *aSex;
@property (nonatomic) int16_t aHeight;
@property (nullable, nonatomic, copy) NSString *sID;

@end

NS_ASSUME_NONNULL_END
