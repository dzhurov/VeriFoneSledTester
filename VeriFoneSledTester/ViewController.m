//
//  ViewController.m
//  VeriFoneSledTester
//
//  Created by DZhurov on 6/8/15.
//  Copyright (c) 2015 Dmitry Zhurov. All rights reserved.
//

#import "ViewController.h"
#import <VMF/VMFramework.h>

@interface ViewController () <VFIPinpadDelegate>
@property(nonatomic, strong) VFIBarcode *barcode;
@property(nonatomic, strong) VFIControl *control;
@property(nonatomic, strong) VFIPinpad *pinpad;

@property (weak, nonatomic) IBOutlet UITextField *numberTextField;
@property (weak, nonatomic) IBOutlet UIButton *uploadButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

- (IBAction)uploadButtonTapped:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUploadButtonShown:YES];
    
    self.pinpad = [[VFIPinpad alloc] init];
    [self.pinpad logEnabled:YES];
    [self.pinpad setDelegate:self];
    [self.pinpad initDevice];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setUploadButtonShown:(BOOL)shown{
    self.uploadButton.hidden = !shown;
    if (shown)
        [self.activityIndicator stopAnimating];
    else{
        [self.activityIndicator startAnimating];
    }
}

#pragma mark - Actions

- (IBAction)uploadButtonTapped:(id)sender {
    [self setUploadButtonShown:NO];
    NSInteger repeets = self.numberTextField.text.integerValue;
    for (int i = 0; i < repeets; i++) {
        [self configurePinpad];
    }
    [self setUploadButtonShown:YES];
}

#pragma mark - Pirvate

- (void)configurePinpad{
    NSString *certificatesFolder = @"engagetst.tmw.com";
    NSString *certificatePath =     [certificatesFolder stringByAppendingPathComponent:@"XPIPubKey.PEM"];
    NSString *keyIDPath =           [certificatesFolder stringByAppendingPathComponent:@"XPIPubKeyId.DAT"];
    NSString *certificateP7SPath =  [certificatesFolder stringByAppendingPathComponent:@"XPIPubKey.PEM.P7S"];
    NSString *keyIDP7SPath =        [certificatesFolder stringByAppendingPathComponent:@"XPIPubKeyId.DAT.P7S"];
    
    NSString *keyData = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:certificatePath ofType:nil]
                                                        encoding:NSASCIIStringEncoding error:nil];
    NSString *keyId = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:keyIDPath ofType:nil]
                                                      encoding:NSASCIIStringEncoding error:nil];
    NSData *certificateP7S = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:certificateP7SPath ofType:nil]];
    NSData *keyIDP7S = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:keyIDP7SPath ofType:nil]];
    
    NSAssert(keyData, @"keyData is empty!");
    NSAssert(keyId, @"keyId is empty!");
    NSAssert(certificateP7S, @"certificateP7S is empty!");
    NSAssert(keyIDP7S, @"keyIDP7S is empty!");
    
    [self.pinpad enableMSRDualTrack];
    int code ;
    if ((code = [self.pinpad selectEncryptionMode:EncryptionMode_PKI]) != EncryptionMode_PKI) {
        NSLog(@"Error configurePinpad >>>> selectEncryptionMode: = %d", code);
    }
    else if ((code = [self.pinpad loadPKISig:1 p75Data:certificateP7S]) != 0 ){
        NSLog(@"Error configurePinpad >>>> loadPKISig:1 p75Data: = %d", code);
    }
    else if ((code = [self.pinpad loadPKISig:2 p75Data:keyIDP7S]) != 0){
        NSLog(@"Error configurePinpad >>>> loadPKISig:2 p75Data: = %d", code);
    }
    else if ((code = [self.pinpad loadKeyInformation_RSA:keyData publicKeyID:keyId]) != 0){
        NSLog(@"Error configurePinpad >>>> loadKeyInformation_RSA: publicKeyID: = %d", code);
    }
}

#pragma mark - VFIPinpadDelegate

- (void)pinpadReconnectStarted
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)pinpadReconnectFinished
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)pinpadConnected:(BOOL)isConnected
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)pinPadInitialized:(BOOL)isInitialized
{
    NSLog(@"%s %d", __PRETTY_FUNCTION__, isInitialized);
}

- (void)pinpadMSRData:(NSString *)pan expMonth:(NSString *)month expYear:(NSString *)year track1Data:(NSString *)track1 track2Data:(NSString *)track2
{
    [_pinpad getPKICipheredData];
    NSString *fred =  _pinpad.vfiCipheredData.encryptedBlob_1;

#if defined(DEBUG) || defined(RELEASE_TEST)
    NSLog(@"-[MWVeriFoneSledDevice pinpadMSRData:%@ expMonth:%@ expYear:%@ track1Data:%@ track2Data:%@]\nBLOB: %@", pan, month, year, track1, track2, fred);
#else
    NSLog(@"%s", __PRETTY_FUNCTION__);
#endif
}

- (void)pinpadSerialData:(NSData*)data incoming:(BOOL)isIncoming
{
    NSLog(@"- pinpadSerialData:%@ incoming:%d", data, isIncoming);
}

- (void)pinpadLogEntry:(NSString *)logEntry withSeverity:(int)severity
{
    NSLog(@"- pinpadLogEntry:%@ withSeverity:%d", logEntry, severity);
}



@end
