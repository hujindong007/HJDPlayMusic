//
//  HJDAudioDownLoader.h
//  HJDPlayMusic
//
//  Created by 胡金东 on 2017/9/12.
//  Copyright © 2017年 胡金东. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HJDAudioDownLoaderDelegate <NSObject>

- (void)downLoading;

@end

@interface HJDAudioDownLoader : NSObject

@property (nonatomic,weak) id<HJDAudioDownLoaderDelegate>  delegate;

@property (nonatomic,assign) long long offset;
@property (nonatomic,assign) long long loadedSize;
@property (nonatomic,assign) long long totalSize;

@property (nonatomic,strong) NSString * mimeType;

- (void)downLoadWithURL:(NSURL *)url offset:(long long)offset;

@end
