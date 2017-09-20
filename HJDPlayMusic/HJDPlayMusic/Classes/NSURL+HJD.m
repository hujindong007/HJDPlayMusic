
//
//  NSURL+HJD.m
//  HJDPlayMusic
//
//  Created by 胡金东 on 2017/9/11.
//  Copyright © 2017年 胡金东. All rights reserved.
//

#import "NSURL+HJD.h"

@implementation NSURL (HJD)
// - 把url中HTTP改成
//URL: sreaming://audio.xmcdn.com/group23/M04/63/C5/wKgJNFg2qdLCziiYAGQxcTOSBEw402.m4a
- (NSURL *)streamingURL {
    NSURLComponents * compents = [NSURLComponents componentsWithString:self.absoluteString ];
    compents.scheme = @"sreaming";
    return compents.URL;
}

- (NSURL *)httpURL
{
    NSURLComponents * compents = [NSURLComponents componentsWithString:self.absoluteString];
    compents.scheme = @"http";
    return compents.URL;
}

@end
