//
//  Student+CoreDataProperties.m
//  HVDataMigration
//
//  Created by Harvey Huang on 2018/3/20.
//  Copyright © 2018年 Harvey Huang. All rights reserved.
//
//

#import "Student+CoreDataProperties.h"

@implementation Student (CoreDataProperties)

+ (NSFetchRequest<Student *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Student"];
}

@dynamic sName;
@dynamic sAge;
@dynamic sNumber;
@dynamic aSex;
@dynamic aHeight;
@dynamic sID;

@end
