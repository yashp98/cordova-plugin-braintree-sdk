declare module 'cordova-plugin-braintree-sdk' {

  /**
   * Used to configure paypalBillingAgreement
   *
   */
  interface PaypalBillingAgreementOptions {
    /**
     * The client token or tokenization key to use with the Braintree client.
     */
    token: string;

    /**
     * the locale code
     * Default is "US"
     */
    localeCode?: string;

    /**
     * The Billing Agreement description
     */
    billingAgreementDescription?: string;

    /**
     * should the result contains the Device Data?
     * default is true
     */
    collectDeviceData?: boolean;
  }

}
