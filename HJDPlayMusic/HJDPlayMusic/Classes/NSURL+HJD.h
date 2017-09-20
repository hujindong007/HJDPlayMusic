//
//  NSURL+HJD.h
//  HJDPlayMusic
//
//  Created by 胡金东 on 2017/9/11.
//  Copyright © 2017年 胡金东. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (HJD)
// - sreaming
//　HTTP Live Streaming（HLS）是苹果公司(Apple Inc.)实现的基于HTTP的流媒体传输协议，可实现流媒体的直播和点播，主要应用在iOS系统，为iOS设备（如iPhone、iPad）提供音视频直播和点播方案
/**
 获取streaming协议的url地址
 */
- (NSURL *)streamingURL;

- (NSURL *)httpURL;

@end
