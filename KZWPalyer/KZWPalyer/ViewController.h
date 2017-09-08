//
//  ViewController.h
//  KZWPalyer
//
//  Created by uhut on 16/8/31.
//  Copyright © 2016年 uhut. All rights reserved.
//

#import <UIKit/UIKit.h>

// 取色值相关的方法
#define RGB(r,g,b)          [UIColor colorWithRed:(r)/255.f \
green:(g)/255.f \
blue:(b)/255.f \
alpha:1.f]
@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *palyerBtn;

@end

