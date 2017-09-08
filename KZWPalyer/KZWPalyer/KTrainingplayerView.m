//
//  KTrainingplayerView.m
//  KZWPalyer
//
//  Created by uhut on 16/9/5.
//  Copyright © 2016年 uhut. All rights reserved.
//

#import "KTrainingplayerView.h"
#import "HeadAll.pch"
@interface KTrainingplayerView (){
    //是否隐藏按钮，锁屏
//    BOOL _locked;
}
@end


@implementation KTrainingplayerView
-(instancetype)initWithFrame:(CGRect)frame{
    if(self=[super initWithFrame:frame]){
        [self createBtn];
    }
    return self;
}


#pragma mark  test
-(void)createBtn{
//    _errView=[[NSBundle mainBundle] loadNibNamed:@"TCVideoErrorView" owner:nil options:nil][0];
//    _errView.frame=CGRectMake(0, 0, 200, 150);
//    _errView.center=self.center;
//    _errView.hidden=YES;
//    [self addSubview:_errView];
    
    //   [self bringSubviewToFront:_errView];
    
    self.lockBtn=[MyButton buttonWithType:UIButtonTypeCustom];
    [self.lockBtn setImage:imageFile(@"TrainingCourselock") forState:UIControlStateSelected];
    //开锁图
    [self.lockBtn  setImage:imageFile(@"TrainingCourselock2") forState:UIControlStateNormal ];
    
    self.lockBtn.frame=CGRectMake(s_height-80, 10, 60, 60);
    self.lockBtn.contentHorizontalAlignment= UIControlContentHorizontalAlignmentRight;
    [self addSubview:self.lockBtn];
    [self.lockBtn addTarget:self action:@selector(lockVC:) forControlEvents:UIControlEventTouchUpInside];


    
    _KtitleLab=[[UILabel alloc] initWithFrame:CGRectMake(70, 20, s_height-140, 40)];
    [self addSubview:_KtitleLab];
    _KtitleLab.textColor=[UIColor whiteColor];
    _KtitleLab.text=@"有一个视频";
    _KtitleLab.font=[UIFont systemFontOfSize:18];
    _KtitleLab.backgroundColor=[UIColor clearColor];
    _KtitleLab.textAlignment=NSTextAlignmentCenter;
    
    [self crateBottomSubView];
    
   
}
-(void)crateBottomSubView{
    self.bottomView=[[UIView alloc] initWithFrame:CGRectMake(0, s_width-45, s_height, 45)];
    self.bottomView.backgroundColor=[UIColor clearColor];
    self.bottomView.userInteractionEnabled=YES;
    
    [self addSubview:self.bottomView];
    [self.bottomView addSubview:self.movieTimeControl];
    [self.bottomView addSubview:self.curPlayTimeLabel];
    [self.bottomView addSubview:self.durationTimeLabel];
    self.curPlayTimeLabel.frame=CGRectMake(20, 0, self.curPlayTimeLabel.frame.size.width, 15);
    self.durationTimeLabel.frame=CGRectMake(s_height- 20-self.durationTimeLabel.frame.size.width, 0, self.durationTimeLabel.frame.size.width, 15);
    self.movieTimeControl.frame=CGRectMake(20, 15, s_height-40, 30);
}

-(void)lockVC:(MyButton *)btn{
    btn.selected=!btn.selected;
    if(btn.selected==false){
        //开锁
        [self myUnLock:YES];
    }else{
        //锁
        [self myUnLock:NO];
    }

}
#pragma mark   是否锁住屏幕上的按钮操作 enable＝no，锁
-(void)myUnLock:(BOOL)unlock{
    
    self.endBtn.hidden=!unlock;
    self.playPauseBtn.hidden=!unlock;
    self.KtitleLab.hidden=!unlock;
    self.bottomView.hidden=!unlock;
    self.progessGesture.enabled=unlock;
}


#pragma mark    点击手势，隐藏还是显示，
-(void)onSingleClick{
    
    if(self.lockBtn&&self.lockBtn.selected==YES){
      //锁屏时
        return;
    }
    if(self.playPauseBtn.hidden==YES){
        [self contorlViewHidden:NO];
                // 定时器开启
        [self.hiddenTimer setFireDate:[NSDate date]];
        
    }else{
        [self contorlViewHidden:YES];
        // 定时器挂起
        [self.hiddenTimer setFireDate:[NSDate distantFuture]];
    }
}
//隐藏还是显示
-(void)contorlViewHidden:(BOOL)hidden{
    self.KtitleLab.hidden=hidden;
    self.playPauseBtn.hidden=hidden;
    self.endBtn.hidden=hidden;
    self.bottomView.hidden=hidden;
    self.lockBtn.hidden=hidden;
    self.controlTime=4;
//
//    if(hidden){
//      //隐藏
//
//        [UIView animateWithDuration:0.2 animations:^{
//            self.bottomView.frame=CGRectMake(0, s_width, s_height, 45);
//        } completion:^(BOOL finished) {
//            self.bottomView.hidden=YES;
//        }];
//        //[];
//    }else{
//    //显示
//        [UIView animateWithDuration:0.2 animations:^{
//            self.bottomView.frame=CGRectMake(0, s_width-45, s_height, 45);
//
//        } completion:^(BOOL finished) {
//            self.bottomView.hidden=NO;
//
//        }];
//    }
//    NSLog(@"s_width =%f  s_height=%f",s_width,s_height);
}
@end
