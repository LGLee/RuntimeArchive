//
//  UserAccount.h
//  RuntimeArchive
//
//  Created by lingo on 2018/2/28.
//  Copyright © 2018年 livefor. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserAccount : NSObject<NSCoding>
/** <#copy注释#> */
@property (nonatomic ,copy) NSString *account;
/** <#copy注释#> */
@property (nonatomic ,copy) NSString *password;
/** <#copy注释#> */
@property (nonatomic ,copy) NSString *nickName;


+ (instancetype)instance;

- (BOOL)save;

- (instancetype)user;
@end
