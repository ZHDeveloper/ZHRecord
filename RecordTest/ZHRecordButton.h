//
//  ZHRecordButton.h
//  RecordTest
//
//  Created by AdminZhiHua on 16/4/11.
//  Copyright © 2016年 AdminZhiHua. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZHRecordTool.h"

typedef NS_ENUM(NSUInteger, ZHRecordStatus) {
    ZHRecordStatusUnknow   = 0,
    ZHRecordStatusStart    = 1 << 0,
    ZHRecordStatusComplete = 1 << 1,
    ZHRecordStatusCancel   = 1 << 2,
    ZHRecordStatusToShort  = 1 << 3
};

@interface ZHRecordButton : UIButton

@property (nonatomic, copy) void (^recordComplete)(ZHRecordStatus status, NSString *recordPath);

@end
