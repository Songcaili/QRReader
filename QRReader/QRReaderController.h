//
//  QRReaderController.h
//  QRReader
//
//  Created by 宋来 on 2017/3/29.
//  Copyright © 2017年 宋来. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

FOUNDATION_EXPORT NSString * const SouFunMachineCodeErrorDomain;

typedef NS_ENUM(NSInteger, SouFunMachineCodeErrorCode) {
    SouFunMachineCodeErrorFailedToAddInput = 98,
    SouFunMachineCodeErrorFailedToAddOutput,
};

@protocol MatchineCodesDetectionDelegate <NSObject>
- (void)didDetectMachineCodes:(NSArray *)codes;
@end


@interface QRReaderController : NSObject

@property (weak, nonatomic) id <MatchineCodesDetectionDelegate> codeDetectionDelegate;
@property (strong, nonatomic) AVCaptureSession *captureSession;

- (BOOL)setupSession:(NSError **)error;

- (void)startSession;
- (void)stopSession;

- (NSString *)readImage:(UIImage *)image;

@end
