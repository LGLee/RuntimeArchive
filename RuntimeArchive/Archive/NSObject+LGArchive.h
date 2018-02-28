//
//  NSObject+LGArchive.h
//  RuntimeArchive
//
//  Created by lingo on 2018/2/28.
//  Copyright © 2018年 livefor. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface NSObject (LGArchive)

/**
 归档

 @param aCoder acoder
 */
- (void)encode:(NSCoder *)aCoder;

/**
 解档

 @param aDecoder acode
 */
- (void)decode:(NSCoder *)aDecoder;
@end
