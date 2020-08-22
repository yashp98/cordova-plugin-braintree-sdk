var plugin = function () {
  return window.Braintree || {};
};
var Braintree = /** @class */ (function () {
  function Braintree() {
  }

  Braintree.ErrorCodes = plugin().ErrorCodes;

  Braintree.presentDropInPaymentUI = function (options, success, failure) {
    var plu = plugin();
    return plu.presentDropInPaymentUI.apply(plu, arguments);
  };

  Braintree.fetchDropInResult = function (token, success, failure) {
    var plu = plugin();
    return plu.fetchDropInResult.apply(plu, arguments);
  };

  Braintree.paypalOneTimePayment = function (options, success, failure) {
    var plu = plugin();
    return plu.paypalOneTimePayment.apply(plu, arguments);
  };

  Braintree.paypalBillingAgreement = function (options, success, failure) {
    var plu = plugin();
    return plu.paypalBillingAgreement.apply(plu, arguments);
  };

  return Braintree;
}());
export default Braintree;
