declare module 'cordova-plugin-braintree-sdk' {

  /**
   * Used to configure paypalOneTimePayment
   *
   */
  interface PaypalOneTimeOptions {
    /**
     * The client token or tokenization key to use with the Braintree client.
     */
    token: string;

    /**
     * the amount the Transaction should be about
     */
    amount: string;

    /**
     * The currency Code - for example: "USD"
     */
    currencyCode: string;

    /**
     * should the result contains the Device Data?
     * default is true
     */
    collectDeviceData?: boolean;
  }

}
