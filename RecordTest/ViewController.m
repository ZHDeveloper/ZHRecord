//
//  ViewController.m
//  RecordTest
//
//  Created by AdminZhiHua on 16/4/8.
//  Copyright © 2016年 AdminZhiHua. All rights reserved.
//

#import "ViewController.h"
#import "ZHRecordTool.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) ZHRecordTool *recoreTool;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.tableFooterView = [UIView new];

    self.dataSource = [NSMutableArray array];
}

- (void)viewDidAppear:(BOOL)animated {
    self.recoreTool = [ZHRecordTool shareZHRecordTool];
}

#pragma mark - Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reuseID = @"cell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseID];

    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseID];
    }

    NSString *text = self.dataSource[indexPath.row];

    cell.textLabel.text = text;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];

    NSString *fileName = self.dataSource[indexPath.row];

    NSString *filePath = [cachePath stringByAppendingPathComponent:fileName];

    [self.recoreTool playAudioWith:filePath];
}

#pragma mark - Action


- (IBAction)dragDown:(id)sender {
    [self.recoreTool startRecord];
}

- (IBAction)dragExit:(id)sender {
    [self.recoreTool stopRecord];

    [self.dataSource addObject:[self.recoreTool.recordFilePath lastPathComponent]];

    NSLog(@"%@", self.dataSource);

    [self.tableView reloadData];
}

@end
