# RuntimeArchive
使用Runtime技术实现数据的持久化，由浅入深的讲解请看blog：http://blog.csdn.net/applelg/article/details/79403202

#需求:
* 在 iOS 开发中，经常需要对用户的一些数据进行持久化的存储， 用以保证用户杀死 App 后， 在下次启动依然能使用退出前的一些数据。如: 用户登录后杀死 App ，下次进入不需要再次登录
* 归档存储的两个问题：（1）存哪里？（2）怎么存？
#使用技术：
ps：持久化的技术很多，这里只说归档
* 存哪里？ 沙盒
- 沙盒结构如图
![这里写图片描述](http://img.blog.csdn.net/20180228160915696?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvYXBwbGVMZw==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)
# 步骤
1. 遵守NSCoding协议
2. 实现归档、接档方法  (重点在这)
3. 设置归档位置（存哪里）
4. 开始归档、接档
## 第一版

```
//归档
- (void)encodeWithCoder:(NSCoder *)aCoder{
[aCoder encodeObject:self.account forKey:@"accountKey"];
[aCoder encodeObject:self.password forKey:@"passwordKey"];
}
//解档
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder{
if (self = [super init]) {
self.account = [aDecoder decodeObjectForKey:@"accountKey"];
self.password = [aDecoder decodeObjectForKey:@"passwordKey"];
}
return self;
}
```
* 如果这两个方法记不住，先遵守协议，然后command+点击 就能查看具体的协议定义内容，如下图![这里写图片描述](http://img.blog.csdn.net/20180228162014421?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvYXBwbGVMZw==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)
* 这种做法有缺陷： 归档和解档两个方法对同一属性的操作的key容易写错
改一下出第二版
## 第二版
* 改进一下，使用宏定义来代替key

```
#define ACCOUNT_KEY @"accountKey"
#define PASSWORD_KEY @"passwordKey"
```
定义了这两个宏，这样就可以在两个方法中对同一属性保持相同的key， 这样就不会取错了

```
//归档
- (void)encodeWithCoder:(NSCoder *)aCoder{
[aCoder encodeObject:self.account forKey:ACCOUNT_KEY];
[aCoder encodeObject:self.password forKey:PASSWORD_KEY];
}
//解档
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder{
if (self = [super init]) {
self.account = [aDecoder decodeObjectForKey:ACCOUNT_KEY];
self.password = [aDecoder decodeObjectForKey:PASSWORD_KEY];
}
return self;
}

```
* 这里的宏业可以用静态常量字符串代替
![这里写图片描述](http://img.blog.csdn.net/20180228163014475?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvYXBwbGVMZw==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)
* 这样做的缺陷：如果有100个属性怎么办？那就需要100个宏，写100次归档和解档，这样工作量还是很大的。 所以下面我们引入运行时机制
## 第三版

```
//归档
- (void)encodeWithCoder:(NSCoder *)aCoder{
unsigned int outCount = 0;
Ivar *ivars = class_copyIvarList([self class], &outCount);
for (int i = 0; i< outCount; i++) {
Ivar ivar = ivars[i];
const char *ivarName = ivar_getName(ivar);
//获取到时是带有下划线的成员变量名
NSString *ocStr = [NSString stringWithCString:ivarName encoding:NSUTF8StringEncoding];
//根据kvc的获取规则，即使是属性名和成员变量名不一致，也是可以获取到的，如：name 和 _name
id value = [self valueForKey:ocStr];
[aCoder encodeObject:value forKey:ocStr];
NSLog(@"%@",ocStr);
}
free(ivars);
}
//解档
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder{
if (self = [super init]) {
unsigned int count = 0;
Ivar *ivars = class_copyIvarList([self class],&count);
for (int i = 0; i < count; i++) {
Ivar ivar = ivars[i];
const char *ivarName = ivar_getName(ivar);
NSString *ocStr = [NSString stringWithCString:ivarName encoding:NSUTF8StringEncoding];
id obj = [aDecoder decodeObjectForKey:ocStr];
[self setValue:obj forKey:ocStr];
}
free(ivars);
}
return self;
}

```
* KVC 中  setValue:forKey的搜索方式（name为例）：
<font color = red>1. setName: 2. _name  3._isName 4.name 5. isName   6. setValue：forUNdefinedKey:</font>
* KVC 中 valueForKey:的搜索方式（name为例）:
<font color = red>1. getName: 2. _name  3._isName 4.name 5. isName 6. valueForUndefinedKey:</font>
* 这种做法也有缺陷：如果有不同的类需要归档呢，就得写很多遍相同的代码。我们可以把它抽出来变成版本四

## 第四版

```
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
```
### 版本四的使用
* 以后使用只需要加入这两行代码就可以了
```
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
}
```
* 版本四还不是最简版本，我们可以把这段代码定义为一个宏，这样一句代码就可以搞定归档和解档
#第五版

```
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
```
### 版本五使用

```
//一句代码
LGArchiveImplementation
```
# 总结：
* 版本五最简单方便
* 代码地址：https://github.com/LGLee/RuntimeArchive.git
* blog地址：http://blog.csdn.net/applelg/article/details/79403202

