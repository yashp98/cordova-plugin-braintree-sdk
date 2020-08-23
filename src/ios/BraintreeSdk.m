#import "BraintreeSdk.h"

@implementation BraintreeSdk {
    enum {
        TokenRequired=1,
        FragmentInitializeFailed=2,
        UserCancelled=3,
        DropInError=4,
        UnsupportedAction=5,
        WrongJsonObject=6,
        NoExistingPaymentMethod=7,
        UnknownError=10
    } ErrorCodes;
}

@synthesize _callbackId;

static NSString * const TAG = @"[BraintreeSdk] ";

- (void)pluginInitialize
{
    [self log:@"pluginInitialize"];
    // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleOpenURL:) name:@"flicApp" object:nil];
}

- (void) presentDropInPaymentUI:(CDVInvokedUrlCommand*)command
{
    [self log:@"presentDropInPaymentUI"];
    _callbackId = command.callbackId;

    @try {
        NSDictionary *options = [command.arguments objectAtIndex:0];
        NSString *token = [options objectForKey:@"token"];

        if(!token) {
            [self returnError:TokenRequired];
            return;
        }
        BOOL vaultManager = [[options objectForKey:@"vaultManager"] boolValue];
        BOOL collectDeviceData = [[options objectForKey:@"collectDeviceData"] boolValue] ?: true;
        BOOL disableCard = [[options objectForKey:@"disableCard"] boolValue];
        BOOL cardHolderNameRequired = [[options objectForKey:@"cardHolderNameRequired"] boolValue];

        BTDropInRequest *request = [[BTDropInRequest alloc] init];
        request.vaultManager = vaultManager;
        if(disableCard) {
            request.cardDisabled = true;
        } else {
            request.cardholderNameSetting = cardHolderNameRequired ? BTFormFieldRequired : BTFormFieldOptional;
        }

        BTDropInController *dropIn = [[BTDropInController alloc] initWithAuthorization:token request:request handler:^(BTDropInController * _Nonnull controller, BTDropInResult * _Nullable result, NSError * _Nullable error) {

            [self.viewController dismissViewControllerAnimated:YES completion:nil];

            if (error != nil) {
                [self returnError:UnknownError andMessage:error.localizedDescription];
            } else if (result.cancelled) {
                [self returnError:UserCancelled];
            } else {
                if (result.paymentOptionType == BTUIKPaymentOptionTypeApplePay ) {
                    //                    PKPaymentRequest *apPaymentRequest = [[PKPaymentRequest alloc] init];
                    //                    apPaymentRequest.paymentSummaryItems = @[
                    //                                                             [PKPaymentSummaryItem summaryItemWithLabel:primaryDescription amount:[NSDecimalNumber decimalNumberWithString: amount]]
                    //                                                             ];
                    //                    apPaymentRequest.supportedNetworks = @[PKPaymentNetworkVisa, PKPaymentNetworkMasterCard, PKPaymentNetworkAmex, PKPaymentNetworkDiscover];
                    //                    apPaymentRequest.merchantCapabilities = PKMerchantCapability3DS;
                    //                    apPaymentRequest.currencyCode = currencyCode;
                    //                    apPaymentRequest.countryCode = countryCode;
                    //
                    //                    apPaymentRequest.merchantIdentifier = applePayMerchantID;
                    //
                    //                    if ((PKPaymentAuthorizationViewController.canMakePayments) && ([PKPaymentAuthorizationViewController canMakePaymentsUsingNetworks:apPaymentRequest.supportedNetworks])) {
                    //                        PKPaymentAuthorizationViewController *viewController = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:apPaymentRequest];
                    //                        viewController.delegate = self;
                    //
                    //                        applePaySuccess = NO;
                    //
                    //                        /* display ApplePay ont the rootViewController */
                    //                        UIViewController *rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
                    //
                    //                        [rootViewController presentViewController:viewController animated:YES completion:nil];
                    //                    } else {
                    //                        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"ApplePay cannot be used."];
                    //
                    //                        [self.commandDelegate sendPluginResult:pluginResult callbackId:dropInUIcallbackId];
                    //                        dropInUIcallbackId = nil;
                    //                    }
                } else {
                    [self handleNonceResult:result.paymentMethod andToken:token andCollectDeviceData:collectDeviceData andPPDataCollector:false];
                }
            }
        }];
        [self.viewController presentViewController:dropIn animated:YES completion:nil];

    } @catch (NSException *exception) {
        [self handleCallbackException:exception];
    }
}

- (void) fetchDropInResult:(CDVInvokedUrlCommand*) command
{
    [self log:@"fetchDropInResult"];
    _callbackId = command.callbackId;

    @try {
        NSString *token = [command.arguments objectAtIndex:0];

        if(!token) {
            [self returnError:TokenRequired];
            return;
        }

        [BTDropInResult fetchDropInResultForAuthorization:token handler:^(BTDropInResult * _Nullable result, NSError * _Nullable error) {
            if (error != nil) {
                [self returnError:NoExistingPaymentMethod andMessage:error.localizedDescription];
            } else {
                // Use the BTDropInResult properties to update your UI
                // TODO
                UIView* selectedPaymentMethodIcon = result.paymentIcon;
                NSString* selectedPaymentMethodDescription = result.paymentDescription;
            }
        }];
    } @catch (NSException *exception) {
        [self handleCallbackException:exception];
    }
}

- (void) paypalOneTimePayment:(CDVInvokedUrlCommand*) command
{
    [self log:@"paypalOneTimePayment"];
    _callbackId = command.callbackId;

    @try {
        NSDictionary *options = [command.arguments objectAtIndex:0];
        NSString *token = [options objectForKey:@"token"];
        NSString *amount = [options objectForKey:@"amount"];
        NSString *currencyCode = [options objectForKey:@"currencyCode"];
        BOOL collectDeviceData = [[options objectForKey:@"collectDeviceData"] boolValue] ?: true;

        if(!token) {
            [self returnError:TokenRequired];
            return;
        }
        if(!amount || !currencyCode) {
            [self returnError:WrongJsonObject];
            return;
        }

        BTAPIClient *braintreeClient = [[BTAPIClient alloc] initWithAuthorization:token];
        BTPayPalDriver *payPalDriver = [[BTPayPalDriver alloc] initWithAPIClient:braintreeClient];
        // payPalDriver.viewControllerPresentingDelegate = self.viewController;
        // payPalDriver.appSwitchDelegate = self.viewController; // Optional

        // Start the Checkout flow
        BTPayPalRequest *request = [[BTPayPalRequest alloc] initWithAmount:amount];
        request.currencyCode = currencyCode;
        [payPalDriver requestOneTimePayment:request
                                 completion:^(BTPayPalAccountNonce *tokenizedPayPalAccount, NSError *error) {
            if(error != nil) {
                [self returnError:UnknownError andMessage:error.localizedDescription];
            } else if(tokenizedPayPalAccount == nil) {
                [self returnError:UserCancelled];
            } else {
                [self handleNonceResult:tokenizedPayPalAccount andToken:token andCollectDeviceData:collectDeviceData andPPDataCollector:false];
            }
        }];
    } @catch (NSException *exception) {
        [self handleCallbackException:exception];
    }
}

- (void) paypalBillingAgreement:(CDVInvokedUrlCommand*) command
{
    [self log:@"paypalBillingAgreement"];
    _callbackId = command.callbackId;

    @try {
        NSDictionary *options = [command.arguments objectAtIndex:0];
        NSString *token = [options objectForKey:@"token"];

        if(!token) {
            [self returnError:TokenRequired];
            return;
        }

        NSString *localeCode = [options objectForKey:@"localeCode"] ?: @"US";
        NSString *billingAgreementDescription = [options objectForKey:@"billingAgreementDescription"];
        BOOL collectDeviceData = [[options objectForKey:@"collectDeviceData"] boolValue] ?: true;

        BTAPIClient *braintreeClient = [[BTAPIClient alloc] initWithAuthorization:token];
        BTPayPalDriver *payPalDriver = [[BTPayPalDriver alloc] initWithAPIClient:braintreeClient];
        // payPalDriver.viewControllerPresentingDelegate = self;
        // payPalDriver.appSwitchDelegate = self; // Optional

        BTPayPalRequest *checkout = [[BTPayPalRequest alloc] init];
        checkout.localeCode = localeCode;
        if(billingAgreementDescription != nil) {
            checkout.billingAgreementDescription = billingAgreementDescription;
        }
        checkout.billingAgreementDescription = @"Your agreement description";
        [payPalDriver requestBillingAgreement:checkout completion:^(BTPayPalAccountNonce * _Nullable tokenizedPayPalCheckout, NSError * _Nullable error) {
            if (error != nil) {
                [self returnError:UnknownError andMessage:error.localizedDescription];
            } else if (tokenizedPayPalCheckout == nil) {
               [self returnError:UserCancelled];
            } else {
                if(collectDeviceData) {
                    [self handleNonceResult:tokenizedPayPalCheckout andToken:token andCollectDeviceData:collectDeviceData andPPDataCollector:true];
                }
            }
        }];

    } @catch (NSException *exception) {
        [self handleCallbackException:exception];
    }
}

- (void) handleNonceResult:(BTPaymentMethodNonce*)paymentNonce andToken:(NSString*)token andCollectDeviceData:(BOOL)collectDeviceData andPPDataCollector:(BOOL)ppDataCollector
{
    if(collectDeviceData) {
        if(ppDataCollector) {
            NSString *deviceData = [PPDataCollector collectPayPalDeviceData];
            NSDictionary *dictionary = [self getPaymentUINonceResult:paymentNonce andDeviceData:deviceData];

            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dictionary];

            [self.commandDelegate sendPluginResult:pluginResult callbackId:self->_callbackId];
            self->_callbackId = nil;
        } else {
            BTAPIClient *apiClient = [[BTAPIClient alloc] initWithAuthorization:token];
            BTDataCollector *dataCollector = [[BTDataCollector alloc] initWithAPIClient:apiClient];
            [dataCollector collectDeviceData:^(NSString * _Nonnull deviceData) {
                NSDictionary *dictionary = [self getPaymentUINonceResult:paymentNonce andDeviceData:deviceData];

                CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dictionary];

                [self.commandDelegate sendPluginResult:pluginResult callbackId:self->_callbackId];
                self->_callbackId = nil;
            }];
        }
    } else {
        NSDictionary *dictionary = [self getPaymentUINonceResult:paymentNonce andDeviceData:[NSNull null]];

        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dictionary];

        [self.commandDelegate sendPluginResult:pluginResult callbackId:self->_callbackId];
        self->_callbackId = nil;
    }
}

- (void) handleCallbackException:(NSException*)exception
{
    if([exception.name isEqualToString:@"NSRangeException"]) {
        [self returnError:WrongJsonObject];
    } else {
        [self returnError:UnknownError andMessage:exception.reason];
    }
}

- (void) returnError:(int)errorCode
{
    [self returnError:errorCode andMessage:nil];
}

- (void) returnError:(int)errorCode andMessage:(NSString *)message
{
    if(_callbackId) {
        NSDictionary *dictionary = @{@"code": [NSNumber numberWithInt:errorCode],
                                     @"message": message ?: @""
        };
        CDVPluginResult *res = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:dictionary];
        [self.commandDelegate sendPluginResult:res callbackId:_callbackId];
        return;
    }
}

- (void) log:(NSString *)text
{
    NSLog(@"%@%@", TAG, text);
}

#pragma mark - Helpers
/**
 * Helper used to return a dictionary of values from the given payment method nonce.
 * Handles several different types of nonces (eg for cards, Apple Pay, PayPal, etc).
 */
- (NSDictionary*)getPaymentUINonceResult:(BTPaymentMethodNonce *)paymentMethodNonce andDeviceData:(NSString*)deviceData {

    BTCardNonce *cardNonce;
    BTPayPalAccountNonce *payPalAccountNonce;
    BTApplePayCardNonce *applePayCardNonce;
    BTVenmoAccountNonce *venmoAccountNonce;

    if ([paymentMethodNonce isKindOfClass:[BTCardNonce class]]) {
        cardNonce = (BTCardNonce*)paymentMethodNonce;
    }

    if ([paymentMethodNonce isKindOfClass:[BTPayPalAccountNonce class]]) {
        payPalAccountNonce = (BTPayPalAccountNonce*)paymentMethodNonce;
    }

    if ([paymentMethodNonce isKindOfClass:[BTApplePayCardNonce class]]) {
        applePayCardNonce = (BTApplePayCardNonce*)paymentMethodNonce;
    }

    if ([paymentMethodNonce isKindOfClass:[BTVenmoAccountNonce class]]) {
        venmoAccountNonce = (BTVenmoAccountNonce*)paymentMethodNonce;
    }

    NSDictionary *dictionary = @{ // Standard Fields
        @"nonce": paymentMethodNonce.nonce,
        @"type": paymentMethodNonce.type,
        @"localizedDescription": paymentMethodNonce.localizedDescription,
        @"deviceData": deviceData,

        // BTCardNonce Fields
        @"card": !cardNonce ? [NSNull null] : @{
                @"lastTwo": cardNonce.lastTwo,
                @"lastFour": cardNonce.lastFour,
                @"type": cardNonce.type,
                @"network": [self formatCardNetwork:cardNonce.cardNetwork]
        },

        // BTPayPalAccountNonce
        @"payPalAccount": !payPalAccountNonce ? [NSNull null] : @{
                @"email": payPalAccountNonce.email,
                @"firstName": (payPalAccountNonce.firstName ?: [NSNull null]),
                @"lastName": (payPalAccountNonce.lastName ?: [NSNull null]),
                @"phone": (payPalAccountNonce.phone ?: [NSNull null]),
                @"billingAddress": [self parseAddress:payPalAccountNonce.billingAddress],
                @"shippingAddress": [self parseAddress:payPalAccountNonce.shippingAddress],
                @"clientMetadataId":  (payPalAccountNonce.clientMetadataId ?: [NSNull null]),
                @"payerId": (payPalAccountNonce.payerId ?: [NSNull null]),
        },

        // BTApplePayCardNonce
        @"applePayCard": !applePayCardNonce ? [NSNull null] : @{
        },

        // BTVenmoAccountNonce Fields
        @"venmoAccount": !venmoAccountNonce ? [NSNull null] : @{
                @"username": venmoAccountNonce.username
        }
    };
    return dictionary;
}

- (NSDictionary*) parseAddress:(BTPostalAddress *) address
{
    NSDictionary *dictonary = @{
        @"recipientName": address.recipientName ?: [NSNull null],
        @"streetAddress": address.streetAddress ?: [NSNull null],
        @"extendedAddress": address.extendedAddress ?: [NSNull null],
        @"locality": address.locality ?: [NSNull null],
        @"region": address.region ?: [NSNull null],
        @"postalCode": address.postalCode ?: [NSNull null],
        @"countryCodeAlpha2": address.countryCodeAlpha2 ?: [NSNull null],
    };

    return dictonary;
}

/**
 * Helper used to provide a string value for the given BTCardNetwork enumeration value.
 */
- (NSString*)formatCardNetwork:(BTCardNetwork)cardNetwork {
    NSString *result = nil;

    // TODO: This method should probably return the same values as the Android plugin for consistency.

    switch (cardNetwork) {
        case BTCardNetworkUnknown:
            result = @"BTCardNetworkUnknown";
            break;
        case BTCardNetworkAMEX:
            result = @"BTCardNetworkAMEX";
            break;
        case BTCardNetworkDinersClub:
            result = @"BTCardNetworkDinersClub";
            break;
        case BTCardNetworkDiscover:
            result = @"BTCardNetworkDiscover";
            break;
        case BTCardNetworkMasterCard:
            result = @"BTCardNetworkMasterCard";
            break;
        case BTCardNetworkVisa:
            result = @"BTCardNetworkVisa";
            break;
        case BTCardNetworkJCB:
            result = @"BTCardNetworkJCB";
            break;
        case BTCardNetworkLaser:
            result = @"BTCardNetworkLaser";
            break;
        case BTCardNetworkMaestro:
            result = @"BTCardNetworkMaestro";
            break;
        case BTCardNetworkUnionPay:
            result = @"BTCardNetworkUnionPay";
            break;
        case BTCardNetworkSolo:
            result = @"BTCardNetworkSolo";
            break;
        case BTCardNetworkSwitch:
            result = @"BTCardNetworkSwitch";
            break;
        case BTCardNetworkUKMaestro:
            result = @"BTCardNetworkUKMaestro";
            break;
        default:
            result = nil;
    }

    return result;
}

@end
