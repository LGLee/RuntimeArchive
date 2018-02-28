//
//  UserAccount.m
//  RuntimeArchive
//
//  Created by lingo on 2018/2/28.
//  Copyright © 2018年 livefor. All rights reserved.
//

#import "UserAccount.h"
//#import <objc/runtime.h>
//#import "NSObject+LGArchive.h"
#import "LGArchive.h"
#define ACCOUNT_KEY @"accountKey"
//#define PASSWORD_KEY @"passwordKey"
static NSString *const PASSWORD_KEY = @"passwordKey";

@interface UserAccount()
/** <#copy注释#> */
@property (nonatomic ,copy) NSString *path;

@end

@implementation UserAccount
+ (instancetype)instance{
    static UserAccount *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

/**
 获取文件路径

 @return <#return value description#>
 */
- (NSString *)path{
    if (!_path) {
        NSString *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES).firstObject;
        _path = [docPath stringByAppendingPathComponent:@"user.data"];
    }
    return _path;
}

- (BOOL)save{
    return [NSKeyedArchiver archiveRootObject:self toFile:self.path];
}
- (instancetype)user{
    return [NSKeyedUnarchiver unarchiveObjectWithFile:self.path];
}

//↑ ↑ ↑ ↑ ↑上面代码依据项目情况而定↑ ↑ ↑ ↑ ↑

#pragma mark - 版本一、版本二、版本三
/*
//归档
- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.account forKey:ACCOUNT_KEY];
    [aCoder encodeObject:self.password forKey:PASSWORD_KEY];
    [aCoder encodeObject:self.nickName forKey:@"nickNameKey"];

}
//解档
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]) {
        self.account = [aDecoder decodeObjectForKey:ACCOUNT_KEY];
        self.password = [aDecoder decodeObjectForKey:PASSWORD_KEY];
        self.nickName = [aDecoder decodeObjectForKey:@"nickNameKey"];
    }
    return self;
}
*/

#pragma mark - 版本四
/*
//归档
- (void)encodeWithCoder:(NSCoder *)aCoder{
    [self encode:aCoder];
}
//解档
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]) {
        [self decode:aDecoder];
    }
    return self;
}*/

#pragma mark - 版本五
//一句代码就行
LGArchiveImplementation


@end
