//
//  UHLivePlaybackView.m
//  KZWPalyer
//
//  Created by uhut on 16/9/27.
//  Copyright © 2016年 uhut. All rights reserved.
//

#import "UHLivePlaybackView.h"

@implementation UHLivePlaybackView
-(instancetype)initWithFrame:(CGRect)frame{
    if(self=[super initWithFrame:frame]){
        [self upDateFrame];
    }
    return self;
}
-(void)upDateFrame{
    self.endBtn.frame=CGRectMake(s_width-60, 20, 60, 60);
  // self.playPauseBtn.frame=CGRectMake(s_height-60, s_width-46-40-20, 40, 40);

}
@end
