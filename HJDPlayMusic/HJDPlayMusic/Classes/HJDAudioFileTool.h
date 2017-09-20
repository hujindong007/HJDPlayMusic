//
//  HJDAudioFile.h
//  HJDPlayMusic
//
//  Created by 胡金东 on 2017/9/12.
//  Copyright © 2017年 胡金东. All rights reserved.
//

/**
 这个文件是用来处理tmp和cache 文件的
 */

#import <Foundation/Foundation.h>

@interface HJDAudioFileTool : NSObject
// 下载完成 -> cache + 文件名称
+ (NSString *)cacheFilePath:(NSURL *)url;
// - 缓存文件是否存在
+ (BOOL)cacheFileExists:(NSURL *)url;
// - 返回缓存文件大小
+ (long long)cacheFileSize:(NSURL *)url;


+ (NSString *)tmpFilePath:(NSURL *)url;
+ (BOOL)tmpFileExists:(NSURL *)url;
+ (long long)tmpFileSize:(NSURL *)url;

+ (void)clearTmpSize:(NSURL *)url;

+ (NSString *)contentType:(NSURL *)url;

+ (void)moveTmpPathToCachePath:(NSURL *)url;


@end
