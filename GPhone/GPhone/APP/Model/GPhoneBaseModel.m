//
//  GPhoneBaseModel.m
//  GPhone
//
//  Created by 郁兵生 on 2017/12/21.
//  Copyright © 2017年 郁兵生. All rights reserved.
//

#import "GPhoneBaseModel.h"
#import <objc/runtime.h>

@implementation GPhoneBaseModel
- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    NSLog(@"new key found ********* %@",key);
}
+ (id)instancefromJsonDic:(NSDictionary*)dic
{
    id instance = nil;
    @try {
        instance = [[self alloc] init];
        NSArray *keys = [dic allKeys];
        for (NSString *key in keys) {
            id item = [dic objectForKey:key];
            //            NSLog(@"class = %@",[item class]);
            if ([item isMemberOfClass:[NSNull class]]) {
                continue;
            } else if ([item isKindOfClass:[NSDictionary class]]) {
                //add another C instance
            } else if ([item isKindOfClass:[NSArray class]]) {
                //add a C instances array
            } else if ([item isKindOfClass:[NSNumber class]]){
                
                //                [instance setValue:[NSNumber numberWithInt:(int)item] forKey:key];
                [instance setValue:[item stringValue] forKey:key];
            } else {
                
                [instance setValue:[item stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:key];
            }
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Drat! Something wrong: %@", exception.reason);
    }
    return instance;
}

+ (NSArray *)instancesFromJsonArray:(NSArray *)array
{
    if (![array isKindOfClass:[NSArray class]]) {
        return [NSArray array];
    }
    NSMutableArray *instances = [NSMutableArray array];
    for (NSDictionary *dic in array) {
        id o = [self instancefromJsonDic:dic];
        if (o) {
            [instances addObject:o];
        }
    }
    return [NSArray arrayWithArray:instances];
}

#pragma - NSCoding

- (void)encodeIvarOfClass:(Class)class withCoder:(NSCoder *)coder
{
    //NSLog(@"encodeIvarOfClass %@", NSStringFromClass(class));
    unsigned int numIvars = 0;
    Ivar *ivars = class_copyIvarList(class, &numIvars);
    for (int i = 0; i < numIvars; i++) {
        Ivar thisIvar = ivars[i];
        NSString * key = [NSString stringWithUTF8String:ivar_getName(thisIvar)];
        id value = [self valueForKey:key];
        if ([key hasPrefix:@"parent"]) {
            [coder encodeConditionalObject:value forKey:key];
        } else {
            [coder encodeObject:value forKey:key];
        }
        //NSLog(@"var name: %@\n", key);
    }
    if (ivars != NULL) { free(ivars); }
}


- (void)continueEncodeIvarOfClass:(Class)class withCoder:(NSCoder *)coder
{
    if (class_respondsToSelector(class, @selector(encodeWithCoder:))) {
        [self encodeIvarOfClass:class withCoder:coder];
        [self continueEncodeIvarOfClass:class_getSuperclass(class) withCoder:coder];
    }
}

- (void)encodeWithCoder:(NSCoder *)coder {
    @autoreleasepool {
        [self continueEncodeIvarOfClass:[self class] withCoder:coder];
        
    }
}

- (void)decodeIvarOfClass:(Class)class withCoder:(NSCoder *)coder
{
    //NSLog(@"decodeIvarOfClass %@", NSStringFromClass(class));
    unsigned int numIvars = 0;
    Ivar * ivars = class_copyIvarList(class, &numIvars);
    for(int i = 0; i < numIvars; i++) {
        Ivar thisIvar = ivars[i];
        NSString * key = [NSString stringWithUTF8String:ivar_getName(thisIvar)];
        id value = [coder decodeObjectForKey:key];
        [self setValue:value forKey:key];
        //NSLog(@"var name: %@\n", key);
    }
    if (ivars != NULL) { free(ivars); }
}

- (void)continueDecodeIvarOfClass:(Class)class withCoder:(NSCoder *)coder
{
    if (class_respondsToSelector(class, @selector(initWithCoder:))) {
        [self decodeIvarOfClass:class withCoder:coder];
        [self continueDecodeIvarOfClass:class_getSuperclass(class) withCoder:coder];
    }
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self == nil) {
        return nil;
    }
    @autoreleasepool {
        [self continueDecodeIvarOfClass:[self class] withCoder:coder];
    }
    return self;
}

@end
