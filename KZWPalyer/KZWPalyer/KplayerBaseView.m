//
//  KplayerBaseView.m
//  KZWPalyer
//
//  Created by uhut on 16/9/5.
//  Copyright © 2016年 uhut. All rights reserved.
//

#import "KplayerBaseView.h"
#import "KPlayerView.h"
#import "LRLLightView.h"


#import "HeadAll.pch"
#import "Masonry.h"
#define TC_TIME_LABEL_FONT_SIZE (12)
#define UNIT_PIXEL (5 * [UIScreen mainScreen].scale)
#define LUMINA_MIN_VALUE 0.1
#define LUMINA_STEP 0.05
#define VOLUME_STEP 0.05

#define iOS8 [UIDevice currentDevice].systemVersion.floatValue >= 8.0
//获取到window
#define Window [[UIApplication sharedApplication].delegate window]


/*
    在这里处理手势，和loading
 */
@interface KplayerBaseView ()<UIGestureRecognizerDelegate>{
    //松手后的时间
    NSInteger                   _seekTime;
    //每一次调节的亮度单位
    CGFloat _luminaStep;
    //每一次调节的声音单位

    CGFloat _volumeStep;
    UIVisualEffectView * _effectView ;
    
    //音量控制控件
    MPVolumeView * _volumeView;
    //用这个来控制音量
    UISlider * _volumeSlider;


}
//这个值判断亮度 默认是1
@property(nonatomic,assign)CGFloat luminance;
@property (nonatomic, assign) CGFloat unitPixel;
//最小亮度值
@property (nonatomic, assign) CGFloat minLumina;
//屏幕亮度背景
@property(nonatomic,strong)UIView *luminaView ;

@property(nonatomic,strong)LRLLightView *lightView;


@end
@implementation KplayerBaseView
-(instancetype)initWithFrame:(CGRect)frame{
    if(self=[super initWithFrame:frame]){
 
//  初始化
        self.luminance=1;
        _opType= GestureOperateType_Unknow;
        _unitPixel = UNIT_PIXEL;
        _minLumina = LUMINA_MIN_VALUE;
        _luminaStep = LUMINA_STEP;
        _volumeStep = VOLUME_STEP;

        _controlTime=4;
        
//添加手势
        
        UIView *viewGesture=[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height-45)];
        [self addSubview:viewGesture];
        viewGesture.backgroundColor=[UIColor clearColor];
        //点击手势
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickPlayView:)];
        _tapGesture.numberOfTapsRequired = 1;
        _tapGesture.numberOfTouchesRequired = 1;
        [viewGesture addGestureRecognizer:_tapGesture];
        
        //增加手势控制
        _progessGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(playViewPanGestureAction:)];
        _progessGesture.minimumNumberOfTouches = 1;
        _progessGesture.maximumNumberOfTouches = 1;
//       _progessGesture.delegate = self;
        [viewGesture addGestureRecognizer:_progessGesture];
        
        //屏幕亮度视图
        _luminaView = [[UIView alloc] initWithFrame:self.bounds];
        _luminaView.alpha = 0;
        //现在调节的是系统亮度，所以注释下面的代码
//        _luminaView.backgroundColor = [UIColor blackColor];
//        _luminaView.userInteractionEnabled = NO;
//        [self addSubview:_luminaView];
        
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [_indicatorView hidesWhenStopped];
        _indicatorView.frame = CGRectMake(0, 0, 50, 50);
        _indicatorView.center=self.center;
//        _indicatorView.backgroundColor=[UIColor yellowColor];
        [self addSubview:_indicatorView];
        
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
        _timeLabel.font = [UIFont systemFontOfSize:14.0];
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
        _timeLabel.center = self.center;//CGPointMake(self.bounds.size.width/2.0, self.bounds.size.height/2.0);
        _timeLabel.hidden = YES;
        [self addSubview:_timeLabel];

        
  
#warning test addSubview 和 frame在子类中重新设置
        _movieTimeControl = [[TCPlayerSlider alloc] initWithFrame:CGRectZero];
        _movieTimeControl.continuous = YES;
        _movieTimeControl.maximumTrackTintColor =RGBA(0x33, 0x33, 0x33,1);//[UIColor blackColor];
        _movieTimeControl.loadTrackTintColor = [UIColor grayColor];
        _movieTimeControl.frame = CGRectMake(20,64,320,30);
        _movieTimeControl.minimumValue=0.0;
        _movieTimeControl.maximumValue=1.0;
        [_movieTimeControl setValue:0.0 animated:YES];
        _movieTimeControl.loadValue=0.0;
        [_movieTimeControl setNeedsDisplay];
        [_movieTimeControl addTarget:self action:@selector(beginScrubbing:) forControlEvents:UIControlEventTouchDown];
        [_movieTimeControl addTarget:self action:@selector(scrubing:) forControlEvents:UIControlEventValueChanged];
        [_movieTimeControl addTarget:self action:@selector(endScrubbing:) forControlEvents:UIControlEventTouchUpOutside | UIControlEventTouchUpInside];
//        [self addSubview:_movieTimeControl];
        
        
        
#pragma mark 添加时间label  addSubview 和 frame在子类中重新设置
        UIFont* timeLabelFont = [UIFont systemFontOfSize:TC_TIME_LABEL_FONT_SIZE];
        CGSize timeLabelSize;
        NSString* defaultTimeText = @" 00:00:00 ";
        BOOL isPreiOS7 = kCFCoreFoundationVersionNumber < kCFCoreFoundationVersionNumber_iOS_7_0;
        if (isPreiOS7) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            timeLabelSize = [defaultTimeText sizeWithFont:timeLabelFont];
#pragma clang diagnostic pop
        }
        else
        {
            timeLabelSize = [defaultTimeText sizeWithAttributes:@{NSFontAttributeName:timeLabelFont}];
        }
        _curPlayTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, timeLabelSize.width, timeLabelSize.height)];
        _curPlayTimeLabel.textColor = [UIColor whiteColor];
        _curPlayTimeLabel.textAlignment = NSTextAlignmentLeft;
        _curPlayTimeLabel.font = [UIFont systemFontOfSize:TC_TIME_LABEL_FONT_SIZE];
        _curPlayTimeLabel.text = @"00:00:00";
//        [self addSubview:_curPlayTimeLabel];

        
        _durationTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, timeLabelSize.width, timeLabelSize.height)];
        _durationTimeLabel.textColor = [UIColor whiteColor];
        _durationTimeLabel.textAlignment = NSTextAlignmentRight;
        _durationTimeLabel.font = [UIFont systemFontOfSize:TC_TIME_LABEL_FONT_SIZE];
        _durationTimeLabel.text = @"00:00:00";
//        [self addSubview:_durationTimeLabel];
        
        [self createLightView];
        [self createVolumeView];
        self.luminance=[UIScreen mainScreen].brightness;
        
        self.endBtn=[MyButton buttonWithType:UIButtonTypeCustom];
        [self.endBtn setImage:imageFile(@"TrainingCourseexit") forState:UIControlStateNormal];
        self.endBtn.frame=CGRectMake(10, 10, 60, 60);
        [self addSubview:self.endBtn];
        //    [_endBtn addTarget:self action:@selector(startXunLian:) forControlEvents:UIControlEventTouchUpInside];
        
        self.playPauseBtn=[MyButton buttonWithType:UIButtonTypeCustom];
        [self.playPauseBtn setImage:imageFile(@"TrainingCourseplay") forState:UIControlStateNormal];
        self.playPauseBtn.frame=CGRectMake(s_height-60, s_width-46-40-20, 40, 40);
        self.playPauseBtn.contentHorizontalAlignment= UIControlContentHorizontalAlignmentRight;
        [self addSubview:self.playPauseBtn];
        
        //隐藏显示  定时器，
        _hiddenTimer=[NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(timeCallback) userInfo:nil repeats:YES];
          [[NSRunLoop currentRunLoop] addTimer:_hiddenTimer forMode:NSDefaultRunLoopMode];
        [self.hiddenTimer setFireDate:[NSDate date]];

    }
    return self;
}
#pragma mark  定时器的回调
-(void)timeCallback{
    NSLog(@"timeCallback");
    //播放按钮隐藏
    if(_playPauseBtn.hidden==NO){
        
        if(_controlTime%5==0){
        [self contorlViewHidden:YES];
//        // 定时器挂起
       [self.hiddenTimer setFireDate:[NSDate distantFuture]];
        }
    }
    _controlTime++;

}
-(void)contorlViewHidden:(BOOL)hidden{
    if(hidden){
    //隐藏
    }else{
      //显示
    }
}
#pragma mark - 用来创建用来显示亮度的view
-(void)createLightView{
    Window.translatesAutoresizingMaskIntoConstraints = NO;
    __weak typeof (self) weakSelf = self;
    if (iOS8) {
        UIBlurEffect * blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        _effectView = [[UIVisualEffectView alloc] initWithEffect:blur];
        _effectView.alpha = 0.0;
        _effectView.contentView.layer.cornerRadius = 10.0;
        _effectView.layer.masksToBounds = YES;
        _effectView.layer.cornerRadius = 10.0;
        
        self.lightView = [[NSBundle mainBundle] loadNibNamed:@"LRLLightView" owner:self options:nil].lastObject;
        self.lightView.translatesAutoresizingMaskIntoConstraints = NO;
        self.lightView.alpha = 0.0;
        [_effectView.contentView addSubview:self.lightView];
        
        [self.lightView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(_effectView);
        }];
        
        [Window addSubview:_effectView];
        [_effectView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(_effectView.superview);
            make.width.equalTo(@(155));
            make.height.equalTo(@155);
        }];
    }else{
        self.lightView = [[NSBundle mainBundle] loadNibNamed:@"LRLLightView" owner:self options:nil].lastObject;
        self.lightView.translatesAutoresizingMaskIntoConstraints = NO;
        self.lightView.alpha = 0.0;
        [Window addSubview:self.lightView];
        [self.lightView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(weakSelf.lightView.superview);
            make.width.equalTo(@(155));
            make.height.equalTo(@155);
        }];
    }
    
}

#pragma mark - 创建控制声音的控制器, 通过self.volumeSlider来控制声音
-(void)createVolumeView{
    _volumeView = [[MPVolumeView alloc] init];
    _volumeView.showsRouteButton = NO;
    _volumeView.showsVolumeSlider = NO;
    for (UIView * view in _volumeView.subviews) {
        if ([NSStringFromClass(view.class) isEqualToString:@"MPVolumeSlider"]) {
            _volumeSlider = (UISlider *)view;
            break;
        }
    }
//    [self addSubview:_volumeView];
        [Window addSubview:_effectView];
}


#pragma mark  进度条的事件处理
-(void)beginScrubbing:(TCPlayerSlider *)sider{
    NSLog(@"beginScrubbing");
    NSLog(@"beginScrubbing-------%f",(sider.value*[_playerView duration]));

    _sliderValueChanging=YES;
    [self.hiddenTimer setFireDate:[NSDate distantFuture]];

}
-(void)scrubing:(TCPlayerSlider *)sider{
    _sliderValueChanging=YES;

}
-(void)endScrubbing:(TCPlayerSlider *)sider{
    NSLog(@"endScrubbing");

   _controlTime=4;
    [self.hiddenTimer setFireDate:[NSDate date]];

    //拖动完成后，刷新label显示的当前拖动的时间
    self.curPlayTimeLabel.text=[self getTimeShowText:(sider.value*[_playerView duration])];
    //清空缓冲 居然不好使，延迟一下看看
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        _movieTimeControl.loadValue = 0.0;
    [_movieTimeControl setNeedsDisplay];
    });

     //前进进度
    //__weak typeof(self)weakSelf=self;
    [_playerView seekToTime:(sider.value*[_playerView duration]) completion:^{
        NSLog(@"endScrubbing-------%f",(sider.value*[_playerView duration]));
    }];


}
#pragma mark  点击手势的处理
- (void)clickPlayView:(UITapGestureRecognizer *)tap
{
    if (tap.state == UIGestureRecognizerStateEnded)
    {
        [self onSingleClick];
    }
}
-(void)onSingleClick{

}

- (void)playViewPanGestureAction:(UIPanGestureRecognizer *)panGesture
{
    switch (panGesture.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            _startPnt = [panGesture translationInView:self];
            _isLeft = [panGesture locationInView:self].x < CGRectGetMidX(self.bounds);
            //这个值判断亮度
           _oldLumina = self.luminance;
//            _oldLumina = [UIScreen mainScreen].brightness;
          
      //这个方法废弃了
            
//            MPMusicPlayerController *mpc = [MPMusicPlayerController applicationMusicPlayer];
//            _oldVolume = mpc.volume;
            
           _oldVolume= _volumeSlider.value;
            
            
            //开始触碰的时候记录事件，但是这个可能因为拖动了进度条，但还没有播放，而变得不准确。
            _oldTime = [_playerView currentTime];
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGPoint curPnt = [panGesture translationInView:self];
            if (GestureOperateType_Unknow == _opType)
            {
                //检测_opType
                if (ABS(curPnt.x - _startPnt.x) > ABS(curPnt.y - _startPnt.y))
                {
                    _opType = GestureOperateType_Progress;
                }
                else
                {
                    //根据触发位置来决定（左边亮度，右边音量）
                    if (_isLeft)
                    {
                        //显示音量控制的view
                        [self hideTheLightViewWithHidden:NO];
                        _opType = GestureOperateType_Lumina;
                    }
                    else
                    {
                        _opType = GestureOperateType_Volume;
                    }
                }
            }
            [self dealWithOpType:_opType startPnt:_startPnt endPnt:curPnt];
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            if (GestureOperateType_Progress == _opType)
            {
                _timeLabel.hidden = YES;
                [_playerView seekToTime:_seekTime completion:nil];
                // 设置成0连续拖动时，会跳到起怒火位置播放
                // _seekTime = 0;
                _oldTime = 0;
            }
            _opType = GestureOperateType_Unknow;
            //显示音量控制的view
            [self hideTheLightViewWithHidden:YES];

        }
            break;
        case UIGestureRecognizerStateCancelled:
        {
            _opType = GestureOperateType_Unknow;
            _timeLabel.hidden = YES;
            //显示音量控制的view
            [self hideTheLightViewWithHidden:YES];

        }
            break;
        default:
        {
            _opType = GestureOperateType_Unknow;
            //显示音量控制的view
            [self hideTheLightViewWithHidden:YES];

        }
            break;
    }
}

#pragma mark  滑动屏幕不松手时处理的事件
- (BOOL)dealWithOpType:(GestureOperateType)opType startPnt:(CGPoint)start endPnt:(CGPoint)end
{
    if (opType == GestureOperateType_Progress)
    {
        CGFloat uint = (end.x - start.y) / _unitPixel;
        if (ABS(uint) < 1)
        {
            return NO;
        }
        [self updateTimeLabel:uint];
    }
    else
    {
        CGFloat uint = (end.y - start.y) / _unitPixel;
        if (ABS(uint) < 1)
        {
            return NO;
        }
        if (opType == GestureOperateType_Lumina)
        {
            [self changeLumina:-uint];
        }
        else
        {
            [self changeVolume:-uint];
        }
    }
    return NO;
}
#pragma mark  更新时间进度label
- (void)updateTimeLabel:(NSInteger)change
{
    if (_playerView.isBuffering)
    {
        return;
    }
    
    _timeLabel.hidden = NO;
    
    NSString *timeString = nil;
    NSInteger time = _oldTime + change;
    
    if (time < 0)
    {
        time = 0;
    }
    else if (time > [_playerView duration])
    {
        time = [_playerView duration];
    }
    
    if (time == 0)
    {
        
    }
    _seekTime = time;
    
    timeString = [NSString stringWithFormat:@"%02zd:%02zd:%02zd", time / 3600, time %3600 /60, time % 60];
    _timeLabel.text = timeString;
    [_timeLabel sizeToFit];
}
#pragma mark  更改亮度
- (void)changeLumina:(NSInteger)change
{
    self.luminance = _oldLumina + change * _luminaStep;
    NSLog(@"self.luminance=%f",self.luminance);
    //真正的调节亮度，不知道能不能上线，暂且不用
    [UIScreen mainScreen].brightness = self.luminance;
    //实时改变现实亮度进度的view
    [self.lightView changeLightViewWithValue:self.luminance];
}
#pragma mark  刷新进度
-(void)RefreshProgress:(CGFloat)second{
    
    CGFloat value=0;
    value=second/[_playerView duration];
    [_movieTimeControl setValue:value animated:YES];
    [_movieTimeControl setNeedsDisplay];
    self.curPlayTimeLabel.text=[self getTimeShowText:second];
    
}
-(void)updateEndTimeLabel:(CGFloat)second{
    self.durationTimeLabel.text=[self getTimeShowText:second];
}
#pragma mark  更新缓冲
- (void)updateOnBufferingProgress:(CGFloat)progress
{
    _movieTimeControl.loadValue = progress;
}
//格式化时间
- (NSString*)getTimeShowText:(CGFloat)fPlaySeconds
{
    NSInteger nPlaySeconds = (NSInteger)fPlaySeconds;
    NSInteger hour = nPlaySeconds / 3600;
    NSInteger minute = (nPlaySeconds - hour * 3600) / 60;
    NSInteger  seconds = nPlaySeconds - hour * 3600 - minute * 60;
    //    if (fPlaySeconds > 0.000001) {
    //        seconds++;
    //    }
    NSString* timeText = [NSString stringWithFormat:@"%.02zd:%.02zd:%.02zd", hour, minute, seconds];
    
    return timeText;
}
#pragma mark - 用来控制显示亮度的view, 以及毛玻璃效果的view
-(void)hideTheLightViewWithHidden:(BOOL)hidden{
    if (hidden) {
        [UIView animateWithDuration:1.0 delay:1.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.lightView.alpha = 0.0;
            if (iOS8) {
                _effectView.alpha = 0.0;
            }
        } completion:nil];
        
    }else{
        self.alpha = 1.0;
        if (iOS8) {
            self.lightView.alpha = 1.0;
            _effectView.alpha = 1.0;
            [Window bringSubviewToFront:_effectView];
        }else{
           [Window bringSubviewToFront:self.lightView];

        }
    }
}

#pragma mark - 播放控制 -
- (void)setLuminance:(CGFloat)luminance
{
    if (luminance < _minLumina)
    {
        luminance = _minLumina;
    }
    else if (luminance > 1)
    {
        luminance = 1;
    }
    _luminaView.alpha = (1 - luminance);
}

- (CGFloat)luminance
{
    return 1 - _luminaView.alpha;
}
#pragma mark  调节声音的大小
- (void)changeVolume:(NSInteger)change
{
//    MPMusicPlayerController *mpc = [MPMusicPlayerController applicationMusicPlayer];
    
    float newVolume = _oldVolume + change * _volumeStep;
    if (newVolume > 1)
    {
        newVolume = 1;
    }
    else if (newVolume < 0)
    {
        newVolume = 0;
    }
    _volumeSlider.value = newVolume;
//    mpc.volume = newVolume;
}
#pragma mark   缓冲的处理
- (void)updateOnWillBuffering
{
    [_indicatorView startAnimating];
}

- (void)updateOnBufferingWhenPlayed
{
    [_indicatorView startAnimating];
}

- (void)updateOnWillPlay
{
    [_indicatorView stopAnimating];
}

- (void)updateOnPlayerFailed
{
    [_indicatorView stopAnimating];
}

- (void)updateOnStateChanged:(KPlayerState)state
{
    if (state == KPlayerState_Play && _indicatorView.isAnimating)
    {
        [_indicatorView stopAnimating];
    }
    else if (state == KPlayerState_Stop)
    {
        [_indicatorView stopAnimating];
    }
}
-(void)dealloc{
    
    if (iOS8) {
        [_effectView removeFromSuperview];
       
    }else{
        [self.lightView removeFromSuperview];

    }
    [_volumeView removeFromSuperview];

  
}
@end
