//
//  NSObject+ZORNCoreDataStackAdditions.m
//  Bonsai
//
//  Created by Michael Zornek on 12/22/13.
//  Copyright (c) 2013 Michael Zornek. All rights reserved.
//

#import "NSObject+ZORNCoreDataStackAdditions.h"
#import <CoreData/CoreData.h>

@implementation NSObject (ZORNCoreDataStackAdditions)

+ (BOOL)zorncds_isCoreDataInstanceClass
{
    return (self == [NSManagedObject class] || [self isSubclassOfClass:[NSManagedObject class]]);
}

@end
