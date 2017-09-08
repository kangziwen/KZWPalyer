//
//  KPlayerView.h
//  KZWPalyer
//
//  Created by uhut on 16/8/31.
//  Copyright © 2016年 uhut. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "UINavigationController+kzw.h"
#import "KplayerBaseView.h"

/*
   视频相关的操作在这个view中处理，viewcontroller中主要处理不同视频的逻辑。分开处理
 
 @"http://2527.vod.myqcloud.com/2527_117134a2343111e5b8f5bdca6cb9f38c.f20.mp4"
 */
@interface KPlayerView : UIView
/**
 *  AVPlayer播放器
 */
@property (nonatomic, strong) AVPlayer *player;
//控制视频的试图
@property(nonatomic,strong)KplayerBaseView *ctrView;
//是不是正在缓存状态
@property(nonatomic,assign)BOOL isBuffering;
    //播放的当前时间
    @property (nonatomic, assign)CGFloat currentSecond;

#pragma mark  销毁播放器相关
-(void)destoryAVPlayer;
#pragma mark  替换视频
- (void)updatePlayerWith:(NSURL *)url;
-(instancetype)initWithFrame:(CGRect)frame  withCtrView:(Class )ctrViewClass;
//返回当前秒数
-(NSInteger)currentTime;
//总时长
-(NSInteger)duration;
// 跳到time处，会继续播放
- (void)seekToTime:(NSInteger)time completion:(void(^)())completion;
#pragma mark - 更新缓冲时间
-(void)updateAvailableDuration;

@end
