declare module 'cordova-plugin-braintree-sdk' {

  interface CardResult {
    lastTwo: string;
    lastFour: string;
    network: string;
    type: string;
  }

  /**
   * Information about the PayPal User
   */
  interface PaypalAccount {
    email: string;
    firstName: string;
    lastName: string;
    phone: string;
    billingAddress: PostalAddress;
    shippingAddress: PostalAddress;
    clientMetadataId: string;
    payerId: string;
  }

  interface VenmoAccount {
    username: string,
  }

  interface PostalAddress {
    recipientName: string;

    /**
     * android only
     */
    phoneNumber: string;
    streetAddress: string;
    extendedAddress: string;
    locality: string;
    region: string;
    postalCode: string;

    /**
     * android only
     */
    sortingCode: string;
    countryCodeAlpha2: string;
  }

  /**
   * The Result of payment Operations with all needed information
   */
  interface PaymentResult {
    nonce: string;
    type: string;
    localizedDescription: string;

    /**
     * only available if collecting is enabled
     */
    deviceData: string;

    /**
     * only available if payment was made via card
     */
    card?: CardResult;

    /**
     * ony available if payment via paypal
     */
    paypalAccount?: PaypalAccount;

    /**
     * only available if payment via venmo
     */
    venmoAccount?: VenmoAccount;
  }

}
