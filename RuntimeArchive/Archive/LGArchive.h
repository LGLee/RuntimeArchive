//
//  LGArchive.h
//  RuntimeArchive
//
//  Created by lingo on 2018/2/28.
//  Copyright © 2018年 livefor. All rights reserved.
//

#ifndef LGArchive_h
#define LGArchive_h
#import "NSObject+LGArchive.h"

#define LGArchiveImplementation \
- (instancetype)initWithCoder:(NSCoder *)aDecoder {\
    if (self = [super init]) {\
        [self decode:aDecoder];\
    }\
    return self;\
}\
\
- (void)encodeWithCoder:(NSCoder *)aCoder {\
    [self encode:aCoder];\
}

#endif /* LGArchive_h */
