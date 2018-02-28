//
//  NSObject+LGArchive.m
//  RuntimeArchive
//
//  Created by lingo on 2018/2/28.
//  Copyright © 2018年 livefor. All rights reserved.
//

#import "NSObject+LGArchive.h"
#import <objc/runtime.h>
@implementation NSObject (LGArchive)
- (void)encode:(NSCoder *)aCoder{
    Class clazz = self.class;
    //如果有继承关系的情况，并且父类不是NSObject
    while (clazz && clazz != [NSObject class]) {
        unsigned int outCount = 0;
        Ivar *ivars = class_copyIvarList(clazz, &outCount);
        for (int i = 0; i < outCount; i++) {
            Ivar ivar = ivars[i];
            const char *ivarName = ivar_getName(ivar);
            //获取到时是带有下划线的成员变量名
            NSString *ocStr = [NSString stringWithCString:ivarName encoding:NSUTF8StringEncoding];
            //根据kvc的获取规则，即使是属性名和成员变量名不一致，也是可以获取到的，如：name 和 _name
            id value = [self valueForKey:ocStr];
            [aCoder encodeObject:value forKey:ocStr];
        }
        free(ivars);
        clazz = [clazz superclass];
    }
}

- (void)decode:(NSCoder *)aDecoder {
    Class clazz = self.class;
    while (clazz && clazz != [NSObject class]) {
        unsigned int outCount = 0;
        Ivar *ivars = class_copyIvarList(clazz, &outCount);
        for (int i = 0; i < outCount; i++) {
            Ivar ivar = ivars[i];
            const char *ivarName = ivar_getName(ivar);
            NSString *ocStr = [NSString stringWithCString:ivarName encoding:NSUTF8StringEncoding];
            id obj = [aDecoder decodeObjectForKey:ocStr];
            [self setValue:obj forKey:ocStr];
        }
        free(ivars);
        clazz = [clazz superclass];
    }
}  
@end
