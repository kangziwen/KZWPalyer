//
//  KPlayerViewTrainController.m
//  KZWPalyer
//
//  Created by uhut on 16/8/31.
//  Copyright © 2016年 uhut. All rights reserved.
//

#import "KPlayerViewTrainController.h"
#import "KPlayerView.h"
#import "CLRotatingScreen.h"
#import "KTrainingplayerView.h"
#define s_width [UIScreen mainScreen].bounds.size.width
#define s_height [UIScreen mainScreen].bounds.size.height

@interface KPlayerViewTrainController ()
@property(nonatomic,strong)KPlayerView *palyerView;
@end

@implementation KPlayerViewTrainController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createPlayerView];
    
    self.view.backgroundColor=[UIColor blackColor];
    [_palyerView updatePlayerWith:[NSURL URLWithString:@"http://baobab.wdjcdn.com/1463028607774b.mp4"]];
  
//    //用来监测屏幕旋转
//    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
  
 }
//-(void)viewDidAppear:(BOOL)animated{
//    [super viewDidAppear:animated];
//    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
//    [self.navigationController setNavigationBarHidden:NO animated:YES];
//
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
//
//}
-(void)createPlayerView{
    _palyerView=[[KPlayerView alloc] initWithFrame:CGRectMake(0, 0,s_height , s_width) withCtrView:[KTrainingplayerView class]];
    [self.view addSubview:_palyerView];
}
//#pragma mark - 通知中心检测到屏幕旋转
//-(void)orientationChanged:(NSNotification *)notification{
//    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
//    //这个就是默认的方向
//    UIInterfaceOrientation Barorientation = [UIApplication sharedApplication].statusBarOrientation;
//  
//    NSLog(@"orientation=%d  Barorientation=%d", orientation,Barorientation);
//    
//    
//
//    switch (orientation) {
//        case UIDeviceOrientationPortrait:
//            NSLog(@"UIDeviceOrientationPortrait");
//            break;
//        case UIDeviceOrientationLandscapeLeft:
//
//            NSLog(@"UIDeviceOrientationLandscapeLeft");
//            //
////            _palyerView.transform = CGAffineTransformMakeRotation(M_PI_2);;
//
//            break;
//        case UIDeviceOrientationLandscapeRight:
//            
//
//            NSLog(@"UIDeviceOrientationLandscapeRight");
////            _palyerView.transform = CGAffineTransformIdentity;
//
//            break;
//        case UIDeviceOrientationPortraitUpsideDown:
//
//            NSLog(@"UIDeviceOrientationPortraitUpsideDown");
//            break;
//        default:
//            break;
//    }
//    
//    UIInterfaceOrientation Barorientationafter = [UIApplication sharedApplication].statusBarOrientation;
//    NSLog(@"Barorientationafter=%d",Barorientation);
//}


#pragma mark   默认横屏的设置 不支持转屏
//不让转屏
-(BOOL)shouldAutorotate{
    return NO;
}
//当前viewcontroller默认的屏幕方向 - 横屏显示
-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationLandscapeRight;
}


- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscapeRight;
}



@end
