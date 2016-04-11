//
//  ZHRecordTool.m
//  RecordTest
//
//  Created by AdminZhiHua on 16/4/8.
//  Copyright © 2016年 AdminZhiHua. All rights reserved.
//

#import "ZHRecordTool.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"

#define HUDFont [UIFont systemFontOfSize:12]

// 全局实例
static ZHRecordTool *instance;

@interface ZHRecordTool () <AVAudioRecorderDelegate>

//录音对象
@property (nonatomic, strong) AVAudioRecorder *recorder;

//播放器对象
@property (nonatomic, strong) AVAudioPlayer *player;

//回话对象
@property (nonatomic, strong) AVAudioSession *session;

//音量指示view
@property (nonatomic, assign) MBProgressHUD *progressHUD;
@property (nonatomic, strong) UIImageView *voliceView;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation ZHRecordTool

#pragma mark - init
+ (instancetype)shareZHRecordTool {
    //创建单例
    if (!instance)
    {
        instance = [[ZHRecordTool alloc] init];
    }

    //默认最大录音时间
    instance.maxRecordTime = CGFLOAT_MAX;

    //默认最小录音时间是0
    instance.minRecordTime = 0;

    //重置录音对象,以及录音文件的路劲
    instance.recordFilePath = nil;
    instance.recorder       = nil;

    return instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    //分配空间的时候检测单例
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [super allocWithZone:zone];
    });

    return instance;
}

#pragma mark - Public
- (void)startRecord {
    //设置session
    self.session = [AVAudioSession sharedInstance];
    [self.session setCategory:AVAudioSessionCategoryRecord error:nil];
    [self.session setActive:YES error:nil];

    //录音
    [self.recorder record];

    //显示指示器的view
    [self.progressHUD show:YES];

    //开始刷新音量
    [self startUpdateVolumeMeters];
}

- (BOOL)stopRecord {
    //判断录音时间是否正确
    BOOL isValidateRecord = [self isValidateRecord];

    [self.recorder stop];

    //重置recorder
    self.recorder = nil;

    //取消延迟执行刷新音量
    [self stopUpdateVolumeMeters];

    return isValidateRecord;
}

- (void)cancelRecord {
    //停止录音
    [self stopRecord];

    //删除当前录音文件
    [self removeFileAtPath:self.recordFilePath];
}

- (void)removeFileAtPath:(NSString *)path {
    NSFileManager *manage = [NSFileManager defaultManager];
    [manage removeItemAtPath:path error:nil];
}

- (BOOL)isValidateRecord {
    //判断录音时间是否合法
    BOOL isValidateRecord = (self.minRecordTime < self.recorder.currentTime) && (self.recorder.currentTime < self.maxRecordTime);

    if (!isValidateRecord)
    { //删除录音文件
        [self.recorder deleteRecording];
        [self updateHUDTitle:@"录音时间太短"];
        [self updateHUDImageView:@"ZHRecor.bundle/record_shorttime.png"];
        [self.progressHUD hide:YES afterDelay:0.5];
        self.progressHUD = nil;
    }
    else
    {
        [self.progressHUD hide:YES];
        self.progressHUD = nil;
    }

    return isValidateRecord;
}

- (void)playRecord {
    //如果没有当前录音文件返回
    if (!self.recordFilePath) return;

    //如果正在播放就放回
    if ([self.player isPlaying]) return;

    //播放当前的录音文件
    [self playAudioWith:self.recordFilePath];
}

- (void)playAudioWith:(NSString *)filePath {
    //录音文件路劲
    NSURL *fileUrl = [NSURL fileURLWithPath:filePath];

    NSError *error;

    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileUrl error:&error];

    [self.session setCategory:AVAudioSessionCategoryPlayback error:nil];

    //播放音频文件
    [self.player prepareToPlay];
    [self.player play];
}

- (void)stopPlayAudio {
    [self.player stop];
}

//开始更新音量
- (void)startUpdateVolumeMeters {
    [self performSelector:@selector(updateVolumeMeters) withObject:nil];
}

//停止刷新音量
- (void)stopUpdateVolumeMeters {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateVolumeMeters) object:nil];
}

//检测音量
- (void)updateVolumeMeters {
    //更新音量
    [self.recorder updateMeters];

    float lowPassResults = pow(10, (0.05 * [_recorder peakPowerForChannel:0]));

    NSLog(@"%lf", lowPassResults);

    if (0.0 <= lowPassResults && lowPassResults <= 0.14)
    {
        [self updateHUDImageView:@"ZHRecor.bundle/record_animate_1.png"];
    }
    else if (0.14 < lowPassResults && lowPassResults <= 0.28)
    {
        [self updateHUDImageView:@"ZHRecor.bundle/record_animate_2.png"];
    }
    else if (0.28 < lowPassResults && lowPassResults <= 0.42)
    {
        [self updateHUDImageView:@"ZHRecor.bundle/record_animate_3.png"];
    }
    else if (0.42 < lowPassResults && lowPassResults <= 0.56)
    {
        [self updateHUDImageView:@"ZHRecor.bundle/record_animate_4.png"];
    }
    else if (0.56 < lowPassResults && lowPassResults <= 0.7)
    {
        [self updateHUDImageView:@"ZHRecor.bundle/record_animate_5.png"];
    }
    else if (0.7 < lowPassResults && lowPassResults <= 0.84)
    {
        [self updateHUDImageView:@"ZHRecor.bundle/record_animate_6.png"];
    }
    else if (0.84 < lowPassResults && lowPassResults <= 0.98)
    {
        [self updateHUDImageView:@"ZHRecor.bundle/record_animate_7.png"];
    }
    else
    {
        [self updateHUDImageView:@"ZHRecor.bundle/record_animate_8.png"];
    }

    //0.5秒刷新一次
    [self performSelector:@selector(updateVolumeMeters) withObject:nil afterDelay:0.25];
}

- (void)updateHUDImageView:(NSString *)imageName {
    self.voliceView.image = [UIImage imageNamed:imageName];
}

- (void)updateHUDTitle:(NSString *)title {
    self.titleLabel.text = title;
}

#pragma mark - AVAudioRecorderDelegate
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {

    if (flag)
    { //取消激活session，其他音频可播放
        [self.session setActive:NO error:nil];
    }
}

#pragma mark - Getter&Setter
- (AVAudioRecorder *)recorder {
    if (!_recorder)
    {
        NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];

        //获取当前的时间
        NSDateFormatter *formatter = [NSDateFormatter new];
        formatter.dateFormat       = @"yyyy-MM-dd-HH-mm-ss";

        NSString *dateStr = [formatter stringFromDate:[NSDate date]];
        //录音文件名
        NSString *fileName = [NSString stringWithFormat:@"Record%@.caf", dateStr];

        //录音文件保存的路劲
        NSString *filePath = [cachePath stringByAppendingPathComponent:fileName];

        self.recordFilePath = filePath;

        //录音的配置
        NSMutableDictionary *setting = [NSMutableDictionary dictionary];

        //音频编码格式
        setting[AVFormatIDKey] = @(kAudioFormatAppleIMA4);

        //音频采样率
        setting[AVSampleRateKey] = @(8000.0);

        //音频频道
        setting[AVNumberOfChannelsKey] = @(1);

        //音频线性音频的位深度
        setting[AVLinearPCMBitDepthKey] = @(8);

        NSError *error;
        _recorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:filePath] settings:setting error:&error];
        //准备录音
        [_recorder prepareToRecord];

        NSLog(@"最长录音时间--%lf", self.maxRecordTime);
        //最长录音时间
        [_recorder recordForDuration:self.maxRecordTime];

        _recorder.delegate = self;
        //开启音量的检测
        _recorder.meteringEnabled = YES;
    }

    return _recorder;
}

- (MBProgressHUD *)progressHUD {
    if (!_progressHUD)
    {
        AppDelegate *delegate = [UIApplication sharedApplication].delegate;

        UIWindow *window = delegate.window;

        //将指示view添加到主窗口
        _progressHUD = [MBProgressHUD showHUDAddedTo:window animated:YES];

        _progressHUD.removeFromSuperViewOnHide = YES;

        //使用自定义view
        _progressHUD.mode    = MBProgressHUDModeCustomView;
        _progressHUD.opacity = 0.6;

        //添加自定义view
        UIView *customView      = [UIView new];
        customView.bounds       = CGRectMake(0, 0, 130, 120);
        _progressHUD.customView = customView;

        //customeView添加子view
        [customView addSubview:self.voliceView];
        [customView addSubview:self.titleLabel];

        //给子view添加约束
        [self addConstToSubViews];
    }
    return _progressHUD;
}

- (void)addConstToSubViews {
    self.voliceView.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;

    //VoliceView
    NSLayoutConstraint *centerX = [NSLayoutConstraint constraintWithItem:self.voliceView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.voliceView.superview attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];

    NSLayoutConstraint *centerY = [NSLayoutConstraint constraintWithItem:self.voliceView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.voliceView.superview attribute:NSLayoutAttributeCenterY multiplier:1 constant:-10];

    //    NSLayoutConstraint *voliceViewW = [NSLayoutConstraint constraintWithItem:self.voliceView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:81];
    //
    //    NSLayoutConstraint *voliceViewH = [NSLayoutConstraint constraintWithItem:self.voliceView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:90];

    [self.voliceView.superview addConstraints:@[ centerX, centerY ]];

    //TitleLabel
    NSLayoutConstraint *titleLabelLeft = [NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.titleLabel.superview attribute:NSLayoutAttributeLeading multiplier:1 constant:0];

    NSLayoutConstraint *titleLabelRight = [NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.titleLabel.superview attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];

    NSLayoutConstraint *titleLabelTop = [NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.voliceView attribute:NSLayoutAttributeBottom multiplier:1 constant:10];
    [self.titleLabel.superview addConstraints:@[ titleLabelLeft, titleLabelRight, titleLabelTop ]];
}

- (UIImageView *)voliceView {
    if (!_voliceView)
    {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ZHRecor.bundle/record_animate_1"]];
        _voliceView            = imageView;
    }
    return _voliceView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel)
    {
        UILabel *titleLabel = [UILabel new];
        NSString *title     = @"手指上滑,取消发送!";
        titleLabel.text     = title;

        titleLabel.numberOfLines = 0;
        titleLabel.font          = HUDFont;
        titleLabel.textAlignment = NSTextAlignmentCenter;

        titleLabel.layer.cornerRadius  = 3;
        titleLabel.layer.masksToBounds = YES;

        titleLabel.textColor = [UIColor whiteColor];
        _titleLabel          = titleLabel;
    }
    return _titleLabel;
}

@end
