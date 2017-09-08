//
//  KplayerBaseView.h
//  KZWPalyer
//
//  Created by uhut on 16/9/5.
//  Copyright © 2016年 uhut. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyButton.h"
#import "TCPlayerSlider.h"
#import <MediaPlayer/MediaPlayer.h>
#import "HeadAll.pch"
@class KPlayerView;
typedef NS_ENUM(NSUInteger, GestureOperateType) {
    GestureOperateType_Unknow,
    GestureOperateType_Lumina,  //亮度
    GestureOperateType_Progress,//进度
    GestureOperateType_Volume,  //音量
    
    GestureOperateType_VideoTypeSel,  // 侧滑出VideoTypeSel
};

// 播放器状态
typedef NS_ENUM(int, KPlayerState)
{
    KPlayerState_Init,                          // 初始化
    KPlayerState_Preparing,                     // 准备阶段(初次播放时，至状态变为TCPlayerState_Play可理解为首次播放缓冲)
    KPlayerState_Buffering,                     // 缓冲(特指播放过程中出现缓冲)
    KPlayerState_Play,                          // 播放
    KPlayerState_Pause,                         // 暂停
    KPlayerState_Stop,                          // 停止
};


@interface KplayerBaseView : UIView{
@protected
    //  手势相关
    //开始触摸的点坐标
    CGPoint     _startPnt;
    //判定手势的方向
    GestureOperateType _opType;
    //是不是向左
    BOOL        _isLeft;
    NSInteger   _oldTime;
    CGFloat     _oldLumina;
    CGFloat     _oldVolume;
}
//播放器呢界面
@property(nonatomic,strong)KPlayerView *playerView;
//关闭视频播放界面按钮，子类实现
@property(nonatomic,strong)MyButton* endBtn;
@property(nonatomic,strong)MyButton * lockBtn;
@property(nonatomic,strong)MyButton *playPauseBtn;
@property(nonatomic,strong)TCPlayerSlider *movieTimeControl;
// 滑动时显示的时间label，松手时隐藏
@property(nonatomic,strong)UILabel *timeLabel;
// 视频总共的时间label
@property(nonatomic,strong)UILabel *durationTimeLabel;
//当前观看的时间label
@property(nonatomic,strong)UILabel *curPlayTimeLabel;
//缓冲时的loading
@property(nonatomic,strong)UIActivityIndicatorView *indicatorView;
//点击手势
@property(nonatomic,strong)UITapGestureRecognizer *tapGesture;
//滑动手势 支持四个方向的判断
@property(nonatomic,strong)UIPanGestureRecognizer *progessGesture ;

//底部条的view
@property(nonatomic,strong)UIView *bottomView;
//定时器 用来隐藏界面上的控件，每5s回调一次
@property(nonatomic,strong)NSTimer *hiddenTimer;
//控制定时器的时间  默认值为4  controlTime%5==0  判断的
@property(nonatomic,assign)NSInteger controlTime;
/**
 * @b 判断滑块是否在拖动 这个值位no时，每一秒钟，才自动刷新进度条
 */
@property (nonatomic, assign) BOOL sliderValueChanging;


//视频上的控件是否隐藏 ，显示状态时5秒后自动隐藏  子类实现
-(void)contorlViewHidden:(BOOL)hidden;
//
-(void)RefreshProgress:(CGFloat)second;
#pragma mark  更新缓冲
- (void)updateOnBufferingProgress:(CGFloat)progress;
-(void)updateEndTimeLabel:(CGFloat)second;

- (void)updateOnWillPlay;
- (void)updateOnPlayerFailed;
- (void)updateOnWillBuffering;
@end
