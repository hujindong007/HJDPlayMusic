//
//  ViewController.m
//  HJDPlayMusic
//
//  Created by 胡金东 on 2017/9/7.
//  Copyright © 2017年 胡金东. All rights reserved.
//

#import "ViewController.h"
#import "HJDPlayer.h"

@interface ViewController ()
// - 播放
@property (nonatomic,strong) UIButton * playBtn;
// - 暂停
@property (nonatomic,strong) UIButton * pauseBtn;
// - 继续
@property (nonatomic,strong) UIButton * resumeBtn;
// - 快进/快退
@property (nonatomic,strong) UIButton * differBtn;
// - 拖动
@property (nonatomic,strong) UISlider * dragSlider;
// - 开始时间
@property (nonatomic,strong) UILabel * playTimeLbl;
// - 总时间
@property (nonatomic,strong) UILabel * totalTimeLbl;
// - 倍速
@property (nonatomic,strong) UIButton * rateBtn;
// - 静音
@property (nonatomic,strong) UIButton * mutedBtn;
// - 音量大小
@property (nonatomic,strong) UISlider * volumSlider;

@property (nonatomic,strong) UISlider * loadDataSlider;

@property (nonatomic, weak) NSTimer *timer;



@end

@implementation ViewController

- (NSTimer *)timer
{
    if (!_timer) {
        NSTimer * timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(update) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        _timer = timer;
    }
    return _timer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.playBtn];
    [self.view addSubview:self.pauseBtn];
    [self.view addSubview:self.resumeBtn];
    [self.view addSubview:self.differBtn];
    [self.view addSubview:self.dragSlider];
    [self.view addSubview:self.playTimeLbl];
    [self.view addSubview:self.totalTimeLbl];
    [self.view addSubview:self.rateBtn];
    [self.view addSubview:self.mutedBtn];
    [self.view addSubview:self.volumSlider];
    [self.view addSubview:self.loadDataSlider];
    
    [self timer];
  }


- (void)update
{
    self.playTimeLbl.text = [HJDPlayer shareInstancePlayer].currentTimeFormat;
    self.totalTimeLbl.text = [HJDPlayer shareInstancePlayer].totalTimeFormat;
    self.dragSlider.value = [HJDPlayer shareInstancePlayer].progress;
    self.mutedBtn.selected = [HJDPlayer shareInstancePlayer].muted;
    self.volumSlider.value = [HJDPlayer shareInstancePlayer].volume;
    self.loadDataSlider.value = [HJDPlayer shareInstancePlayer].loadDataProgress;
}


#pragma mark  - click
// - 播放点击
- (void)playBtnClick
{
    NSURL * url = [NSURL URLWithString:@"http://audio.xmcdn.com/group23/M04/63/C5/wKgJNFg2qdLCziiYAGQxcTOSBEw402.m4a"];
    [[HJDPlayer shareInstancePlayer] playWithURL:url isCache:YES];
}
// - 暂停点击
- (void)pauseBtnClick
{
    [[HJDPlayer shareInstancePlayer] pause];
}
// - 继续点击
- (void)resumeBtnClick
{
    [[HJDPlayer shareInstancePlayer]resume];
}
// - 快进/快退
- (void)differBtnClick
{
    [[HJDPlayer shareInstancePlayer] seekWithTimeDiffer:15];
}

- (void)dragSliderClick:(UISlider *)slider
{
    [[HJDPlayer shareInstancePlayer] seekWithProgress:slider.value];
}

// - 倍速
- (void)rateBtnClick
{
    [[HJDPlayer shareInstancePlayer] setRate:2];
}
// - 静音
- (void)mutedBtnClick:(UIButton *)btn
{
    btn.selected = !btn.selected;
    [[HJDPlayer shareInstancePlayer] setMuted:btn.selected];
}

- (void)volumSliderClick:(UISlider *)slider
{
    [[HJDPlayer shareInstancePlayer] setVolume:slider.value];
}



#pragma mark  - load

- (UIButton *)playBtn
{
    if (!_playBtn) {
        _playBtn = [[UIButton alloc]initWithFrame:CGRectMake(50, 100, 200, 50)];
        [_playBtn setTitle:@"播放" forState:UIControlStateNormal];
        [_playBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_playBtn addTarget:self action:@selector(playBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playBtn;
}

- (UIButton *)pauseBtn
{
    if (!_pauseBtn) {
        _pauseBtn = [[UIButton alloc]initWithFrame:CGRectMake(50, 150, 200, 50)];
        [_pauseBtn setTitle:@"暂停" forState:UIControlStateNormal];
        [_pauseBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_pauseBtn addTarget:self action:@selector(pauseBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _pauseBtn;
}

- (UIButton *)resumeBtn
{
    if (!_resumeBtn) {
        _resumeBtn = [[UIButton alloc]initWithFrame:CGRectMake(50, 200, 200, 50)];
        [_resumeBtn setTitle:@"继续" forState:UIControlStateNormal];
        [_resumeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_resumeBtn addTarget:self action:@selector(resumeBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _resumeBtn;
}

- (UIButton *)differBtn
{
    if (!_differBtn) {
        _differBtn = [[UIButton alloc]initWithFrame:CGRectMake(50, 250, 200, 50)];
        [_differBtn setTitle:@"快进/快退" forState:UIControlStateNormal];
        [_differBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_differBtn addTarget:self action:@selector(differBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _differBtn;
}

- (UILabel *)playTimeLbl
{
    if (!_playTimeLbl) {
        _playTimeLbl = [[UILabel alloc]initWithFrame:CGRectMake(50, 300, 200, 50)];
        _playTimeLbl.text = @"0:00";
        _playTimeLbl.textColor = [UIColor redColor];
    }
    return _playTimeLbl;
}

- (UILabel *)totalTimeLbl
{
    if (!_totalTimeLbl) {
        _totalTimeLbl = [[UILabel alloc]initWithFrame:CGRectMake(250, 300, 200, 50)];
        _totalTimeLbl.text = @"0:00";
        _totalTimeLbl.textColor = [UIColor redColor];
    }
    return _totalTimeLbl;
}


- (UISlider *)dragSlider
{
    if (!_dragSlider) {
        _dragSlider = [[UISlider alloc]initWithFrame:CGRectMake(50, 350, 200, 50)];
        _dragSlider.value = 0.0;
        [_dragSlider addTarget:self action:@selector(dragSliderClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _dragSlider;
}


- (UIButton *)rateBtn
{
    if (!_rateBtn) {
        _rateBtn = [[UIButton alloc]initWithFrame:CGRectMake(50, 400, 200, 50)];
        [_rateBtn setTitle:@"倍速" forState:UIControlStateNormal];
        [_rateBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_rateBtn addTarget:self action:@selector(rateBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rateBtn;
}

- (UIButton *)mutedBtn
{
    if (!_mutedBtn) {
        _mutedBtn = [[UIButton alloc]initWithFrame:CGRectMake(50, 450, 200, 50)];
        [_mutedBtn setTitle:@"静音" forState:UIControlStateNormal];
        [_mutedBtn setTitle:@"取消静音" forState:UIControlStateSelected];
        [_mutedBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_mutedBtn addTarget:self action:@selector(mutedBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _mutedBtn;
}

- (UISlider *)volumSlider
{
    if (!_volumSlider) {
        _volumSlider = [[UISlider alloc]initWithFrame:CGRectMake(50, 500, 200, 50)];
        _volumSlider.value = 0.0;
        [_volumSlider addTarget:self action:@selector(volumSliderClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _volumSlider;
}

- (UISlider *)loadDataSlider
{
    if (!_loadDataSlider) {
        _loadDataSlider = [[UISlider alloc]initWithFrame:CGRectMake(50, 550, 200, 50)];
        _loadDataSlider.value = 0.0;
//        [_loadDataSlider addTarget:self action:@selector(loadDataSliderClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _loadDataSlider;
}

@end
