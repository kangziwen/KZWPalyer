//
//  KPlayerView.m
//  KZWPalyer
//
//  Created by uhut on 16/8/31.
//  Copyright © 2016年 uhut. All rights reserved.
//

#import "KPlayerView.h"

@interface KPlayerView(){
  AVPlayerItem *_playerItem;
  AVPlayerLayer *_playerLayer;
    //判断是否为第一次布局
    BOOL _isFisrtConfig;


}
/**
* @b 用来监控播放时间的observer
*/
@property (nonatomic, strong) id timerObserver;
/**
 *  @b 视频的总长度
 */
@property (nonatomic, assign, readonly) CGFloat totalSeconds;

/**
 *  @b 是否在播放
 */
@property (nonatomic, assign, readonly) BOOL isPlaying;


@end
@implementation KPlayerView
-(instancetype)initWithFrame:(CGRect)frame  withCtrView:(Class )ctrViewClass{//KplayerBaseView
    if(self=[super initWithFrame:frame]){
        
#pragma mark  初始化数据
        _isFisrtConfig=YES;
        _isPlaying=YES;
         _ctrView=[[ctrViewClass alloc] initWithFrame:self.bounds];
        _ctrView.playerView=self;
        self.player = [[AVPlayer alloc] init];
        self.player.usesExternalPlaybackWhileExternalScreenIsActive = YES;

        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
        _playerLayer.frame=self.bounds;
        
//        _playerLayer.videoGravity=AVLayerVideoGravityResize;//AVLayerVideoGravityResizeAspectFill;//视频填充模式
        NSLog(@"_playerLayer.frame=%f %f  %f  %f",_playerLayer.frame.origin.x ,_playerLayer.frame.origin.y,_playerLayer.frame.size.width,_playerLayer.frame.size.height);
        [self.layer addSublayer:_playerLayer];
        [self addSubview:_ctrView];
        //显示缓冲状态
        [_ctrView updateOnWillBuffering];
//        [_ctrView.playPauseBtn addTarget:self action:@selector(playPauseDown:) forControlEvents:UIControlEventTouchUpInside];

    }
    return self;
}
//#pragma mark  btn事件
//-(void)playPauseDown:(UIButton *)btn{
//    //if()
//    [self.player pause];
//    }
#pragma mark - 添加监听事件
-(void )addObserverAndNotification{
//    if (!_playerItem) {
        [_playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        [_playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        [_playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        [_playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        [_playerItem addObserver:self forKeyPath:@"playbackBufferFull" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        [_playerItem addObserver:self forKeyPath:@"presentationSize" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
//    }
}

#pragma mark  替换视频
- (void)updatePlayerWith:(NSURL *)url{
    
    _playerItem = [AVPlayerItem playerItemWithURL:url];
    [_player replaceCurrentItemWithPlayerItem:_playerItem];
    [self addObserverAndNotification];
}

-(NSInteger)currentTime{
    return _currentSecond;
}
-(NSInteger) duration{
    return _totalSeconds;
}
#pragma mark  向前滑动屏幕会调用这个方法
- (void)seekToTime:(NSInteger)time completion:(void(^)())completion{
    
    if(_playerItem.status == AVPlayerItemStatusReadyToPlay){
    _ctrView.indicatorView.hidden = NO;
    [_ctrView.indicatorView startAnimating];
    [self.player pause];
    CMTime changedTime = CMTimeMakeWithSeconds(time, 1);
    __weak typeof(self)  weakSelf = self;
    [self.player seekToTime:changedTime completionHandler:^(BOOL finished){
        if (weakSelf.isPlaying) {
            [weakSelf.player play];
        }
          [weakSelf.ctrView.indicatorView stopAnimating];
        weakSelf.ctrView.indicatorView.hidden = YES;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 延迟一会，addPeriodicTimeObserverForInterval ，回调的太快 会有回弹得效果，暂时没有解决，这样写会好点
        weakSelf.ctrView.sliderValueChanging = NO;
        });
        if (completion) {
            completion();
        }
    }];
    }
}
//播放结束调用的方法
-(void)moviePlayEnd:(NSNotification *)notification{
    [self seekToTime:0 completion:nil];
    [self.player pause];
    _isPlaying = NO;
}
#pragma mark - KVO - 监测视频状态, 视频播放的核心部分
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"status"]) {        //获取到视频信息的状态, 成功就可以进行播放, 失败代表加载失败
        if (_playerItem.status == AVPlayerItemStatusReadyToPlay) {   //准备好播放
            NSLog(@"AVPlayerItemStatusReadyToPlay: 视频成功播放");
            if (_isFisrtConfig) {
                //self准备好播放
                [self readyToPlay];
                //avplayerView准备好播放
                [self readyToPlayConfigPlayView];
                if (self.isPlaying) {
                    [self.player play];
                }else{
                    [self.player pause];
                }
//                if (_destoryed) {
//                    [self seekToTheTimeValue:_destoryTempTime];
//                }
            }
        }else if(_playerItem.status == AVPlayerItemStatusFailed){    //加载失败
            NSLog(@"AVPlayerItemStatusFailed: 视频播放失败");
        }else if(_playerItem.status == AVPlayerItemStatusUnknown){   //未知错误
            NSLog(@"AVPlayerItemStatusUnknown: 未知错误");

        }
//        _destoryed = NO;
    }else if([keyPath isEqualToString:@"loadedTimeRanges"]){ //当缓冲进度有变化的时候
        //防止向后拖动滑动条，有缓冲效果也卡住的现象
        if(!self.ctrView.sliderValueChanging)
        [self updateAvailableDuration];
        NSLog(@"loadedTimeRanges");
    }else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]){ //当视频播放因为各种状态播放停止的时候, 这个属性会发生变化
//        if (self.pipC && self.pipC.pictureInPictureActive) {
//            _isPlaying = YES;
//            [self playOrPause];
//        }else{
            if (self.isPlaying) {
                [self.player play];
                [_ctrView.indicatorView stopAnimating];
                _ctrView.indicatorView.hidden = YES;
            }
//        }
        NSLog(@"playbackLikelyToKeepUp change : %@", change);
    }else if([keyPath isEqualToString:@"playbackBufferEmpty"]){  //当没有任何缓冲部分可以播放的时候
        [_ctrView.indicatorView startAnimating];
        _ctrView.indicatorView.hidden = NO;
        NSLog(@"playbackBufferEmpty");
    }else if ([keyPath isEqualToString:@"playbackBufferFull"]){
        NSLog(@"playbackBufferFull: change : %@", change);
    }else if([keyPath isEqualToString:@"presentationSize"]){      //获取到视频的大小的时候调用
        NSLog(@"presentationSize");

////        if (!_isFullScreen) {
//            CGSize size = _playerItem.presentationSize;
//            static float staticHeight = 0;
//            staticHeight = size.height/size.width * SCREEN_WIDTH;
//            self->_videoHeight = &(staticHeight);
//            [self mas_remakeConstraints:self.portraitBlock];
////        }
//        //用来监测屏幕旋转
//        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
//        _canFullScreen = YES;
//        AVDLog(@"presentationSize");
    }
}
#pragma mark - 缓冲好准备播放所做的操作, 并且添加时间观察, 更新播放时间
-(void)readyToPlay{
    _isFisrtConfig = NO;
    _totalSeconds = _playerItem.duration.value/_playerItem.duration.timescale;
    _totalSeconds = (float)self.totalSeconds;
//    NSInteger tempLength = self.totalTimeLabel.text.length;
//    if (tempLength > 5) {
//        self.timeLabel.text = @"00:00:00";
//    }else{
//        self.timeLabel.text = @"00:00";
//    }
    //这个是用来监测视频播放的进度做出相应的操作  一秒钟回调一次
    __weak typeof(self) weakSelf = self;
    self.timerObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:nil usingBlock:^(CMTime time) {
        //刷新进度条进度和当前时间显示label的变化
        if(!weakSelf.ctrView.sliderValueChanging)
        {
            NSLog(@"-------%f",CMTimeGetSeconds(time));
            weakSelf.currentSecond=(CMTimeGetSeconds(time));//_playerItem.currentTime.value/_playerItem.currentTime.timescale;

        [weakSelf.ctrView RefreshProgress:weakSelf.currentSecond];
        }
        
    }];
  //设置结束label显示的时间
    [self.ctrView updateEndTimeLabel:_totalSeconds];
    
    
}
-(void)readyToPlayConfigPlayView{
    [_ctrView updateOnWillPlay];

}
#pragma mark - 更新缓冲时间
-(void)updateAvailableDuration{
    NSArray * loadedTimeRanges = _playerItem.loadedTimeRanges;
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds;
    //self.videoProgressView.progress = result/self.totalSeconds;
    //更新缓冲的进度条
    [_ctrView  updateOnBufferingProgress:result/self.totalSeconds];
}



#pragma mark  销毁播放器相关
-(void)destoryAVPlayer{
//    _destoryTempTime = self.avplayerItem.currentTime.value/self.avplayerItem.currentTime.timescale;
    if (_ctrView.hiddenTimer && _ctrView.hiddenTimer.valid) {
        [_ctrView.hiddenTimer invalidate];
        _ctrView.hiddenTimer = nil;
    }
    if (_playerItem) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
        /*
         status
         loadedTimeRanges
         playbackLikelyToKeepUp
         playbackBufferEmpty
         playbackBufferFull
         presentationSize
         */
        [_playerItem removeObserver:self forKeyPath:@"status"];
        [_playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
        [_playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
        [_playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
        [_playerItem removeObserver:self forKeyPath:@"playbackBufferFull"];
        [_playerItem removeObserver:self forKeyPath:@"presentationSize"];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (_timerObserver) {
        [self.player removeTimeObserver:self.timerObserver];
        _timerObserver = nil;
    }
    [(AVPlayerLayer *)self.layer setPlayer:nil];
    _playerItem = nil;
     self.player = nil;
}



@end
