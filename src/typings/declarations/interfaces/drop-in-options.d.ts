declare module 'cordova-plugin-braintree-sdk' {

  /**
   * Used to configure the presentDropInPaymentUI
   */
  interface DropInOptions {
    /**
     * The client token or tokenization key to use with the Braintree client.
     */
    token: string;

    /**
     * Enable the vaultManager
     */
    vaultManager?: boolean;

    /**
     * Collect additional Device Data in the Request
     * default is true
     */
    collectDeviceData?: boolean;

    /**
     * Disable the Card Option
     */
    disableCard?: boolean;

    /**
     * Set the cardholder-name to be required
     */
    cardHolderNameRequired?: boolean;
  }

}
