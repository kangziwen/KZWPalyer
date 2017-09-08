//
//  MyButton.h
//  Uhut
//
//  Created by uhut on 15/5/22.
//  Copyright (c) 2015年 uhut. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyButton : UIButton
@property(nonatomic,assign)BOOL isxuanZhong;
@property(nonatomic,strong)NSString *firendCell;
@property(nonatomic,strong)NSArray *chuanArr;
@property(nonatomic,assign)NSInteger row;
@property(nonatomic,assign)NSInteger varable;
@property(nonatomic,strong)NSDictionary *dataDic;

@end
