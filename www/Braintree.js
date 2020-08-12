var exec = require('cordova/exec');

pluginName = 'BraintreeSdk';

exports.ErrorCodes = {
  TokenRequired: 1,
  FragmentInitializeFailed: 2,
  UserCancelled: 3,
  DropInError: 4,
  UnsupportedAction: 5,
  WrongJsonObject: 6,
  NoExistingPaymentMethod: 7,
  UnknownError: 10
};

exports.presentDropInPaymentUI = function (options, success, error) {
  exec(success, error, pluginName, 'presentDropInPaymentUI', [options]);
};

exports.fetchDropInResult = function (token, success, error) {
  exec(success, error, pluginName, 'fetchDropInResult', [token]);
};

exports.paypalOneTimePayment = function (options, success, error) {
  exec(success, error, pluginName, 'paypalOneTimePayment', [options]);
}

exports.paypalBillingAgreement = function (options, success, error) {
  exec(success, error, pluginName, 'paypalBillingAgreement', [options]);
}
