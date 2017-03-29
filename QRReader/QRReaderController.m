//
//  QRReaderController.m
//  QRReader
//
//  Created by 宋来 on 2017/3/29.
//  Copyright © 2017年 宋来. All rights reserved.
//

#import "QRReaderController.h"
#import <UIKit/UIKit.h>

NSString *const SouFunMachineCodeErrorDomain = @"com.SouFun.SouFunMachineCodeErrorDomain";

@interface QRReaderController () <AVCaptureMetadataOutputObjectsDelegate>
@property (strong, nonatomic) AVCaptureMetadataOutput *metadataOutput;
@property (weak, nonatomic) AVCaptureDeviceInput *activeVideoInput;

@property (strong, nonatomic) dispatch_queue_t videoQueue;
@property(nonatomic,assign) BOOL scanStopped; //扫描已经停止

@end

@implementation QRReaderController

- (NSString *)sessionPreset {
    return AVCaptureSessionPresetHigh;
}

- (BOOL)setupSession:(NSError **)error {
    
#if TARGET_IPHONE_SIMULATOR
    return NO;
#else
    self.captureSession = [[AVCaptureSession alloc] init];
    self.captureSession.sessionPreset = [self sessionPreset];
    
    if (![self setupSessionInputs:error]) {
        return NO;
    }
    
    if (![self setupSessionOutputs:error]) {
        return NO;
    }
    
    self.videoQueue = dispatch_queue_create("com.SouFun.VideoQueue", NULL);
    
    return YES;
#endif
}

- (BOOL)setupSessionInputs:(NSError **)error {
    
    // Set up default camera device
    AVCaptureDevice *videoDevice =
    [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    AVCaptureDeviceInput *videoInput =
    [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:error];
    if (videoInput) {
        if ([self.captureSession canAddInput:videoInput]) {
            [self.captureSession addInput:videoInput];
            self.activeVideoInput = videoInput;
            
            if ([self.activeCamera isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
                if ([self.activeCamera lockForConfiguration:error]) {
                    self.activeCamera.focusMode = AVCaptureFocusModeContinuousAutoFocus;
                    [self.activeCamera unlockForConfiguration];
                }
            }
            
        } else {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey: @"Failed to add video input."};
            *error = [NSError errorWithDomain:SouFunMachineCodeErrorDomain
                                         code:SouFunMachineCodeErrorFailedToAddInput
                                     userInfo:userInfo];
            return NO;
        }
    } else {
        return NO;
    }
    
    return YES;
}

- (BOOL)setupSessionOutputs:(NSError **)error {
    self.metadataOutput = [[AVCaptureMetadataOutput alloc] init];
    
    if ([self.captureSession canAddOutput:self.metadataOutput]) {
        [self.captureSession addOutput:self.metadataOutput];
        
        dispatch_queue_t mainQueue = dispatch_get_main_queue();
        [self.metadataOutput setMetadataObjectsDelegate:self
                                                  queue:mainQueue];
        NSArray *types;
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
            types = @[AVMetadataObjectTypeUPCECode,
                      AVMetadataObjectTypeCode39Code,
                      AVMetadataObjectTypeCode39Mod43Code,
                      AVMetadataObjectTypeEAN13Code,
                      AVMetadataObjectTypeEAN8Code,
                      AVMetadataObjectTypeCode93Code,
                      AVMetadataObjectTypeCode128Code,
                      AVMetadataObjectTypePDF417Code,
                      AVMetadataObjectTypeQRCode,
                      AVMetadataObjectTypeAztecCode,
                      AVMetadataObjectTypeInterleaved2of5Code,
                      AVMetadataObjectTypeITF14Code,
                      AVMetadataObjectTypeDataMatrixCode];
        }else {
            types = @[AVMetadataObjectTypeUPCECode,
                      AVMetadataObjectTypeUPCECode,
                      AVMetadataObjectTypeCode39Mod43Code,
                      AVMetadataObjectTypeEAN13Code,
                      AVMetadataObjectTypeEAN8Code,
                      AVMetadataObjectTypeCode93Code,
                      AVMetadataObjectTypeCode128Code,
                      AVMetadataObjectTypePDF417Code,
                      AVMetadataObjectTypeQRCode,
                      AVMetadataObjectTypeAztecCode];
        }
        
        self.metadataOutput.metadataObjectTypes = types;
        
    } else {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey:
                                       @"Failed to still image output."};
        *error = [NSError errorWithDomain:SouFunMachineCodeErrorDomain
                                     code:SouFunMachineCodeErrorFailedToAddOutput
                                 userInfo:userInfo];
        return NO;
    }
    
    return YES;
}


- (AVCaptureDevice *)activeCamera {
    return self.activeVideoInput.device;
}


- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputMetadataObjects:(NSArray *)metadataObjects
       fromConnection:(AVCaptureConnection *)connection {
    
    //iOS7时，捕获会话停止可能不及时，依旧会收到该代理回调，所以使用该判断
//    if (self.scanStopped) {
//        return;
//    }
    //iOS7时，可能会返回一个空的数组
    if ([metadataObjects count] > 0 ) {
//        [self stopSession];
        [self.codeDetectionDelegate didDetectMachineCodes:metadataObjects];
    }
    
}

- (void)startSession {
#if !TARGET_IPHONE_SIMULATOR
    if (![self.captureSession isRunning]) {
        dispatch_async(self.videoQueue, ^{
            self.scanStopped = NO;
            [self.captureSession startRunning];
        });
    }
#endif
}

- (void)stopSession {
#if !TARGET_IPHONE_SIMULATOR
    if ([self.captureSession isRunning]) {
        self.scanStopped = YES;
        dispatch_async(self.videoQueue, ^{
            [self.captureSession stopRunning];
        });
    }
#endif
}

- (NSString *)readImage:(UIImage *)image{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
        return @"";
    }
    
    NSData *imageData = UIImagePNGRepresentation(image);
    CIImage *ciImage = [CIImage imageWithData:imageData];
    //创建探测器
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy: CIDetectorAccuracyLow}];
    
    NSArray *features = [detector featuresInImage:ciImage];
    //取出探测到的数据
    NSString *contentString;
    for (CIQRCodeFeature *result in features) {
        contentString = result.messageString;
    };
    return contentString;
}

@end
