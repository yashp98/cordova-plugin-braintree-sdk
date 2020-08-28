# Braintree Cordova Plugin
![Maintenance](https://img.shields.io/maintenance/yes/2020)

This [Cordova](https://cordova.apache.org) Plugin is a Wrapper for [Braintree](https://www.braintreepayments.com/).

It currently uses Version `4.35.0` (iOS) and `3.13.0` (Android) of the Braintree Mobile SDK. The Braintree process
is not very easy, so before start using this Plugin you should read (and understand) their [Documentation](https://developers.braintreepayments.com/start/overview). 

**This Plugin is still in development & should only used in production after testing!**

<!-- DONATE -->
[![Donate](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG_global.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=LMX5TSQVMNMU6&source=url)

This and other Open-Source Cordova Plugins are developed in my free time.
To help ensure this plugin is kept updated, new features are added and bugfixes are implemented quickly, please donate a couple of dollars (or a little more if you can stretch) as this will help me to afford to dedicate time to its maintenance.
Please consider donating if you're using this plugin in an app that makes you money, if you're being paid to make the app, if you're asking for new features or priority bug fixes.
<!-- END DONATE -->

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Content**

- [Note](#note)
- [Install](#install)
  - [General Requirements](#general-requirements)
  - [Android](#android)
  - [iOS](#ios)
- [Environment Variables](#environment-variables)
  - [Android](#android-1)
- [Usage](#usage)
  - [Failure Callbacks](#failure-callbacks)
  - [Error Codes](#error-codes)
- [Api](#api)
  - [Both](#both)
    - [presentDropInPaymentUI](#presentdropinpaymentui)
    - [fetchDropInResult](#fetchdropinresult)
    - [paypalOneTimePayment](#paypalonetimepayment)
    - [paypalBillingAgreement](#paypalbillingagreement)
- [Data Models](#data-models)
  - [PaymentUINonceResult](#paymentuinonceresult)
  - [CardNonce](#cardnonce)
  - [PayPalAccountNonce](#paypalaccountnonce)
  - [VenmoAccount](#venmoaccount)
  - [Postal Address](#postal-address)
- [Changelog](#changelog)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Note

This Plugin in still in development and not ready for production yet.
If you want to help me develop this Plugin, please read this carefully.
If you found any issues, you can report them [here](https://github.com/EinfachHans/cordova-plugin-braintree-sdk/issues).

# Install

## General Requirements

- Cordova-lib: `>= 9`

## Android
Because this Plugin uses the latest Braintree SDK, which is based on [AndroidX](https://developer.android.com/jetpack/androidx) and **AppCompatActivity**,
it requires a [cordova-android](https://github.com/apache/cordova-android) Version `>= todo`.
As [this Change](https://github.com/apache/cordova-android/issues/841) is not done yet, you currently only can use this if you use my Fork of `cordova-android` like this:

```shell script
cordova platform add android@https://github.com/EinfachHans/cordova-android.git#appcompat
```

This fork is based on `cordova-android9.0.0`.

Also `AndroidXEnabled` must be set to **true** via: 
```xml
<preference name="AndroidXEnabled" value="true"/>
```

## iOS

I developed/tested this Plugin with a [cordova-ios](https://github.com/apache/cordova-ios) version `6.1.0`.
If you are using another Version and think this cause Errors please [open an Issue](https://github.com/EinfachHans/cordova-plugin-braintree-sdk/issues) and we will out together what the problem is and how you can solve it.

# Environment Variables

## Android

- ANDROID_CARD_IO_VERSION - Version of `io.card:android-sdk` / default to `5.+` 

# Usage

The plugin is available via a global variable named `window.Braintree`.
A TypeScript definition is included out of the Box. You can import it like this:
```ts
import Braintree from 'cordova-plugin-braintree-sdk';
```

## Failure Callbacks

If an Error appeared this Plugin returns an Object in the failureCallback, that always has the following Structure:

```json
{
  "code": 0,
  "message": "Some additional Info"
}
```

The `code` is one of the [Error Codes](#error-codes) and always present, while the `message` can be empty.
This is mostly something like an Exception Message.

## Error Codes

The following Error Codes can be fired by this Plugin:
- TokenRequired
- FragmentInitializeFailed
- UserCancelled
- DropInError
- UnsupportedAction
- WrongJsonObject
- NoExistingPaymentMethod
- UnknownError

They can be accessed over for Example `window.Braintree.ErrorCodes.TokenRequired` and are present in the TypeScript definition too of course. 

# Api

The list of available methods for this plugin is described below.
If not other described in the methode, every Methode required a success and failure callbacks as their last two arguments:
- success (function) - callback function which will be invoked on success (See methods for objects type)
- error (function) - callback function which will be passed a [Error Object](#failure-callbacks) as an argument 

## Both

The following methods are available for Android and iOS. 

### presentDropInPaymentUI

Opens the Braintree's DropIn UI

#### Parameters:
- options (object) - a JSON-Object containing the following Elements:
    - token (string) **required**
    - vaultManager (boolean) **optional. default: false**
    - collectDeviceData (boolean) **optional. default: true**
    - disableCard (boolean) **optional. default: false**
    - cardHolderNameRequired (boolean) **optional. default: false**

```js
window.Braintree.presentDropInPaymentUI({
  token: 'your_token'
}, function(success) {
  console.log(success);
}, function (error) {
  console.error(error);
});
```
#### SuccessType:

This Methode returns an [PaymentUiNonceResult](#paymentuinonceresult)

### fetchDropInResult

If your user already has an existing payment method, you may not need to show Drop-In. You can check if they have an existing payment method using this Method.
Note that a payment method will only be returned when using a client token created with a customer_id.

#### Parameters:
- token (string) **required**

```js
window.Braintree.fetchDropInResult('your_client_token', function(success) {
  console.log(success);
}, function(error) {
  console.error(error);
})
```

This Method is still in progress and not production ready

### paypalOneTimePayment

Requests an OneTime PayPal Payment

#### Parameters:
- options (object) - a JSON-Object containing the following Elements:
    - token (string) **required**
    - amount (string) **required**
    - currencyCode (string) **required**
    - collectDeviceData (boolean) **optional, default: true**
    
```js
window.Braintree.paypalOneTimePayment({
  token: 'your_token',
  amount: '10',
  currencyCode: 'USD'
}, function (success) {
  console.log(success);
}, function (error) {
  console.error(error)
});
```

#### SuccessType:

This Methode returns an [PaymentUiNonceResult](#paymentuinonceresult)

### paypalBillingAgreement

Requests a PayPal Billing Agreement

#### Parameters:
- options (object) - a JSON-Object containing the following Elements:
    - token (string) **required**
    - localeCode (string) **optional, default: "US"**
    - billingAgreementDescription (string) **optional**
    - collectDeviceData (boolean) **optional, default: true**
    
```js
window.Braintree.paypalBillingAgreement({
  token: 'your_token',
  localeCode: 'DE'
}, function (success) {
  console.log(success);
}, function (error) {
  console.error(error)
});
```

#### SuccessType:

This Methode returns an [PaymentUiNonceResult](#paymentuinonceresult)

# Data Models

## PaymentUINonceResult

- nonce (string)
- type (string)
- localizedDescription (string)
- deviceData (string) - Only available if collecting device data is enabled
- card ([CardNonce](#cardnonce)) - Only available if payment was via card
- paypalAccount ([PayPalAccountNonce](#paypalaccountnonce)) - Only available if payment via PayPal
- venmoAccount ([VenmoAccount](#venmoaccount)) - Only available if payment via Venmo

## CardNonce

- lastTwo (string)
- lastFour (string)
- network (string)
- type (string)

## PayPalAccountNonce

- email (string)
- firstName (string)
- lastName (string)
- phone (string)
- billingAddress ([PostalAddress](#postal-address))
- shippingAddress ([PostalAddress](#postal-address))
- clientMetadataId (string)
- payerId (string)

## VenmoAccount

- username (string)

## Postal Address

- recipientName (string)
- phoneNumber (string) **Android only**
- streetAddress (string)
- extendedAddress (string)
- locality (string)
- region (string)
- postalCode (string)
- sortingCode (string) **Android only**
- countryCodeAlpha2 (string)

# Changelog

The full Changelog is available [here](CHANGELOG.md)
