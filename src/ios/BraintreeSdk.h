#import <Cordova/CDVPlugin.h>
#import "BraintreeCore.h"
#import "BraintreeDropIn.h"
#import "BraintreeCard.h"
#import "BraintreeDataCollector.h"
#import "BraintreeVenmo.h"
#import "Braintree3DSecure.h"
#import "BraintreePayPal.h"
#import "BraintreeApplePay.h"
#import "PayPalDataCollector.h"

@interface BraintreeSdk: CDVPlugin

@property (nonatomic, strong) NSString *_callbackId;

- (void) presentDropInPaymentUI:(CDVInvokedUrlCommand*)command;
- (void) fetchDropInResult:(CDVInvokedUrlCommand*) command;
- (void) paypalOneTimePayment:(CDVInvokedUrlCommand*) command;
- (void) paypalBillingAgreement:(CDVInvokedUrlCommand*) command;
- (void) handleNonceResult:(BTPaymentMethodNonce*)paymentNonce andToken:(NSString*)token andCollectDeviceData:(BOOL)collectDeviceData andPPDataCollector:(BOOL)ppDataCollector;
- (void) handleCallbackException:(NSException*)exception;
- (void) returnError:(int)errorCode;
- (void) returnError:(int)errorCode andMessage:(NSString *)message;
- (void) log:(NSString *)text;
- (NSDictionary*)getPaymentUINonceResult:(BTPaymentMethodNonce *)paymentMethodNonce andDeviceData:(NSString*)deviceData;
- (NSDictionary*) parseAddress:(BTPostalAddress *) address;
- (NSString*)formatCardNetwork:(BTCardNetwork)cardNetwork;

@end
