/// <reference path="./interfaces/drop-in-options.d.ts" />
/// <reference path="./interfaces/error.d.ts" />
/// <reference path="./interfaces/payment-result.d.ts" />
/// <reference path="./interfaces/paypal-one-time-options.d.ts" />
/// <reference path="./interfaces/paypal-billing-agreement-options.d.ts" />

declare module 'cordova-plugin-braintree-sdk' {

  export default class Braintree {

    /**
     * Available Error Codes
     */
    static ErrorCodes: {
      TokenRequired,
      FragmentInitializeFailed,
      UserCancelled,
      DropInError,
      UnsupportedAction,
      WrongJsonObject,
      NoExistingPaymentMethod,
      UnknownError
    };

    /**
     * Present Braintree's Drop-In UI
     *
     * @param options Configurable options
     * @param success Success Callback
     * @param error Error Callback
     */
    static presentDropInPaymentUI(options: DropInOptions, success: (result: PaymentResult) => void, error: (error: BraintreeError) => void): void;

    /**
     * get latest saved Drop In Payment
     *
     * @param token The client token to use with the Braintree client.
     * @param success Success Callback
     * @param error Error Callback
     */
    static fetchDropInResult(token: string, success: (result: any) => void, error: (error: BraintreeError) => void): void;

    /**
     * Request a OneTime Payment via PayPal
     *
     * @param options Configurable options
     * @param success Success Callback
     * @param error Error Callback
     */
    static paypalOneTimePayment(options: PaypalOneTimeOptions, success: (result: PaymentResult) => void, error: (error: BraintreeError) => void): void;

    /**
     * Request a Billing Agreement via PayPal
     *
     * @param options Configurable options
     * @param success Success Callback
     * @param error Error Callback
     */
    static paypalBillingAgreement(options: PaypalBillingAgreementOptions, success: (result: PaymentResult) => void, error: (error: BraintreeError) => void): void;
  }
}
