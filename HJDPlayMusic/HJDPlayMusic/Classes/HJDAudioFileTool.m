
//
//  HJDAudioFile.m
//  HJDPlayMusic
//
//  Created by 胡金东 on 2017/9/12.
//  Copyright © 2017年 胡金东. All rights reserved.
//

#import "HJDAudioFileTool.h"
#import <MobileCoreServices/MobileCoreServices.h>

#define  CachePath NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject
#define  TmpPath NSTemporaryDirectory()

@implementation HJDAudioFileTool
// - 下载成功 返回路径 -> cache + 文件名称
+ (NSString *)cacheFilePath:(NSURL *)url
{
    return [CachePath stringByAppendingPathComponent:url.lastPathComponent];
}

// - 判断文件是否存在
+ (BOOL)cacheFileExists:(NSURL *)url
{
    NSString * path = [self cacheFilePath:url];
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}
// - 返回文件大小
+ (long long)cacheFileSize:(NSURL *)url
{
    // -1.1 文件不存在，直接返回0
    if (![self cacheFileExists:url]) {
        return 0;
    }
    // - 1.2 获取文件路径
    NSString * path = [self cacheFilePath:url];
    NSDictionary * fileInfoDic = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
    return [fileInfoDic[NSFileSize] longLongValue];
}


+ (NSString *)tmpFilePath:(NSURL *)url
{
    return [TmpPath stringByAppendingPathComponent:url.lastPathComponent];
}

+ (BOOL)tmpFileExists:(NSURL *)url
{
    NSString * path = [self tmpFilePath:url];
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

+ (long long)tmpFileSize:(NSURL *)url
{
    if (![self tmpFileExists:url]) {
        return 0;
    }
    
    NSString * path = [self tmpFilePath:url];
    NSDictionary * dict = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
    return [dict[NSFileSize] longLongValue];
}

+ (void)clearTmpSize:(NSURL *)url
{
    NSString * path = [self tmpFilePath:url];
    // - 是否是目录
    BOOL isDirectory = YES;
    // - 路径是否存在
    BOOL isEx = [[NSFileManager defaultManager]fileExistsAtPath:path isDirectory:&isDirectory];
    // - 路径存在并且不是目录 就删除文件，不能把目录都删除了，只删除目录下的临时文件
    if (isEx && !isDirectory) {
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }
    
}

+ (NSString *)contentType:(NSURL *)url
{
    NSString * path = [self cacheFilePath:url];
    NSString * fileExtension = path.pathExtension;
    CFStringRef contentTypeRef = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension,(__bridge CFStringRef _Nonnull)(fileExtension),NULL);
    NSString * contentType = CFBridgingRelease(contentTypeRef);
    return contentType;
}

+ (void)moveTmpPathToCachePath:(NSURL *)url
{
    NSString * cachePath = [self cacheFilePath:url];
    NSString * tmpPath = [self tmpFilePath:url];
    [[NSFileManager defaultManager] moveItemAtPath:tmpPath toPath:cachePath error:nil];
}

@end
