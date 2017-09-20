
//
//  HJDRmoteResourceLoaderDelegate.m
//  HJDPlayMusic
//
//  Created by 胡金东 on 2017/9/11.
//  Copyright © 2017年 胡金东. All rights reserved.
//

#import "HJDRmoteResourceLoaderDelegate.h"
#import "HJDAudioDownLoader.h"
#import "HJDAudioFileTool.h"
#import "NSURL+HJD.h"

@interface HJDRmoteResourceLoaderDelegate ()<HJDAudioDownLoaderDelegate>

@property (nonatomic,strong) HJDAudioDownLoader * downLoader;
// - 记录请求数组
@property (nonatomic,strong) NSMutableArray * loadingRequests;

@end


@implementation HJDRmoteResourceLoaderDelegate



// - 当外界，需要播放一段音频资源时，会跑这个请求，给这个对象
// - 这个对象，到时候，只需要根据请求信息，抛数据给外界
- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest {
    NSLog(@"%@",loadingRequest);
    // - 1.判断，本地有没有该音频资源的缓存文件，如果有-> 直接根据本地缓存，向外界响应数据（三个步骤）
    // - 之前转换成streaming，现在转换成http
    NSURL * url = [loadingRequest.request.URL httpURL];
    // - 请求数据
    long long requestOffset = loadingRequest.dataRequest.requestedOffset;
    // - 当前请求数据
    long long currentOffset = loadingRequest.dataRequest.currentOffset;
    // - 当不等的时候，以当前请求数据为准
    if (requestOffset != currentOffset) {
        requestOffset = currentOffset;
    }
    //1. 处理, 本地已经下载好的资源文件
    if ([HJDAudioFileTool cacheFileExists:url]) {
        [self handleLoadingRequest:loadingRequest];
        return YES;
    }
    
    // - 记录所有的请求
    [self.loadingRequests addObject:loadingRequest];
    
    // - 2. 判断有没有正在下载
    if (self.downLoader.loadedSize == 0) {
         //        开始下载数据(根据请求的信息, url, requestOffset, requestLength)
        [self.downLoader downLoadWithURL:url offset:requestOffset];
        return YES;
    }
    
    // - 3. 判断当前是否需要重新下载
    // - 3.1 当资源请求，开始点 < 下载开始点
    // - 3.2 当资源的请求， 开始点 > 下载的开始点 + 下载的长度 + 666(允许追赶的长度)
    if (requestOffset < self.downLoader.offset || requestOffset > (self.downLoader.offset + self.downLoader.loadedSize + 666)) {
        //        开始下载数据(根据请求的信息, url, requestOffset, requestLength)
        [self.downLoader downLoadWithURL:url offset:requestOffset];
        return  YES;
    }
    // - 开始处理资源请求（在下载的过程中，也要不断的去判断）
    [self handleAllLoadingRequest];
    
    return  YES;

}

// - 取消请求

- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest
{
    NSLog(@"取消某个请求");
    // - 取消请求之后要移除 这个请求
    [self.loadingRequests removeObject:loadingRequest];
}
// - 代理方法
- (void)downLoading
{// - 开始处理资源请求（在下载的过程中，也要不断的去判断）
    [self handleAllLoadingRequest];
}

- (void)handleAllLoadingRequest
{
    // - 这里不断处理请求
     NSLog(@"-----%@", self.loadingRequests);
    // - 要删除的请求数组
    NSMutableArray * deleteRequests = [NSMutableArray array];
    for (AVAssetResourceLoadingRequest * loadingRequest in self.loadingRequests) {
        // - 1. 填充内容信息头
        NSURL * url = loadingRequest.request.URL;
        long long totalSize = self.downLoader.totalSize;
        loadingRequest.contentInformationRequest.contentLength = totalSize;
        NSString * contentType = self.downLoader.mimeType;
        loadingRequest.contentInformationRequest.contentType = contentType;
        loadingRequest.contentInformationRequest.byteRangeAccessSupported = YES;
        
        // - 2.填充数据
        NSData * data = [NSData dataWithContentsOfFile:[HJDAudioFileTool tmpFilePath:url] options:NSDataReadingMappedIfSafe error:nil];
        // - 当下载完成时，文件移动到cache中，在tmp中找不到，需要转换一下路径
        if (data == nil) {
            data = [NSData dataWithContentsOfFile:[HJDAudioFileTool cacheFilePath:url] options:NSDataReadingMappedIfSafe error:nil];
        }
        long long requestOffset = loadingRequest.dataRequest.requestedOffset;
        long long currentOffset = loadingRequest.dataRequest.currentOffset;
        // - 如果请求位置和当前请求位置不一样，以当前请求位置为标准
        if (requestOffset != currentOffset) {
            requestOffset = currentOffset;
        }
        // - 请求的长度
        NSInteger requestLength = loadingRequest.dataRequest.requestedLength;
        // - 回应的开始位置
        long long responseOffset = requestOffset - self.downLoader.offset;
        // - 回应的长度，取小的
        long long responseLength = MIN(self.downLoader.offset + self.downLoader.loadedSize - requestOffset, requestLength);
        NSData * subData = [data subdataWithRange:NSMakeRange(responseOffset, responseLength)];
        [loadingRequest.dataRequest respondWithData:subData];
        
        // - 3.完成请求（必须把所有的关于这个请求的区间数据，都返回完之后，才能完成这个请求）
        if (requestLength == responseLength) {
            [loadingRequest finishLoading];
            [deleteRequests addObject:loadingRequest];
        }
        
    }
    // - 移除完成的请求
    [self.loadingRequests removeObjectsInArray:deleteRequests];
}




#pragma mark  - 私有方法
// 处理, 本地已经下载好的资源文件
- (void)handleLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest{

    // - 1.填充相应的信息头信息
    // - 文件总大小
    NSURL * url = loadingRequest.request.URL;
    long long totalSize = [HJDAudioFileTool cacheFileSize:url];
    loadingRequest.contentInformationRequest.contentLength = totalSize ;
    // - 文件类型
    NSString * contentType = [HJDAudioFileTool contentType:url];
    loadingRequest.contentInformationRequest.contentType = contentType;
    // - 文件允许访问区间
    loadingRequest.contentInformationRequest.byteRangeAccessSupported = YES;
    
    // - 2. 相应数据给外界
    // - NSDataReadingMappedIfSafe 不会直接拉到内存，只是映射
    NSData * data = [NSData dataWithContentsOfFile:[HJDAudioFileTool cacheFilePath:url] options:NSDataReadingMappedIfSafe error:nil];
    long long requestOffset = loadingRequest.dataRequest.requestedOffset;
    NSInteger requestLength = loadingRequest.dataRequest.requestedLength;
    
    NSData * subData = [data subdataWithRange:NSMakeRange(requestOffset, requestLength)];
    
    [loadingRequest.dataRequest respondWithData:subData];
    
    // - 3.完成本次请求（一旦，所有的数据都给完了，才能调用完成请求方法）
    [loadingRequest finishLoading];

}

#pragma mark  - loadinit
- (HJDAudioDownLoader *)downLoader
{
    if (!_downLoader) {
        _downLoader = [[HJDAudioDownLoader alloc]init];
        _downLoader.delegate = self;
    }
    return _downLoader;
}

- (NSMutableArray *)loadingRequests
{
    if (!_loadingRequests) {
        _loadingRequests = [NSMutableArray array];
    }
    return _loadingRequests;
}



@end
