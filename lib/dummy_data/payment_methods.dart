class PaymentMethod {
  String? id;
  String? key;
  String? name;
  String? image;

  PaymentMethod({this.id, this.key, this.name, this.image});
}

List<PaymentMethod> paymentMethodList = [
  PaymentMethod(
      id: "1",
      key: "MTN",
      name: "Pay with MTN",
      image: "dummy_assets/paypal.png"),
  PaymentMethod(
      id: "2",
      key: "AIR",
      name: "Pay with Airtel",
      image: "dummy_assets/stripe.png"),
  PaymentMethod(
      id: "3",
      key: "VOD",
      name: "Pay with Vodafone",
      image: "dummy_assets/flutterwave.png"),
];
