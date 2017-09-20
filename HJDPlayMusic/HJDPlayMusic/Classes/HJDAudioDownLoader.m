//
//  HJDAudioDownLoader.m
//  HJDPlayMusic
//
//  Created by 胡金东 on 2017/9/12.
//  Copyright © 2017年 胡金东. All rights reserved.
//

#import "HJDAudioDownLoader.h"
#import "HJDAudioFileTool.h"

@interface HJDAudioDownLoader ()<NSURLSessionDataDelegate>

@property (nonatomic,strong) NSURLSession * session;

@property (nonatomic,strong) NSOutputStream * outputStream;

@property (nonatomic,strong) NSURL * url;

@end


@implementation HJDAudioDownLoader

- (void)downLoadWithURL:(NSURL *)url offset:(long long)offset{
    [self cancelAndClean];
    self.url = url;
    self.offset = offset;
    // - 请求的是某一个区间的数据 Range
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:0];
    [request setValue:[NSString stringWithFormat:@"bytes=%lld-",offset] forHTTPHeaderField:@"Range"];
    NSURLSessionDataTask * task = [self.session dataTaskWithRequest:request];
    // - 启动
    [task resume];
}



- (void)cancelAndClean
{
    // - 取消
    [self.session invalidateAndCancel];
    self.session = nil;
    // - 清空本地临时文件
    [HJDAudioFileTool clearTmpSize:self.url];
    // - 重置数据
    self.loadedSize = 0;
}

#pragma mark  - NSURLSessionDataDelegate
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSHTTPURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    self.totalSize = [response.allHeaderFields[@"Content-Length"] longLongValue];
    NSString * contentRangeStr = response.allHeaderFields[@"Content-Range"];
    if (contentRangeStr.length != 0) {
        self.totalSize = [[contentRangeStr componentsSeparatedByString:@"/"].lastObject longLongValue ];
    }
    // - url类型
    self.mimeType = response.MIMEType;
    // -
    self.outputStream = [NSOutputStream outputStreamToFileAtPath:[HJDAudioFileTool tmpFilePath:self.url] append:YES];
    
    [self.outputStream open];
    
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    self.loadedSize += data.length;
    [self.outputStream write:data.bytes maxLength:data.length];
    // - 代理
    if ([self.delegate respondsToSelector:@selector(downLoading)]) {
        [self.delegate downLoading];
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (error == nil) {
        NSURL * url = self.url;
        if ([HJDAudioFileTool tmpFileSize:url] == self.totalSize) {
            // - 下载完成，移动文件：临时文件夹 -> cache文件夹
            [HJDAudioFileTool moveTmpPathToCachePath:url];
           
        }
    }else{
        NSLog(@"有错误");
    }
}




#pragma mark  - loadinit

- (NSURLSession *)session
{
    if (!_session) {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    return _session;
}

@end
