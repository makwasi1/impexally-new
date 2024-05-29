import 'dart:convert';

ProductResponse productResponseFromJson(String str) =>
    ProductResponse.fromJson(json.decode(str));

String productMiniResponseToJson(ProductResponse data) =>
    json.encode(data.toJson());


class ProductResponse {
  ProductResponse({
    this.products,
  });

  List<Products>? products;

  factory ProductResponse.fromJson(List<dynamic> json) =>
      ProductResponse(
        products: json.map((x) => Products.fromJson(x)).toList(),
      );

  List<dynamic> toJson() => products!.map((x) => x.toJson()).toList();
}

class Products {
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
  String? status;
  String? isPromoted;
  String? rating;
  String? stock;
  String? brandId;
  String? userId;
  ProductDetail? productDetail;
  Photos? image;
  List<Variation>? variation;

  Products(
      {this.id,
      this.slug,
      this.productType,
      this.listingType,
      this.sku,
      this.categoryId,
      this.price,
      this.priceDiscounted,
      this.currency,
      this.discountRate,
      this.status,
      this.isPromoted,
      this.rating,
      this.stock,
      this.brandId,
      this.userId,
      this.productDetail,
      this.image,
      this.variation

      });

  Products.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    slug = json['slug'];
    productType = json['product_type'];
    listingType = json['listing_type'];
    sku = json['sku'];
    categoryId = json['category_id'];
    price = json['price'];
    priceDiscounted = json['price_discounted'];
    currency = json['currency'];
    discountRate = json['discount_rate'];
    status = json['status'];
    isPromoted = json['is_promoted'];
    rating = json['rating'];
    stock = json['stock'];
    brandId = json['brand_id'];
    userId = json['user_id'];
    productDetail = json['product_detail'] != null
        ? new ProductDetail.fromJson(json['product_detail'])
        : null;
    image = json['image'] != null ? Photos.fromJson(json['image']) : null;
    if (json['variation'] != null) {
      variation = [];
      json['variation'].forEach((v) {
        variation!.add(Variation.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['slug'] = this.slug;
    data['product_type'] = this.productType;
    data['listing_type'] = this.listingType;
    data['sku'] = this.sku;
    data['category_id'] = this.categoryId;
    data['price'] = this.price;
    data['price_discounted'] = this.priceDiscounted;
    data['currency'] = this.currency;
    data['discount_rate'] = this.discountRate;
    data['status'] = this.status;
    data['is_promoted'] = this.isPromoted;
    data['rating'] = this.rating;
    data['stock'] = this.stock;
    data['brand_id'] = this.brandId;
    data['user_id'] = this.userId;
    if (this.productDetail != null) {
      data['product_detail'] = this.productDetail!.toJson();
    }
    if (this.image != null) {
      data['image'] = this.image!.toJson();
    }
    if (this.variation != null) {
      data['variation'] = this.variation!.map((v) => v.toJson()).toList();
    } 
    return data;
  }
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
  List<VariationOptions>? variationOptions;

  Variation(
      {this.id,
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
      this.variationOptions});

  Variation.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    productId = json['product_id'];
    userId = json['user_id'];
    parentId = json['parent_id'];
    labelNames = json['label_names'];
    variationType = json['variation_type'];
    insertType = json['insert_type'];
    optionDisplayType = json['option_display_type'];
    showImagesOnSlider = json['show_images_on_slider'];
    useDifferentPrice = json['use_different_price'];
    isVisible = json['is_visible'];
    if (json['variation_options'] != null) {
      variationOptions = [];
      json['variation_options'].forEach((v) {
        variationOptions!.add(VariationOptions.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['product_id'] = this.productId;
    data['user_id'] = this.userId;
    data['parent_id'] = this.parentId;
    data['label_names'] = this.labelNames;
    data['variation_type'] = this.variationType;
    data['insert_type'] = this.insertType;
    data['option_display_type'] = this.optionDisplayType;
    data['show_images_on_slider'] = this.showImagesOnSlider;
    data['use_different_price'] = this.useDifferentPrice;
    data['is_visible'] = this.isVisible;
    if (this.variationOptions != null) {
      data['variation_options'] =
          this.variationOptions!.map((v) => v.toJson()).toList();
    }
    return data;
  }
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

  

  VariationOptions(
      {this.id,
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
    if (this.imageVariation != null) {
      data['image_variation'] = this.imageVariation!.toJson();
    }
    return data;
  }
}


class ImageVariation {
  int? id;
  String? productId;
  String? variationOptionId;
  String? imageDefault;
  String? imageBig;
  String? imageSmall;
  String? isMain;
  String? storage;

  ImageVariation(
      {this.id,
      this.productId,
      this.variationOptionId,
      this.imageDefault,
      this.imageBig,
      this.imageSmall,
      this.isMain,
      this.storage});

  ImageVariation.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    productId = json['product_id'];
    variationOptionId = json['variation_option_id'];
    imageDefault = json['image_default'];
    imageBig = json['image_big'];
    imageSmall = json['image_small'];
    isMain = json['is_main'];
    storage = json['storage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['product_id'] = this.productId;
    data['variation_option_id'] = this.variationOptionId;
    data['image_default'] = this.imageDefault;
    data['image_big'] = this.imageBig;
    data['image_small'] = this.imageSmall;
    data['is_main'] = this.isMain;
    data['storage'] = this.storage;
    return data;
  }
}

class ProductDetail {
  int? id;
  String? productId;
  String? langId;
  String? title;
  String? description;
  String? shortDescription;
  String? keywords;

  ProductDetail(
      {this.id,
      this.productId,
      this.langId,
      this.title,
      this.description,
      this.shortDescription,
      this.keywords});

  ProductDetail.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    productId = json['product_id'];
    langId = json['lang_id'];
    title = json['title'];
    description = json['description'];
    shortDescription = json['short_description'];
    keywords = json['keywords'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['product_id'] = this.productId;
    data['lang_id'] = this.langId;
    data['title'] = this.title;
    data['description'] = this.description;
    data['short_description'] = this.shortDescription;
    data['keywords'] = this.keywords;
    return data;
  }
}

class Photos {
  int? id;
  String? productId;
  String? imageDefault;
  String? imageBig;
  String? imageSmall;
  String? isMain;
  String? storage;

  Photos(
      {this.id,
      this.productId,
      this.imageDefault,
      this.imageBig,
      this.imageSmall,
      this.isMain,
      this.storage});

  Photos.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    productId = json['product_id'];
    imageDefault = json['image_default'];
    imageBig = json['image_big'];
    imageSmall = json['image_small'];
    isMain = json['is_main'];
    storage = json['storage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['product_id'] = this.productId;
    data['image_default'] = this.imageDefault;
    data['image_big'] = this.imageBig;
    data['image_small'] = this.imageSmall;
    data['is_main'] = this.isMain;
    data['storage'] = this.storage;
    return data;
  }
}
