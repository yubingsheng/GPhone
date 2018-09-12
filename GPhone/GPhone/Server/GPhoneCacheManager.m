//
//  GPhoneCacheManager.m
//  GPhone
//
//  Created by 郁兵生 on 2017/12/21.
//  Copyright © 2017年 郁兵生. All rights reserved.
//

#import "GPhoneCacheManager.h"

@implementation GPhoneCacheManager

+(id)sharedManager{
    static GPhoneCacheManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[super allocWithZone:NULL] init];
    });
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone{
    return [self sharedManager];
}

- (id)copyWithZone:(NSZone *)zone{
    return self;
}

- (id)init{
    self = [super init];
    if (self) {
    }
    return self;
}
- (void)clearAllUserDefaultsData {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *dic = [userDefaults dictionaryRepresentation];
    for (id  key in dic) {
        [userDefaults removeObjectForKey:key];
    }
    [userDefaults synchronize];
}

- (id)restoreWithkey:(NSString *)key{
    return [[NSUserDefaults standardUserDefaults] valueForKey:key];
}

- (void)store:(id)object withKey:(NSString *)key{
    [[NSUserDefaults standardUserDefaults] setObject:object forKey:key];
}

- (void)cleanWithKey:(NSString *)key{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
}
#pragma makr - 解档归档

- (NSString *)archiveCacheFolderPath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsPath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    NSString *dirToCreate = [NSString stringWithFormat:@"%@/archiveCache", docsPath];
    NSFileManager *fm= [NSFileManager defaultManager];
    NSError *error = nil;
    BOOL isDir = YES;
    if(![fm fileExistsAtPath:dirToCreate isDirectory:&isDir]) {
        if(![fm createDirectoryAtPath:dirToCreate withIntermediateDirectories:YES attributes:nil error:&error])
            NSLog(@"Error: Create folder failed");
    }
    return dirToCreate;
}

- (BOOL) archiveFileExistsWithName:(NSString*)name {
    NSFileManager *fm= [NSFileManager defaultManager];
    BOOL isDir = YES;
    NSString *filepath = [NSString stringWithFormat:@"%@/%@", [self archiveCacheFolderPath], name];
    return [fm fileExistsAtPath:filepath isDirectory:&isDir];
}

- (void)archiveObject:(id)anObject forKey:(NSString *)key{
    NSString *file = [[self archiveCacheFolderPath] stringByAppendingPathComponent:key];
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:anObject forKey:key];
    [archiver finishEncoding];
    [data writeToFile:file atomically:YES];
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}

- (id)unarchiveObjectforKey:(NSString *)key {
    NSString *file = [[self archiveCacheFolderPath] stringByAppendingPathComponent:key];
    NSData  *newData = [NSData dataWithContentsOfFile:file];
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc]initForReadingWithData:newData];
    id obj = [unarchiver decodeObjectForKey:key];
    [unarchiver finishDecoding];
    return obj;
}

@end
