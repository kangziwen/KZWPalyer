//
//  ViewController.m
//  KZWPalyer
//
//  Created by uhut on 16/8/31.
//  Copyright © 2016年 uhut. All rights reserved.
//

#import "ViewController.h"
#import "TCPlayerSlider.h"
#import "KPlayerViewTrainController.h"
#import "UHLivePlaybackViewController.h"
#import <AVFoundation/AVFoundation.h>
@interface ViewController (){
    TCPlayerSlider      *_movieTimeControl;

}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
 
    self.view.backgroundColor=[UIColor redColor];
    self.navigationController.navigationBar.hidden=YES;
}
- (IBAction)playerDown:(UIButton *)sender {

    KPlayerViewTrainController *KP=[[KPlayerViewTrainController alloc] init];
    [self presentViewController:KP animated:YES completion:nil];

    
}
- (IBAction)huiFangDown:(id)sender {
    
    
    UHLivePlaybackViewController*KP=[[UHLivePlaybackViewController alloc] init];
       [self.navigationController pushViewController:KP animated:YES];
}
//- (void) convertVideoQuailtyWithInputURL:(NSURL*)inputURL
//                               outputURL:(NSURL*)outputURL
//                         completeHandler:(void (^)(AVAssetExportSession*))handler
//{
//    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:inputURL options:nil];
//    
//    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPresetMediumQuality];//  AVAssetExportPresetLowQuality 画质量失真严重
//    //  NSLog(resultPath);
//    exportSession.outputURL = outputURL;
//    exportSession.outputFileType = AVFileTypeMPEG4;
//    exportSession.shouldOptimizeForNetworkUse= YES;
//    [exportSession exportAsynchronouslyWithCompletionHandler:^(void)
//     {
//         switch (exportSession.status) {
//             case AVAssetExportSessionStatusCancelled:
//                 NSLog(@"AVAssetExportSessionStatusCancelled");
//                 break;
//             case AVAssetExportSessionStatusUnknown:
//                 NSLog(@"AVAssetExportSessionStatusUnknown");
//                 break;
//             case AVAssetExportSessionStatusWaiting:
//                 NSLog(@"AVAssetExportSessionStatusWaiting");
//                 break;
//             case AVAssetExportSessionStatusExporting:
//                 NSLog(@"AVAssetExportSessionStatusExporting");
//                 break;
//             case AVAssetExportSessionStatusCompleted:
//                 NSLog(@"AVAssetExportSessionStatusCompleted");
//                 NSLog(@"%@",[NSString stringWithFormat:@"%f s", [self getVideoLength:outputURL]]);
//                 NSLog(@"%@", [NSString stringWithFormat:@"%.2f kb", [self getFileSize:[outputURL path]]]);
//                 
//                 //UISaveVideoAtPathToSavedPhotosAlbum([outputURL path], self, nil, NULL);//这个是保存到手机相册
//                 
//                 // [self alertUploadVideo:outputURL];
//                 break;
//             case AVAssetExportSessionStatusFailed:
//                 NSLog(@"AVAssetExportSessionStatusFailed");
//                 break;
//         }
//         
//     }];
//    
//}
////此方法可以获取文件的大小，返回的是单位是KB。
//- (CGFloat) getFileSize:(NSString *)path
//{
//    NSLog(@"%@",path);
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    float filesize = -1.0;
//    if ([fileManager fileExistsAtPath:path]) {
//        NSDictionary *fileDic = [fileManager attributesOfItemAtPath:path error:nil];//获取文件的属性
//        unsigned long long size = [[fileDic objectForKey:NSFileSize] longLongValue];
//        filesize = 1.0*size/1024;
//    }else{
//        NSLog(@"找不到文件");
//    }
//    return filesize;
//}
////此方法可以获取视频文件的时长。
//- (CGFloat) getVideoLength:(NSURL *)URL
//{
//    
//    AVURLAsset *avUrl = [AVURLAsset assetWithURL:URL];
//    CMTime time = [avUrl duration];
//    int second = ceil(time.value/time.timescale);
//    return second;
//}
@end
