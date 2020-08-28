package de.einfachhans.Braintree;

import android.content.Intent;
import android.util.Log;

import androidx.appcompat.app.AppCompatActivity;

import com.braintreepayments.api.BraintreeFragment;
import com.braintreepayments.api.DataCollector;
import com.braintreepayments.api.PayPal;
import com.braintreepayments.api.dropin.DropInActivity;
import com.braintreepayments.api.dropin.DropInRequest;
import com.braintreepayments.api.dropin.DropInResult;
import com.braintreepayments.api.dropin.utils.PaymentMethodType;
import com.braintreepayments.api.interfaces.BraintreeCancelListener;
import com.braintreepayments.api.interfaces.BraintreeErrorListener;
import com.braintreepayments.api.interfaces.PaymentMethodNonceCreatedListener;
import com.braintreepayments.api.models.CardNonce;
import com.braintreepayments.api.models.PayPalAccountNonce;
import com.braintreepayments.api.models.PayPalRequest;
import com.braintreepayments.api.models.PaymentMethodNonce;
import com.braintreepayments.api.models.PostalAddress;
import com.braintreepayments.api.models.VenmoAccountNonce;
import com.braintreepayments.cardform.view.CardForm;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.Map;

/**
 * This class echoes a string called from JavaScript.
 */
public class BraintreeSdk extends CordovaPlugin implements BraintreeErrorListener {

    private static final String TAG = "BraintreePlugin";

    private static final int DROP_IN_REQUEST = 100;
    private static final int PAYMENT_BUTTON_REQUEST = 200;
    private static final int CUSTOM_REQUEST = 300;
    private static final int PAYPAL_REQUEST = 400;

    private CallbackContext _callbackContext;

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) {
        _callbackContext = callbackContext;

        try {
            if (action.equals("presentDropInPaymentUI")) {
                this.presentDropInPaymentUI(args);
            } else if(action.equals("fetchDropInResult")) {
                this.fetchDropInResult(args);
            } else if (action.equals("paypalOneTimePayment")) {
                this.paypalOneTimePayment(args);
            } else if (action.equals("paypalBillingAgreement")) {
                this.paypalBillingAgreement(args);
            } else if (action.equals("setupApplePay")) {
                this.setupApplePay();
            } else {
                // The given action was not handled above.
                return false;
            }
        } catch (JSONException exception) {
            returnError(BraintreeErrorCodes.WrongJsonObject);
        } catch (Exception exception) {
            returnError(BraintreeErrorCodes.UnknownError, exception.getMessage());
        }

        return true;
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent intent) {
        super.onActivityResult(requestCode, resultCode, intent);

        Log.i(TAG, "DropIn Activity Result: " + requestCode + ", " + resultCode);

        if (_callbackContext == null) {
            Log.e(TAG, "onActivityResult exiting ==> callbackContext is invalid");
            return;
        }

        if (requestCode == DROP_IN_REQUEST) {

            PaymentMethodNonce paymentMethodNonce = null;
            String deviceData = null;

            if (resultCode == AppCompatActivity.RESULT_OK) {
                DropInResult result = intent.getParcelableExtra(DropInResult.EXTRA_DROP_IN_RESULT);
                paymentMethodNonce = result.getPaymentMethodNonce();
                deviceData = result.getDeviceData();

                Log.i(TAG, "DropIn Activity Result: paymentMethodNonce = " + paymentMethodNonce);
            }

            // handle errors here, an exception may be available in
            if (intent != null && intent.getSerializableExtra(DropInActivity.EXTRA_ERROR) != null) {
                Exception error = (Exception) intent.getSerializableExtra(DropInActivity.EXTRA_ERROR);
                Log.e(TAG, "onActivityResult exiting ==> received error: " + error.getMessage() + "\n" + error.getStackTrace());
                returnError(BraintreeErrorCodes.DropInError, error.getMessage());
                return;
            }

            this.handleDropInPaymentUiResult(resultCode, paymentMethodNonce, deviceData);
        }
    }

    private void handleDropInPaymentUiResult(int resultCode, PaymentMethodNonce paymentMethodNonce, String deviceData) {

        Log.i(TAG, "handleDropInPaymentUiResult resultCode ==> " + resultCode + ", paymentMethodNonce = " + paymentMethodNonce);

        if (resultCode == AppCompatActivity.RESULT_CANCELED) {
            returnError(BraintreeErrorCodes.UserCancelled);
            return;
        }

        if (paymentMethodNonce == null) {
            returnError(BraintreeErrorCodes.DropInError, "Result was not RESULT_CANCELED, but no PaymentMethodNonce was returned from the Braintree SDK (was " + resultCode + ").");
            return;
        }

        Map<String, Object> resultMap = this.getPaymentUINonceResult(paymentMethodNonce, deviceData);
        _callbackContext.success(new JSONObject(resultMap));
        _callbackContext = null;
    }

    private Map<String, Object> getPaymentUINonceResult(PaymentMethodNonce paymentMethodNonce, String deviceData) {

        Map<String, Object> resultMap = new HashMap<>();

        resultMap.put("nonce", paymentMethodNonce.getNonce());
        resultMap.put("type", paymentMethodNonce.getTypeLabel());
        resultMap.put("localizedDescription", paymentMethodNonce.getDescription());
        resultMap.put("deviceData", deviceData);

        // Card
        if (paymentMethodNonce instanceof CardNonce) {
            CardNonce cardNonce = (CardNonce) paymentMethodNonce;

            Map<String, Object> innerMap = new HashMap<>();
            innerMap.put("lastTwo", cardNonce.getLastTwo());
            innerMap.put("lastFour", cardNonce.getLastFour());
            innerMap.put("network", cardNonce.getCardType());
            innerMap.put("type", cardNonce.getTypeLabel());

            resultMap.put("card", innerMap);
        }

        // PayPal
        if (paymentMethodNonce instanceof PayPalAccountNonce) {
            PayPalAccountNonce payPalAccountNonce = (PayPalAccountNonce) paymentMethodNonce;

            Map<String, Object> innerMap = new HashMap<>();
            innerMap.put("email", payPalAccountNonce.getEmail());
            innerMap.put("firstName", payPalAccountNonce.getFirstName());
            innerMap.put("lastName", payPalAccountNonce.getLastName());
            innerMap.put("phone", payPalAccountNonce.getPhone());
            innerMap.put("billingAddress", parseAddress(payPalAccountNonce.getBillingAddress()));
            innerMap.put("shippingAddress", parseAddress(payPalAccountNonce.getShippingAddress()));
            innerMap.put("clientMetadataId", payPalAccountNonce.getClientMetadataId());
            innerMap.put("payerId", payPalAccountNonce.getPayerId());

            resultMap.put("paypalAccount", innerMap);
        }

        // Venmo
        if (paymentMethodNonce instanceof VenmoAccountNonce) {
            VenmoAccountNonce venmoAccountNonce = (VenmoAccountNonce) paymentMethodNonce;

            Map<String, Object> innerMap = new HashMap<>();
            innerMap.put("username", venmoAccountNonce.getUsername());

            resultMap.put("venmoAccount", innerMap);
        }

        return resultMap;
    }

    private Object parseAddress(PostalAddress address) {
        if (address != null) {
            Map<String, Object> innerMap = new HashMap<>();
            innerMap.put("recipientName", address.getRecipientName());
            innerMap.put("phoneNumber", address.getPhoneNumber());
            innerMap.put("streetAddress", address.getStreetAddress());
            innerMap.put("extendedAddress", address.getExtendedAddress());
            innerMap.put("locality", address.getLocality());
            innerMap.put("region", address.getRegion());
            innerMap.put("postalCode", address.getPostalCode());
            innerMap.put("sortingCode", address.getSortingCode());
            innerMap.put("countryCodeAlpha2", address.getCountryCodeAlpha2());
            return innerMap;
        }
        return null;
    }

    private void presentDropInPaymentUI(JSONArray args) throws JSONException {
        JSONObject options = args.getJSONObject(0);
        String token = options.getString("token");
        boolean vaultManager = options.optBoolean("vaultManager");
        boolean collectDeviceData = options.optBoolean("collectDeviceData", true);
        boolean disableCard = options.optBoolean("disableCard");
        boolean cardHolderNameRequired = options.optBoolean("cardHolderNameRequired");

        DropInRequest dropInRequest = new DropInRequest()
                .clientToken(token)
                .vaultManager(vaultManager)
                .collectDeviceData(collectDeviceData);
        if (disableCard) {
            dropInRequest.disableCard();
        } else {
            dropInRequest.cardholderNameStatus(cardHolderNameRequired ? CardForm.FIELD_REQUIRED : CardForm.FIELD_OPTIONAL);
        }

        this.cordova.startActivityForResult(this, dropInRequest.getIntent(this.cordova.getContext()), DROP_IN_REQUEST);
    }

    private void fetchDropInResult(JSONArray args) throws JSONException {
        String clientToken = args.getString(0);

        DropInResult.fetchDropInResult(cordova.getActivity(), clientToken, new DropInResult.DropInResultListener() {
            @Override
            public void onError(Exception exception) {
                // an error occurred
                returnError(BraintreeErrorCodes.UnknownError, exception.getMessage());
            }

            @Override
            public void onResult(DropInResult result) {
                if (result.getPaymentMethodType() != null) {
                    // use the icon and name to show in your UI
                    int icon = result.getPaymentMethodType().getDrawable();
                    int name = result.getPaymentMethodType().getLocalizedName();

                    if (result.getPaymentMethodType() == PaymentMethodType.GOOGLE_PAYMENT) {
                        // The last payment method the user used was GooglePayment. The GooglePayment
                        // flow will need to be performed by the user again at the time of checkout
                        // using GooglePayment#requestPayment(...). No PaymentMethodNonce will be
                        // present in result.getPaymentMethodNonce(), this is only an indication that
                        // the user last used GooglePayment.
                        returnError(BraintreeErrorCodes.NoExistingPaymentMethod);
                    } else {
                        // show the payment method in your UI and charge the user at the
                        // time of checkout using the nonce: paymentMethod.getNonce()
                        PaymentMethodNonce paymentMethod = result.getPaymentMethodNonce();
                        // todo
                    }
                } else {
                    // there was no existing payment method
                    returnError(BraintreeErrorCodes.NoExistingPaymentMethod);
                }
            }
        });
    }

    private void paypalOneTimePayment(JSONArray args) throws JSONException {
        JSONObject options = args.getJSONObject(0);
        String token = options.getString("token");
        String amount = options.getString("amount");
        String currencyCode = options.getString("currencyCode");
        boolean collectDeviceData = options.optBoolean("collectDeviceData", true);

        PayPalRequest request = new PayPalRequest(amount)
                .currencyCode(currencyCode)
                .intent(PayPalRequest.INTENT_AUTHORIZE);

        performPayPalRequest(token, request, collectDeviceData);
    }

    private void paypalBillingAgreement(JSONArray args) throws JSONException {
        JSONObject options = args.getJSONObject(0);
        String token = options.getString("token");
        String localeCode = options.optString("localeCode", "US");
        String billingAgreementDescription = options.optString("billingAgreementDescription");
        boolean collectDeviceData = options.optBoolean("collectDeviceData", true);

        PayPalRequest request = new PayPalRequest()
                .localeCode(localeCode);

        if (!billingAgreementDescription.equals("")) {
            request.billingAgreementDescription(billingAgreementDescription);
        }
        performPayPalRequest(token, request, collectDeviceData);
    }

    private void performPayPalRequest(String token, PayPalRequest request, boolean collectDeviceData) {
        cordova.getThreadPool().execute(() -> {
            BraintreeFragment fragment = createFragment(token);
            if (fragment == null) {
                return;
            }

            fragment.addListener((PaymentMethodNonceCreatedListener) paymentMethodNonce -> {
                if(collectDeviceData) {
                    DataCollector.collectDeviceData(fragment, s -> {
                        Map<String, Object> resultMap = getPaymentUINonceResult(paymentMethodNonce, s);
                        _callbackContext.success(new JSONObject(resultMap));
                        _callbackContext = null;
                    });
                } else {
                    Map<String, Object> resultMap = getPaymentUINonceResult(paymentMethodNonce, null);
                    _callbackContext.success(new JSONObject(resultMap));
                    _callbackContext = null;
                }
            });

            fragment.addListener((BraintreeCancelListener) var -> {
                if (var == 13591) {
                    returnError(BraintreeErrorCodes.UserCancelled);
                }
            });

            if (request.getAmount() == null) {
                PayPal.requestBillingAgreement(fragment, request);
            } else {
                PayPal.requestOneTimePayment(fragment, request);
            }
        });
    }

    private BraintreeFragment createFragment(String token) {
        if (token.equals("")) {
            returnError(BraintreeErrorCodes.TokenRequired);
            return null;
        }

        BraintreeFragment mBraintreeFragment;

        try {
            mBraintreeFragment = BraintreeFragment.newInstance(cordova.getActivity(), token);
            // mBraintreeFragment is ready to use!
        } catch (Exception e) {
            // There was an issue with your authorization string.
            returnError(BraintreeErrorCodes.FragmentInitializeFailed, e.getMessage());
            return null;
        }

        return mBraintreeFragment;
    }

    private void setupApplePay() {
        returnError(BraintreeErrorCodes.UnsupportedAction, "ApplePay is only available on iOS Devices");
    }

    @Override
    public void onError(Exception e) {
        returnError(BraintreeErrorCodes.UnknownError);
    }

    private void returnError(BraintreeErrorCodes errorCode) {
        returnError(errorCode, null);
    }

    private void returnError(BraintreeErrorCodes errorCode, String message) {
        if (_callbackContext != null) {
            Map<String, Object> resultMap = new HashMap<>();
            resultMap.put("code", errorCode.value);
            resultMap.put("message", message == null ? "" : message);
            _callbackContext.error(new JSONObject(resultMap));
            _callbackContext = null;
        }
    }
}
