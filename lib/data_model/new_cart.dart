import 'dart:convert';

import 'package:active_ecommerce_flutter/data_model/products_model.dart';

class CartModel {
  List<Item>? cart;
  dynamic cartTotal;

  CartModel({
    this.cart,
    this.cartTotal,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) => CartModel(
        cart: json["items"] == null
            ? null
            : List<Item>.from(json["items"].map((x) => Item.fromMap(x))),
        cartTotal: json["cart_total"],
      );
}

class Item {
  int? id;
  String? cartId;
  String? productId;
  String? variationId;
  dynamic variationOptionId;
  String? quantity;
  String? itemPrice;
  DateTime? createdAt;
  DateTime? updatedAt;
  Product? product;
  List<Variation>? variation;

  Item(
      {this.id,
      this.cartId,
      this.productId,
      this.variationId,
      this.variationOptionId,
      this.quantity,
      this.createdAt,
      this.updatedAt,
      this.product,
      this.variation,
      this.itemPrice
      });

  factory Item.fromJson(String str) => Item.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Item.fromMap(Map<String, dynamic> json) => Item(
        id: json["item_id"],
        cartId: json["cart_id"],
        productId: json["product_id"],
        variationId: json["variation_id"],
        variationOptionId: json["variation_option_id"],
        quantity: json["quantity"],
        itemPrice: json["used_price"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        product:
            json["product"] == null ? null : Product.fromMap(json["product"]),
        variation: json["variations"] == null
            ? null
            : List<Variation>.from(
                json["variations"].map((x) => Variation.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "cart_id": cartId,
        "product_id": productId,
        "variation_id": variationId,
        "variation_option_id": variationOptionId,
        "quantity": quantity,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "product": product?.toMap(),
        "variation": variation == null
            ? null
            : List<dynamic>.from(variation!.map((x) => x.toMap())),
      };
}

class VariationOptions {
  int? id;
  String? variationId;
  String? parentId;
  String? optionNames;
  String? stock;
  String? color;
  String? price;
  String? priceDiscounted;
  String? discountRate;
  String? isDefault;
  String? useDefaultPrice;
  ImageVariation? imageVariation;

  VariationOptions({
    this.id,
    this.variationId,
    this.parentId,
    this.optionNames,
    this.stock,
    this.color,
    this.price,
    this.priceDiscounted,
    this.discountRate,
    this.isDefault,
    this.useDefaultPrice,
    this.imageVariation
  });

  VariationOptions.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    variationId = json['variation_id'];
    parentId = json['parent_id'];
    optionNames = json['option_names'];
    stock = json['stock'];
    color = json['color'];
    price = json['price'];
    priceDiscounted = json['price_discounted'];
    discountRate = json['discount_rate'];
    isDefault = json['is_default'];
    useDefaultPrice = json['use_default_price'];
    imageVariation = json['image_variation'] != null
        ? new ImageVariation.fromJson(json['image_variation'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['variation_id'] = this.variationId;
    data['parent_id'] = this.parentId;
    data['option_names'] = this.optionNames;
    data['stock'] = this.stock;
    data['color'] = this.color;
    data['price'] = this.price;
    data['price_discounted'] = this.priceDiscounted;
    data['discount_rate'] = this.discountRate;
    data['is_default'] = this.isDefault;
    data['use_default_price'] = this.useDefaultPrice;

    return data;
  }
}

class Product {
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
  dynamic specialOfferDate;
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

  Product({
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
    this.specialOfferDate,
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
  });

  factory Product.fromJson(String str) => Product.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Product.fromMap(Map<String, dynamic> json) => Product(
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
        promoteStartDate: json["promote_start_date"] == null
            ? null
            : DateTime.parse(json["promote_start_date"]),
        promoteEndDate: json["promote_end_date"] == null
            ? null
            : DateTime.parse(json["promote_end_date"]),
        promotePlan: json["promote_plan"],
        promoteDay: json["promote_day"],
        isSpecialOffer: json["is_special_offer"],
        specialOfferDate: json["special_offer_date"],
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
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "slug": slug,
        "product_type": productType,
        "listing_type": listingType,
        "sku": sku,
        "category_id": categoryId,
        "price": price,
        "price_discounted": priceDiscounted,
        "currency": currency,
        "discount_rate": discountRate,
        "vat_rate": vatRate,
        "user_id": userId,
        "status": status,
        "is_promoted": isPromoted,
        "promote_start_date": promoteStartDate?.toIso8601String(),
        "promote_end_date": promoteEndDate?.toIso8601String(),
        "promote_plan": promotePlan,
        "promote_day": promoteDay,
        "is_special_offer": isSpecialOffer,
        "special_offer_date": specialOfferDate,
        "visibility": visibility,
        "rating": rating,
        "pageviews": pageviews,
        "demo_url": demoUrl,
        "external_link": externalLink,
        "files_included": filesIncluded,
        "stock": stock,
        "shipping_class_id": shippingClassId,
        "shipping_delivery_time_id": shippingDeliveryTimeId,
        "multiple_sale": multipleSale,
        "digital_file_download_link": digitalFileDownloadLink,
        "country_id": countryId,
        "state_id": stateId,
        "city_id": cityId,
        "address": address,
        "zip_code": zipCode,
        "brand_id": brandId,
        "is_sold": isSold,
        "is_deleted": isDeleted,
        "is_draft": isDraft,
        "is_free_product": isFreeProduct,
        "is_rejected": isRejected,
        "reject_reason": rejectReason,
        "created_at": createdAt?.toIso8601String(),
      };
}

class Variation {
  int? id;
  String? productId;
  String? userId;
  String? parentId;
  String? labelNames;
  String? variationType;
  String? insertType;
  String? optionDisplayType;
  String? showImagesOnSlider;
  String? useDifferentPrice;
  String? isVisible;
  VariationOptions? variationOptions;

  Variation({
    this.id,
    this.productId,
    this.userId,
    this.parentId,
    this.labelNames,
    this.variationType,
    this.insertType,
    this.optionDisplayType,
    this.showImagesOnSlider,
    this.useDifferentPrice,
    this.isVisible,
    this.variationOptions,
  });

  factory Variation.fromJson(String str) => Variation.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Variation.fromMap(Map<String, dynamic> json) => Variation(
        id: json["id"],
        productId: json["product_id"],
        userId: json["user_id"],
        parentId: json["parent_id"],
        labelNames: json["label_names"],
        variationType: json["variation_type"],
        insertType: json["insert_type"],
        optionDisplayType: json["option_display_type"],
        showImagesOnSlider: json["show_images_on_slider"],
        useDifferentPrice: json["use_different_price"],
        isVisible: json["is_visible"],
        variationOptions: json["variation_option"] == null
            ? null
            : VariationOptions.fromJson(json["variation_option"]),
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "product_id": productId,
        "user_id": userId,
        "parent_id": parentId,
        "label_names": labelNames,
        "variation_type": variationType,
        "insert_type": insertType,
        "option_display_type": optionDisplayType,
        "show_images_on_slider": showImagesOnSlider,
        "use_different_price": useDifferentPrice,
        "is_visible": isVisible,
        "variation_option": variationOptions?.toJson(),
      };
}
