# ZHRecord
仿微信录音

####最短的录音时间
	@property (nonatomic, assign) CGFloat minRecordTime;

####最大录音时间
	@property (nonatomic, assign) CGFloat maxRecordTime;

####录音文件的路劲，创建record对象，此属性才有值
	@property (nonatomic, copy) NSString *recordFilePath;

####创建单例类
	+ (instancetype)shareZHRecordTool;

####开始录音
	- (void)startRecord;

####停止录音,返回bool判断录音时间是否正确
	- (BOOL)stopRecord;

####取消录音，会删除当前录音文件
 	- (void)cancelRecord;

####播放当前录音
 	- (void)playRecord;

####根据音频文件的路劲来播放音频
 	- (void)playAudioWith:(NSString *)filePath;

####停止播放音频
 	- (void)stopPlayAudio;

####更新HUD图片

	 - (void)updateHUDImageView:(NSString *)imageName;

####更新HUD标题
	- (void)updateHUDTitle:(NSString *)title;

	- (void)startUpdateVolumeMeters;

	- (void)stopUpdateVolumeMeters;
	
##效果预览
![效果图](https://github.com/ZHDeveloper/ZHRecord/blob/master/Untitled.gif)


