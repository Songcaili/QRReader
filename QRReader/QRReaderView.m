//
//  QRReaderView.m
//  QRReader
//
//  Created by 宋来 on 2017/3/29.
//  Copyright © 2017年 宋来. All rights reserved.
//

#import "QRReaderView.h"

@interface QRReaderView ()

@property (strong, nonatomic) CAShapeLayer *boundsLayer;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property(nonatomic,strong) QRReaderController *mcController;
@property(nonatomic,assign) BOOL setupSessionFailed;

@end

@implementation QRReaderView

+ (Class)layerClass {
    return [AVCaptureVideoPreviewLayer class];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
        [self setupMcController];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setupView];
        [self setupMcController];
    }
    return self;
}

- (void)setupView {
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
}

- (void)setupMcController {
    self.mcController = [[QRReaderController alloc] init];
    NSError *error;
    
    if ([self.mcController setupSession:&error]) {
        
        [self setSession:self.mcController.captureSession];
        self.mcController.codeDetectionDelegate = self;
        
        [self.mcController startSession];
    } else {
        self.setupSessionFailed = YES;
        NSLog(@"Error: %@", [error localizedDescription]);
    }
}

- (AVCaptureSession*)session {
    return self.previewLayer.session;
}

- (void)setSession:(AVCaptureSession *)session {
    self.previewLayer.session = session;
}

- (AVCaptureVideoPreviewLayer *)previewLayer {
    return (AVCaptureVideoPreviewLayer *)self.layer;
}

- (void)start {
    if (self.setupSessionFailed) {
        return;
    }
    if (self.boundsLayer) {
        [self.boundsLayer removeFromSuperlayer];
        self.boundsLayer = nil;
    }
    [self.mcController startSession];
}

- (void)stop {
    if (self.setupSessionFailed) {
        return;
    }
    [self.mcController stopSession];
}

- (void)didDetectMachineCodes:(NSArray *)codes {
    
    NSArray *transformedCodes = [self transformedCodesFromCodes:codes];
    
    AVMetadataMachineReadableCodeObject *code = [transformedCodes firstObject];
    
    NSString *stringValue = code.stringValue;
    
    if (self.boundsLayer) {
        [self.boundsLayer removeFromSuperlayer];
        self.boundsLayer = nil;
    }
    //    self.boundsLayer = [self makeBoundsLayer];
    //
    //    [self.previewLayer addSublayer:_boundsLayer];
    //
    //    self.boundsLayer.path  = [self bezierPathForBounds:code.bounds].CGPath;
    //    self.boundsLayer.hidden = NO;
    
//    self.boundsLayer = [self makeCornersLayer];
//    [self.previewLayer addSublayer:_boundsLayer];
//    self.boundsLayer.path = [self bezierPathForCorners:code.corners].CGPath;
//    self.boundsLayer.hidden = NO;
    
    [self.delegate machineCodeDidReadString:stringValue];
}

- (NSArray *)transformedCodesFromCodes:(NSArray *)codes {
    NSMutableArray *transformedCodes = [NSMutableArray array];
    for (AVMetadataObject *code in codes) {
        AVMetadataObject *transformedCode =
        [self.previewLayer transformedMetadataObjectForMetadataObject:code];
        [transformedCodes addObject:transformedCode];
    }
    return transformedCodes;
}

- (UIBezierPath *)bezierPathForBounds:(CGRect)bounds {
    return [UIBezierPath bezierPathWithRect:bounds];
}

- (UIBezierPath *)bezierPathForCorners:(NSArray *)corners {
    UIBezierPath *path = [UIBezierPath bezierPath];
    for (int i = 0; i < corners.count; i++) {
        CGPoint point = [self pointForCorner:corners[i]];
        if (i == 0) {
            [path moveToPoint:point];
        } else {
            [path addLineToPoint:point];
        }
    }
    [path closePath];
    return path;
}

- (CGPoint)pointForCorner:(NSDictionary *)corner {
    CGPoint point;
    CGPointMakeWithDictionaryRepresentation((CFDictionaryRef)corner, &point);
    return point;
}

- (CAShapeLayer *)makeBoundsLayer {
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.strokeColor =
    [UIColor colorWithRed:0.95f green:0.75f blue:0.06f alpha:1.0f].CGColor;
    shapeLayer.fillColor = nil;
    shapeLayer.lineWidth = 4.0f;
    return shapeLayer;
}

- (CAShapeLayer *)makeCornersLayer {
    CAShapeLayer *cornersLayer = [CAShapeLayer layer];
    cornersLayer.lineWidth = 2.0f;
    cornersLayer.strokeColor =
    [UIColor colorWithRed:0.172 green:0.671 blue:0.428 alpha:1.000].CGColor;
    cornersLayer.fillColor =
    [UIColor colorWithRed:0.190 green:0.753 blue:0.489 alpha:0.500].CGColor;
    
    return cornersLayer;
}

@end
