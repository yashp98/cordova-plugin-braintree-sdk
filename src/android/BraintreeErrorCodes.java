package de.einfachhans.Braintree;

public enum BraintreeErrorCodes {
    TokenRequired(1),
    FragmentInitializeFailed(2),
    UserCancelled(3),
    DropInError(4),
    UnsupportedAction(5),
    WrongJsonObject(6),
    NoExistingPaymentMethod(7),
    UnknownError(10);

    public final int value;

    BraintreeErrorCodes(int value) {
        this.value = value;
    }
}
