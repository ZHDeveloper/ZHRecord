
//
//  ZHRecordButton.m
//  RecordTest
//
//  Created by AdminZhiHua on 16/4/11.
//  Copyright © 2016年 AdminZhiHua. All rights reserved.
//

#import "ZHRecordButton.h"

@interface ZHRecordButton ()

@property (nonatomic, strong) ZHRecordTool *recordTool;

@end

@implementation ZHRecordButton

- (instancetype)init {
    if ([super init])
    {
        [self initial];
    }
    return self;
}

- (void)awakeFromNib {
    [self initial];
}

- (void)initial {
    //初始化record工具类
    self.recordTool = [ZHRecordTool shareZHRecordTool];

    //设置最小录音时间
    self.recordTool.minRecordTime = 1;
    //最大录音时间
    self.recordTool.maxRecordTime = 10;

    //按下按钮
    [self addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
    //内部松开
    [self addTarget:self action:@selector(touchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    //外部松开
    [self addTarget:self action:@selector(touchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
    //进入内部
    [self addTarget:self action:@selector(touchDragEnter:) forControlEvents:UIControlEventTouchDragEnter];
    //进入外部
    [self addTarget:self action:@selector(touchDragExit:) forControlEvents:UIControlEventTouchDragExit];
    //触摸取消
    [self addTarget:self action:@selector(touchCancel:) forControlEvents:UIControlEventTouchCancel];
}

#pragma mark - Action
- (void)touchDown:(UIButton *)button {
    //开始录音
    [self.recordTool startRecord];
    
    [self.recordTool updateHUDTitle:@"手指上滑,取消发送!"];

    if (self.recordComplete)
    {
        self.recordComplete(ZHRecordStatusStart, nil);
    }
}

//在按钮内松开
- (void)touchUpInside:(UIButton *)button {
    //判断录音是否是合法
    //正常结束录音
    BOOL isValidateRecord = [self.recordTool stopRecord];

    ZHRecordStatus status;
    status = isValidateRecord ? ZHRecordStatusComplete : ZHRecordStatusToShort;

    NSString *recordPath;
    recordPath = isValidateRecord ? self.recordTool.recordFilePath : nil;

    if (self.recordComplete)
    {
        self.recordComplete(ZHRecordStatusComplete, recordPath);
    }
}

- (void)touchUpOutside:(UIButton *)button {
    //取消录音
    [self.recordTool cancelRecord];

    if (self.recordComplete)
    {
        self.recordComplete(ZHRecordStatusCancel, nil);
    }
}

- (void)touchDragEnter:(UIButton *)button {
    [self.recordTool startUpdateVolumeMeters];
    [self.recordTool updateHUDTitle:@"手指上滑,取消发送!"];
}

- (void)touchDragExit:(UIButton *)button {
    [self.recordTool stopUpdateVolumeMeters];

    [self.recordTool updateHUDTitle:@"松开手指，取消发送"];
    [self.recordTool updateHUDImageView:@"ZHRecor.bundle/record_shorttime.png"];
}

- (void)touchCancel:(UIButton *)button {
    //取消录音
    [self.recordTool cancelRecord];

    if (self.recordComplete)
    {
        self.recordComplete(ZHRecordStatusCancel, nil);
    }
}

@end
