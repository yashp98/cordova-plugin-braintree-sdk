declare module 'cordova-plugin-braintree-sdk' {

  /**
   * Used for every Plugin Error Callback
   */
  interface BraintreeError {
    /**
     * One of the BraintreeErrorCodes
     */
    code: number;

    /**
     * If available some more info (mostly exception message)
     */
    message: string;
  }

}
