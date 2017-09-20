//
//  HJDPlayer.m
//  HJDPlayMusic
//
//  Created by 胡金东 on 2017/9/7.
//  Copyright © 2017年 胡金东. All rights reserved.
//

#import "HJDPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import "HJDRmoteResourceLoaderDelegate.h"
#import "NSURL+HJD.h"

@interface HJDPlayer ()<NSCopying,NSMutableCopying>
{
    // - 是否是用户自己手动暂停
    BOOL _isUserPause;
}
// - 音乐播放器
@property (nonatomic,strong) AVPlayer * player;
// - 资源加载代理
@property (nonatomic,strong) HJDRmoteResourceLoaderDelegate * remoteDelegate;
@end

@implementation HJDPlayer


/**
 根据Url地址播放远程音频资源
 
 @param url url地址资源
 @param isCache 是否需要缓存
 */

- (void)playWithURL:(NSURL *)url isCache:(BOOL)isCache
{
    
    NSURL * currentURL = [(AVURLAsset *)self.player.currentItem.asset URL];
    // - 判断当前url是否存在
    if ([url isEqual:currentURL]) {
        NSLog(@"当前播放已经存在,继续播放");
        [self resume];
        return;
    }
    
    // - 判断当前Item是否存在，存在就移除KVO的通知，防止多次注册
    if (self.player.currentItem) {
        [self removeObserver];
    }
    
    
    _url = url;
    // - 如果需要缓存，才走这
    if (isCache) {
        
//        <AVAssetResourceLoadingRequest: 0x600000207f50, URL request = <NSMutableURLRequest: 0x600000207f80> { URL: sreaming://audio.xmcdn.com/group23/M04/63/C5/wKgJNFg2qdLCziiYAGQxcTOSBEw402.m4a }, request ID = 2, content information request = (null), data request = <AVAssetResourceLoadingDataRequest: 0x6080002032b0, requested offset = 0, requested length = 4093201, requests all data to end of resource = YES, current offset = 0>>
        url = [url streamingURL];
    }
    
    
    //1. - 资源请求
    AVURLAsset * urlAsset = [AVURLAsset assetWithURL:url];
    // - 关于网络音频的请求，是通过这个对象，调用代理的相关方法，进行加载的
    // - 拦截加载的请求，只需要，重新修改它的代理方法就可以
    // - 通过这个代理，只需要下载一次就行，不需要一边加载，一边缓存，消耗两次流量
    self.remoteDelegate = [[HJDRmoteResourceLoaderDelegate alloc]init];
    [urlAsset.resourceLoader setDelegate:self.remoteDelegate queue:dispatch_get_main_queue()];
    
    //2. - 资源的组织
    AVPlayerItem * item = [AVPlayerItem playerItemWithAsset:urlAsset];
//    typedef NS_ENUM(NSInteger, AVPlayerItemStatus) {
//        AVPlayerItemStatusUnknown,
//        AVPlayerItemStatusReadyToPlay,
//        AVPlayerItemStatusFailed
//    };
    // - 通知监听，AVPlayerItemStatus status改变AVPlayerItemStatusReadyToPlay，就可以播放
    [item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [item addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    // - 监听是否播放完
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(playEnd) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    // - 监听是否被打断播放
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(playInterupt) name:AVPlayerItemPlaybackStalledNotification object:nil];
    
    // - 3.资源播放
    self.player = [AVPlayer playerWithPlayerItem:item];
}

// - 暂停
- (void)pause{
    
    [self.player pause];
    // - 是用户点击暂停
    _isUserPause = YES;
    // - 判断 当前播放器存在
    if (self.player) {
        self.playState = HJDPlayerStatePause;
    }
    
}
// - 继续
- (void)resume{
    [self.player play];
    // - 不是用户点击暂停
    _isUserPause = NO;
    // - 判断 当前播放器存在 并且 数据组织者里面的数据准备，已经足够播放量
    if (self.player && self.player.currentItem.playbackLikelyToKeepUp) {
        self.playState = HJDPlayerStatePlaying;
    }
}
// - 停止
- (void)stop{
    [self.player pause];
    self.player = nil;
    // - 判断 当前播放器存在
    if (self.player) {
        self.playState = HJDPlayerStateStoped;
    }
}

// - 拖动
- (void)seekWithProgress:(float)progress{
    if (progress<0 || progress>1) {
        return;
    }
    
    // - 可以指定时间点去播放
    // - 时间：CMTime:为影片的时间
    // - 先把影片时间转换成秒
    // - 然后在把秒转换成影片时间
    // - 1.当前音频的总时长
    CMTime totalTime = self.player.currentItem.duration;
    // - 当前音频，已经播放的时长
//    self.player.currentItem.currentTime
    NSTimeInterval totalSecond = CMTimeGetSeconds(totalTime);
    NSTimeInterval playTimeSecond = totalSecond * progress;
    // - 1表示精度
    CMTime currentTime = CMTimeMake(playTimeSecond, 1);
    
    [self.player seekToTime:currentTime completionHandler:^(BOOL finished) {
        if (finished) {
            NSLog(@"确定加载这个时间点的音频资源");
        }else{
            NSLog(@"确定取消这个时间点的音频资源");
        }
    }];
    
}

// - 快进/快退
- (void)seekWithTimeDiffer:(NSTimeInterval )timeDiffer{
    // - 1.当前音频的总时长
    NSTimeInterval totalSecond = [self totalTime];
    
    // - 当前已播放的时长
    NSTimeInterval currentSecond = [self currentTime];
    // - 加快进时间
    currentSecond += timeDiffer;
    // - 交给 拖动方法 处理
    [self seekWithProgress:currentSecond/totalSecond];
}
// - 倍速
- (void)setRate:(float)rate{
    [self.player setRate:rate];
}

- (float)rate
{
    return self.player.rate;
}

// - 静音
- (void)setMuted:(BOOL)muted{
    self.player.muted = muted;
}

- (BOOL)muted
{
    return self.player.muted;
}

// - 音量大小
- (void)setVolume:(float)volume{
    if (volume < 0 || volume > 1) {
        return;
    }
    if (volume > 0) {
        [self setMuted:NO];
    }

    self.player.volume = volume;
   
}

- (float)volume
{
    return self.player.volume;
}
/**
 当前音频资源总时长
 
 @return 总时长
 */
// - readonly只读，就只有get方法
- (NSTimeInterval)totalTime
{// - 总时长
    CMTime totalTime = self.player.currentItem.duration;
    // - 转换成秒
    NSTimeInterval totalTimeSecond = CMTimeGetSeconds(totalTime);
    // - 判断是否为空，为空就返回0
    if (isnan(totalTimeSecond)) {
        return 0;
    }
    return totalTimeSecond;
}

/**
 当前音频资源总时长(格式化后)
 
 @return 总时长 01:02
 */
- (NSString *)totalTimeFormat
{
    return  [NSString stringWithFormat:@"%02zd:%02zd",(int)self.totalTime / 60,(int)self.totalTime % 60];
}

/**
 当前音频资源播放时长
 
 @return 播放时长
 */

- (NSTimeInterval)currentTime
{
    CMTime currtime = self.player.currentItem.currentTime;
    NSTimeInterval currentTimeSecond = CMTimeGetSeconds(currtime);
    if (isnan(currentTimeSecond)) {
        return 0;
    }
    return currentTimeSecond;
}

/**
 当前音频资源播放时长(格式化后)
 
 @return 播放时长
 */
- (NSString *)currentTimeFormat
{
    return [NSString stringWithFormat:@"%02zd:%02zd",(int)self.currentTime / 60,(int)self.currentTime % 60];
}

/**
 当前播放进度
 
 @return 播放进度
 */
- (float)progress
{
    if (self.totalTime == 0) {
        return 0;
    }
    return self.currentTime/self.totalTime;
}
/**
 资源加载进度
 
 @return 加载进度
 */
- (float)loadDataProgress
{
    if (self.totalTime == 0) {
        return 0;
    }
    // - 只取最后一个
    CMTimeRange timeRange = [[self.player.currentItem loadedTimeRanges].lastObject CMTimeRangeValue];
    CMTime loadTime = CMTimeAdd(timeRange.start, timeRange.duration);
    NSTimeInterval loadTimeSecond = CMTimeGetSeconds(loadTime);
    return loadTimeSecond/self.totalTime;
}

- (void)playEnd {
    NSLog(@"播放完成");
    self.playState = HJDPlayerStateStoped;
}

- (void)playInterupt {
    // 来电话, 资源加载跟不上
    NSLog(@"播放被打断");
    self.playState = HJDPlayerStatePause;
}

#pragma mark  - playerState
- (void)setPlayState:(HJDPlayerState)playState
{
    _playState = playState;
    NSLog(@"playState=%zd",_playState);
    
    // 如果需要告知外界相关的事件
    // block
    // 代理
    // 发通知

}

// - 移除监听
- (void)removeObserver{
    [self.player.currentItem removeObserver:self forKeyPath:@"status"];
    [self.player.currentItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark  - KVO 监听

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    // - 这个方法在开始的时候会走
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItemStatus status = [change[NSKeyValueChangeNewKey] integerValue];
        if (status == AVPlayerItemStatusReadyToPlay) {
            NSLog(@"资源准备好了，这时候可以播放了");
            [self resume];
        }else{
            NSLog(@"状态未知");
            self.playState = HJDPlayerStateFailed;
        }
        // - 这个是用户在还没有加载，就拖动到一个位置，这个时候就不会走上面的方法
    }else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]){
        BOOL ptk = [change[NSKeyValueChangeNewKey] boolValue];
        if (ptk) {
            NSLog(@"当前资源，准备的已经足够播放了");
//            用户的手动暂停的优先级最高
            // - 判断在加载过程用户是否点击了暂停
            if (!_isUserPause) {//没有点击
                [self resume];
            }else{
            }
        }else{
            NSLog(@"当前资源不足够播放，加载中");
            self.playState = HJDPlayerStateLoading;
        }
    }
}


#pragma mark  - 单例
static HJDPlayer * _sharePlayer;
+ (instancetype)shareInstancePlayer
{
    if (!_sharePlayer) {
        _sharePlayer = [[HJDPlayer alloc]init];
    }
    return _sharePlayer;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    if (!_sharePlayer) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _sharePlayer = [super allocWithZone:zone];
        });
    }
    return _sharePlayer;
}

- (id)copyWithZone:(NSZone *)zone
{
    return _sharePlayer;
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    return _sharePlayer;
}


@end
