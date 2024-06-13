// To parse this JSON data, do
//
//     final orderItemlResponse = orderItemlResponseFromJson(jsonString);
//https://app.quicktype.io/
import 'dart:convert';

OrderItemResponse orderItemlResponseFromJson(String str) =>
    OrderItemResponse.fromJson(json.decode(str));

String orderItemlResponseToJson(OrderItemResponse data) =>
    json.encode(data.toJson());

class OrderItemResponse {
  OrderItemResponse({
    this.ordered_items,
    this.success,
    this.status,
  });

  List<OrderItem>? ordered_items;
  bool? success;
  int? status;

  factory OrderItemResponse.fromJson(Map<String, dynamic> json) =>
      OrderItemResponse(
        ordered_items: List<OrderItem>.from(
            json["data"].map((x) => OrderItem.fromJson(x))),
        success: json["success"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(ordered_items!.map((x) => x.toJson())),
        "success": success,
        "status": status,
      };
}

class OrderItem {
  OrderItem({
    this.id,
    this.product_id,
    this.product_name,
    this.variation,
    this.price,
    this.tax,
    this.shipping_cost,
    this.coupon_discount,
    this.quantity,
    this.payment_status,
    this.payment_status_string,
    this.delivery_status,
    this.delivery_status_string,
    this.refund_section,
    this.refund_button,
    this.refund_label,
    this.refund_request_status,
    required this.product,
    required this.variationOptions,
  });

  int? id;
  String? product_id;
  String? product_name;
  String? variation;
  String? price;
  String? tax;
  String? shipping_cost;
  String? coupon_discount;
  String? quantity;
  String? payment_status;
  String? payment_status_string;
  String? delivery_status;
  String? delivery_status_string;
  bool? refund_section;
  bool? refund_button;
  String? refund_label;
  int? refund_request_status;
  ProductOrdered? product;
  List<VariationOption>? variationOptions;

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
        id: json["id"],
        product_id: json["product_id"],
        product_name: json["product_slug"],
        variation: json["variation_option_ids"],
        price: json["price"],
        tax: json["tax"],
        shipping_cost: json["shipping_cost"],
        coupon_discount: json["coupon_discount"],
        quantity: json["product_quantity"],
        payment_status: json["payment_status"],
        payment_status_string: json["payment_status_string"],
        delivery_status: json["delivery_status"],
        delivery_status_string: json["delivery_status_string"],
        refund_section: json["refund_section"],
        refund_button: json["refund_button"],
        refund_label: json["refund_label"],
        refund_request_status: json["refund_request_status"],
        product: ProductOrdered.fromJson(json["product"]),
        variationOptions: List<VariationOption>.from(
            json["variation_options"].map((x) => VariationOption.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "product_id": product_id,
        "product_name": product_name,
        "variation": variation,
        "price": price,
        "tax": tax,
        "shipping_cost": shipping_cost,
        "coupon_discount": coupon_discount,
        "quantity": quantity,
        "payment_status": payment_status,
        "payment_status_string": payment_status_string,
        "delivery_status": delivery_status,
        "delivery_status_string": delivery_status_string,
        "refund_section": refund_section,
        "refund_button": refund_button,
        "refund_label": refund_label,
        "refund_request_status": refund_request_status,
      };
}

class ProductOrdered {
  int? id;
  String? slug;
  String? productType;
  String? listingType;
  String? sku;
  String? categoryId;
  String? price;
  String? priceDiscounted;
  String? currency;
  String? discountRate;
  String? vatRate;
  String? userId;
  String? status;
  String? isPromoted;
  DateTime? promoteStartDate;
  DateTime? promoteEndDate;
  String? promotePlan;
  String? promoteDay;
  String? isSpecialOffer;
  // DateTime? specialOfferDate;
  String? visibility;
  String? rating;
  String? pageviews;
  String? demoUrl;
  String? externalLink;
  dynamic filesIncluded;
  String? stock;
  String? shippingClassId;
  String? shippingDeliveryTimeId;
  dynamic multipleSale;
  String? digitalFileDownloadLink;
  String? countryId;
  String? stateId;
  String? cityId;
  String? address;
  String? zipCode;
  String? brandId;
  String? isSold;
  String? isDeleted;
  String? isDraft;
  String? isFreeProduct;
  String? isRejected;
  dynamic rejectReason;
  DateTime? createdAt;
  ProductDetail? productDetail;

  ProductOrdered({
    this.id,
    this.slug,
    this.productType,
    this.listingType,
    this.sku,
    this.categoryId,
    this.price,
    this.priceDiscounted,
    this.currency,
    this.discountRate,
    this.vatRate,
    this.userId,
    this.status,
    this.isPromoted,
    this.promoteStartDate,
    this.promoteEndDate,
    this.promotePlan,
    this.promoteDay,
    this.isSpecialOffer,
    // this.specialOfferDate,
    this.visibility,
    this.rating,
    this.pageviews,
    this.demoUrl,
    this.externalLink,
    this.filesIncluded,
    this.stock,
    this.shippingClassId,
    this.shippingDeliveryTimeId,
    this.multipleSale,
    this.digitalFileDownloadLink,
    this.countryId,
    this.stateId,
    this.cityId,
    this.address,
    this.zipCode,
    this.brandId,
    this.isSold,
    this.isDeleted,
    this.isDraft,
    this.isFreeProduct,
    this.isRejected,
    this.rejectReason,
    this.createdAt,
    this.productDetail,
  });

  factory ProductOrdered.fromJson(Map<String, dynamic> json) => ProductOrdered(
        id: json["id"],
        slug: json["slug"],
        productType: json["product_type"],
        listingType: json["listing_type"],
        sku: json["sku"],
        categoryId: json["category_id"],
        price: json["price"],
        priceDiscounted: json["price_discounted"],
        currency: json["currency"],
        discountRate: json["discount_rate"],
        vatRate: json["vat_rate"],
        userId: json["user_id"],
        status: json["status"],
        isPromoted: json["is_promoted"],
        promoteStartDate: DateTime.parse(json["promote_start_date"]),
        promoteEndDate: DateTime.parse(json["promote_end_date"]),
        promotePlan: json["promote_plan"],
        promoteDay: json["promote_day"],
        isSpecialOffer: json["is_special_offer"],
        // specialOfferDate: DateTime.parse(json["special_offer_date"]),
        visibility: json["visibility"],
        rating: json["rating"],
        pageviews: json["pageviews"],
        demoUrl: json["demo_url"],
        externalLink: json["external_link"],
        filesIncluded: json["files_included"],
        stock: json["stock"],
        shippingClassId: json["shipping_class_id"],
        shippingDeliveryTimeId: json["shipping_delivery_time_id"],
        multipleSale: json["multiple_sale"],
        digitalFileDownloadLink: json["digital_file_download_link"],
        countryId: json["country_id"],
        stateId: json["state_id"],
        cityId: json["city_id"],
        address: json["address"],
        zipCode: json["zip_code"],
        brandId: json["brand_id"],
        isSold: json["is_sold"],
        isDeleted: json["is_deleted"],
        isDraft: json["is_draft"],
        isFreeProduct: json["is_free_product"],
        isRejected: json["is_rejected"],
        rejectReason: json["reject_reason"],
        createdAt: DateTime.parse(json["created_at"]),
        productDetail: ProductDetail.fromJson(json["product_detail"]),
      );
}


class ProductDetail {
    int? id;
    String? productId;
    String? langId;
    String? title;
    String? description;
    String? shortDescription;
    String? keywords;

    ProductDetail({
        this.id,
        this.productId,
        this.langId,
        this.title,
        this.description,
        this.shortDescription,
        this.keywords,
    });

    factory ProductDetail.fromJson(Map<String, dynamic> json) => ProductDetail(
        id: json["id"],
        productId: json["product_id"],
        langId: json["lang_id"],
        title: json["title"],
        description: json["description"],
        shortDescription: json["short_description"],
        keywords: json["keywords"],
    );

}

class VariationOption {
  int? id;
  String? variationId;
  String? optionName;
  Variation? variation;
  Image? image;

  VariationOption({
    this.id,
    this.variationId,
    this.optionName,
    this.variation,
    this.image,
  });

  factory VariationOption.fromJson(Map<String, dynamic> json) =>
      VariationOption(
        id: json["id"],
        variationId: json["variation_id"],
        optionName: json["option_name"],
        variation: Variation.fromJson(json["variation"]),
        
        image: json['image'] != null ? Image.fromJson(json['image']) : null,
      );
}

class Image {
  int? id;
  String? imageDefault;
  String? imageBig;
  String? imageSmall;
  String? isMain;
  String? storage;

  Image({
    this.id,
    this.imageDefault,
    this.imageBig,
    this.imageSmall,
    this.isMain,
    this.storage,
  });

  factory Image.fromJson(Map<String, dynamic> json) => Image(
        id: json["id"],
        imageDefault: json["image_default"],
        imageBig: json["image_big"],
        imageSmall: json["image_small"],
        isMain: json["is_main"],
        storage: json["storage"],
      );
}

class Variation {
  int? id;
  String? labelNames;
  Variation? variation;

  Variation({
    this.id,
    this.labelNames,
    this.variation,
  });

  factory Variation.fromJson(Map<String, dynamic> json) => Variation(
        id: json["id"],
        labelNames: json["label_names"],
        variation: json['variation'] != null
            ? Variation.fromJson(json['variation'])
            : null,
      );
}
