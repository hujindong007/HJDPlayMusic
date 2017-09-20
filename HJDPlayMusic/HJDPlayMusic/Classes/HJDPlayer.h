//
//  HJDPlayer.h
//  HJDPlayMusic
//
//  Created by 胡金东 on 2017/9/7.
//  Copyright © 2017年 胡金东. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 * 播放器的状态
 * 因为UI界面需要加载状态显示, 所以需要提供加载状态
 - XMGRemotePlayerStateUnknown: 未知(比如都没有开始播放音乐)
 - XMGRemotePlayerStateLoading: 正在加载()
 - XMGRemotePlayerStatePlaying: 正在播放
 - XMGRemotePlayerStateStopped: 停止
 - XMGRemotePlayerStatePause:   暂停
 - XMGRemotePlayerStateFailed:  失败(比如没有网络缓存失败, 地址找不到)
 */
typedef NS_ENUM(NSInteger,HJDPlayerState) {
    HJDPlayerStateUnknown = 0,
    HJDPlayerStateLoading = 1,
    HJDPlayerStatePlaying = 2,
    HJDPlayerStateStoped  = 3,
    HJDPlayerStatePause   = 4,
    HJDPlayerStateFailed  = 5
    
};


@interface HJDPlayer : NSObject

+(instancetype)shareInstancePlayer;

- (void)playWithURL:(NSURL *)url isCache:(BOOL)isCache;

// - 暂停
- (void)pause;
// - 停止
- (void)stop;
// - 继续
- (void)resume;
// - 快进/快退
- (void)seekWithTimeDiffer:(NSTimeInterval )timeDiffer;
// - 拖动
- (void)seekWithProgress:(float)progress;


// - 当前播放速率
@property (nonatomic,assign) float rate;
// - 是否静音，可以反向设置数据
@property (nonatomic,assign) BOOL muted;
// - 音量大小
@property (nonatomic,assign) float volume;
// - 总时长
@property (nonatomic,assign,readonly) NSTimeInterval totalTime;
// - 格式化后的总时长
@property (nonatomic,copy,readonly) NSString * totalTimeFormat;
// - 当前时长
@property (nonatomic,assign,readonly) NSTimeInterval currentTime;
// - 格式化后的当前时长
@property (nonatomic,copy,readonly) NSString * currentTimeFormat;
// - 播放进度
@property (nonatomic,assign,readonly) float progress;
// - 当前播放地址的url
@property (nonatomic,strong,readonly) NSURL * url;
// - 加载进度
@property (nonatomic,assign,readonly) float loadDataProgress;
// - 播放状态
@property (nonatomic,assign) HJDPlayerState  playState;

@end
