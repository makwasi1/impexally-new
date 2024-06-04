// To parse this JSON data, do
//
//     final orderMiniResponse = orderMiniResponseFromJson(jsonString);
// https://app.quicktype.io/
import 'dart:convert';

OrderMiniResponse orderMiniResponseFromJson(String str) => OrderMiniResponse.fromJson(json.decode(str));

String orderMiniResponseToJson(OrderMiniResponse data) => json.encode(data.toJson());

class OrderMiniResponse {
  OrderMiniResponse({
    this.orders,
    this.success,
    this.status,
  });

  List<Order>? orders;
  OrderMiniResponseLinks? links;
  Meta? meta;
  bool? success;
  int? status;

  factory OrderMiniResponse.fromJson(Map<dynamic, dynamic> json) => OrderMiniResponse(
    orders: List<Order>.from(json["data"].map((x) => Order.fromJson(x))),
    success: json["success"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "data": List<dynamic>.from(orders!.map((x) => x.toJson())),
    "success": success,
    "status": status,
  };
}

class Order {
  final int id;
  final String orderNumber;
  final String buyerId;
  final String buyerType;
  final String priceSubtotal;
  final String priceVat;
  final String priceShipping;
  final String priceTotal;
  final String priceCurrency;
  final String status;
  final String paymentMethod;
  final String paymentStatus;
  final String updatedAt;
  final String createdAt;
  final List<OrderProduct> orderProducts;

  Order({
    required this.id,
    required this.orderNumber,
    required this.buyerId,
    required this.buyerType,
    required this.priceSubtotal,
    required this.priceVat,
    required this.priceShipping,
    required this.priceTotal,
    required this.priceCurrency,
    required this.status,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.updatedAt,
    required this.createdAt,
    required this.orderProducts,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    var list = json['order_products'] as List;
    List<OrderProduct> orderProductList =
        list.map((i) => OrderProduct.fromJson(i)).toList();

    return Order(
      id: json['id'],
      orderNumber: json['order_number'],
      buyerId: json['buyer_id'],
      buyerType: json['buyer_type'],
      priceSubtotal: json['price_subtotal'],
      priceVat: json['price_vat'],
      priceShipping: json['price_shipping'],
      priceTotal: json['price_total'],
      priceCurrency: json['price_currency'],
      status: json['status'],
      paymentMethod: json['payment_method'],
      paymentStatus: json['payment_status'],
      updatedAt: json['updated_at'],
      createdAt: json['created_at'],
      orderProducts: orderProductList,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "order_number": orderNumber,
    "buyer_id": buyerId,
    "buyer_type": buyerType,
    "price_subtotal": priceSubtotal,
    "price_vat": priceVat,
    "price_shipping": priceShipping,
    "price_total": priceTotal,
    "price_currency": priceCurrency,
    "status": status,
    "payment_method": paymentMethod,
    "payment_status": paymentStatus,
    "updated_at": updatedAt,
    "created_at": createdAt,
    "order_products": List<dynamic>.from(orderProducts.map((x) => x.toJson())),
  };
}

class OrderProduct {
  final int id;
  final String orderId;
  final String sellerId;
  final String productType;
  final String listingType;
  final String productSlug;
  final String productQuantity;
  final String orderStatus;
  final String updatedAt;
  final String createdAt;

  OrderProduct({
    required this.id,
    required this.orderId,
    required this.sellerId,
    required this.productType,
    required this.listingType,
    required this.productSlug,
    required this.productQuantity,
    required this.orderStatus,
    required this.updatedAt,
    required this.createdAt,
  });

  factory OrderProduct.fromJson(Map<String, dynamic> json) {
    return OrderProduct(
      id: json['id'],
      orderId: json['order_id'],
      sellerId: json['seller_id'],
      productType: json['product_type'],
      listingType: json['listing_type'],
      productSlug: json['product_slug'],
      productQuantity: json['product_quantity'],
      orderStatus: json['order_status'],
      updatedAt: json['updated_at'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "order_id": orderId,
    "seller_id": sellerId,
    "product_type": productType,
    "listing_type": listingType,
    "product_slug": productSlug,
    "product_quantity": productQuantity,
    "order_status": orderStatus,
    "updated_at": updatedAt,
    "created_at": createdAt,
  };
}

class OrderLinks {
  OrderLinks({
    this.details,
  });

  String? details;

  factory OrderLinks.fromJson(Map<String, dynamic> json) => OrderLinks(
    details: json["details"],
  );

  Map<String, dynamic> toJson() => {
    "details": details,
  };
}



class OrderMiniResponseLinks {
  OrderMiniResponseLinks({
    this.first,
    this.last,
    this.prev,
    this.next,
  });

  dynamic first;
  dynamic last;
  dynamic prev;
  dynamic next;

  factory OrderMiniResponseLinks.fromJson(Map<String, dynamic> json) => OrderMiniResponseLinks(
    first: json["first"],
    last: json["last"],
    prev: json["prev"],
    next: json["next"],
  );

  Map<String, dynamic> toJson() => {
    "first": first,
    "last": last,
    "prev": prev,
    "next": next,
  };
}

class Meta {
  Meta({
    this.currentPage,
    this.from,
    this.lastPage,
    this.path,
    this.perPage,
    this.to,
    this.total,
  });

  int? currentPage;
  int? from;
  int? lastPage;
  String? path;
  int? perPage;
  int? to;
  int? total;

  factory Meta.fromJson(Map<String, dynamic> json) => Meta(
    currentPage: json["current_page"],
    from: json["from"],
    lastPage: json["last_page"],
    path: json["path"],
    perPage: json["per_page"],
    to: json["to"],
    total: json["total"],
  );

  Map<String, dynamic> toJson() => {
    "current_page": currentPage,
    "from": from,
    "last_page": lastPage,
    "path": path,
    "per_page": perPage,
    "to": to,
    "total": total,
  };
}

