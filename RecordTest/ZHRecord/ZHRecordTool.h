//
//  ZHRecordTool.h
//  RecordTest
//
//  Created by AdminZhiHua on 16/4/8.
//  Copyright © 2016年 AdminZhiHua. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

// 录音工具类
@interface ZHRecordTool : NSObject

#pragma mark - 属性

//最短的录音时间
@property (nonatomic, assign) CGFloat minRecordTime;

//最大录音时间
@property (nonatomic, assign) CGFloat maxRecordTime;

//录音文件的路劲，创建record对象，此属性才有值
@property (nonatomic, copy) NSString *recordFilePath;

//创建单例类
+ (instancetype)shareZHRecordTool;

//开始录音
- (void)startRecord;

//停止录音,返回bool判断录音时间是否正确
- (BOOL)stopRecord;

//取消录音，会删除当前录音文件
- (void)cancelRecord;

//播放当前录音
- (void)playRecord;

//根据音频文件的路劲来播放音频
- (void)playAudioWith:(NSString *)filePath;

//停止播放音频
- (void)stopPlayAudio;

//更新HUD图片
- (void)updateHUDImageView:(NSString *)imageName;

//更新HUD标题
- (void)updateHUDTitle:(NSString *)title;

- (void)startUpdateVolumeMeters;

- (void)stopUpdateVolumeMeters;

//是否是标准录音,小于最短的录音时间或大于最大录音时间返回false;
//此方法在停止录音前调用
//- (BOOL)isValidateRecord;

@end
