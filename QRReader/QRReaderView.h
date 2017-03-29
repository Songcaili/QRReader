//
//  QRReaderView.h
//  QRReader
//
//  Created by 宋来 on 2017/3/29.
//  Copyright © 2017年 宋来. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "QRReaderController.h"

@protocol QRReaderViewDelegate <NSObject>

- (void)machineCodeDidReadString:(NSString *)string;

@end

@interface QRReaderView : UIView <MatchineCodesDetectionDelegate>

@property (strong, nonatomic) AVCaptureSession *session;
@property(nonatomic,assign) id<QRReaderViewDelegate> delegate;

- (void)start;
- (void)stop;


@end
