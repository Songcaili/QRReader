//
//  ViewController.m
//  QRReader
//
//  Created by 宋来 on 2017/3/29.
//  Copyright © 2017年 宋来. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property(nonatomic,strong) QRReaderView *readerView;
@property (nonatomic, strong) UIImageView *scannerLine;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //读取视图
    CGRect readViewFrame = CGRectMake(([UIScreen mainScreen].bounds.size.width - 200)/2.0, 80, 200, 200);
    QRReaderView * readerView = [[QRReaderView alloc] initWithFrame:readViewFrame];
    self.readerView = readerView;
    [self.view addSubview:_readerView];
    _readerView.delegate = self;
    
    //扫描线
    UIImageView *line = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"buleLine.png"]];
    line.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width - 200)/2.0, 80, 200, 20);
    self.scannerLine = line;
    [self.view addSubview:self.scannerLine];
    [self.scannerLine setHidden:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [_readerView start];
    [self startScannerLineAnimate];
}

- (void)startScannerLineAnimate {
    [self.scannerLine setHidden:NO];
    if (self.timer == nil) {
        NSTimer *tempTimer = [NSTimer scheduledTimerWithTimeInterval:3.0f
                                                              target:self
                                                            selector:@selector(animateScannerLine)
                                                            userInfo:nil repeats:YES];
        self.timer = tempTimer;
        [self.timer fire]; //立即执行
    }else {
        [self.timer setFireDate:[NSDate distantPast]];
    }
}

- (void)animateScannerLine
{
    CGRect rect = _readerView.frame;
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.duration = 3.0f;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.fromValue = [NSValue valueWithCGPoint:CGPointMake(rect.origin.x + 100, rect.origin.y)];
    animation.toValue = [NSValue valueWithCGPoint:CGPointMake(rect.origin.x + 100, rect.origin.y + rect.size.height)];
    
    [self.scannerLine.layer addAnimation:animation forKey:@"animation"];
    [UIView beginAnimations:@"" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView commitAnimations];
}

- (void)stopScannerLineAnimate {
    [self.scannerLine setHidden:YES];
    [self.timer setFireDate:[NSDate distantFuture]];
}


- (void)machineCodeDidReadString:(NSString *)string
{
//    [_readerView stop];
//    
//    [self stopScannerLineAnimate];
    
    NSLog(@"%@", string);
}

- (void) viewWillDisappear: (BOOL) animated
{
    [super viewWillDisappear:animated];
    
    [_readerView stop];
    [self stopScannerLineAnimate];
    [self.timer invalidate];
    self.timer = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
