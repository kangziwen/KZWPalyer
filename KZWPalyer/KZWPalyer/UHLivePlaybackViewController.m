//
//  UHLivePlaybackViewController.m
//  KZWPalyer
//
//  Created by uhut on 16/9/27.
//  Copyright © 2016年 uhut. All rights reserved.
//

#import "UHLivePlaybackViewController.h"
#import "KPlayerView.h"
#import "UHLivePlaybackView.h"

@interface UHLivePlaybackViewController ()
@property(nonatomic,strong)KPlayerView *palyerView;

@end

@implementation UHLivePlaybackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _palyerView=[[KPlayerView alloc] initWithFrame:CGRectMake(0, 0 ,s_width , s_height) withCtrView:[UHLivePlaybackView class]];
    [self.view addSubview:_palyerView];
    self.view.backgroundColor=[UIColor blackColor];
    NSString *path=NSHomeDirectory();
    NSString *str=[NSString stringWithFormat:@"%@/Documents/hehheheh.wmv",path];
    NSURL *fileurl=[NSURL fileURLWithPath:str];
    NSLog(@"path===%@",path);
    [_palyerView updatePlayerWith:fileurl];//@"http://baobab.wdjcdn.com/1463028607774b.mp4"[NSURL URLWithString:fileurl]
}

@end
