// To parse this JSON data, do
//
//     final categoryResponse = categoryResponseFromJson(jsonString);
//https://app.quicktype.io/
import 'dart:convert';

CategoryResponse categoryResponseFromJson(String str) => 
  CategoryResponse.fromJson(List<Map<String, dynamic>>.from(json.decode(str).map((x) => Map<String, dynamic>.from(x))));

String categoryResponseToJson(CategoryResponse data) => json.encode(data.toJson());

class CategoryResponse {
  CategoryResponse({
    this.categories,
  });

  List<Category>? categories;


  factory CategoryResponse.fromJson(List<Map<String, dynamic>> json) => 
    CategoryResponse(
      categories: json.map((x) => Category.fromJson(x)).toList(),
    );

  Map<String, dynamic> toJson() => {
    "data": List<dynamic>.from(categories!.map((x) => x.toJson())),
  };
}

class Category {
  Category({
    this.id,
    this.name,
    this.slug,
    this.banner,
    this.icon,
    this.number_of_children,
    this.links,
  });

  int? id;
  String? name;
  String? slug;
  String? banner;
  String? icon;
  int? number_of_children;
  Links? links;

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json["id"],
    name: json["title_meta_tag"],
    slug: json["slug"],
    banner: json["image"],
    icon: json["icon"],
    number_of_children: json["homepage_order"],
    // links: Links.fromJson(json["links"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "slug": slug,
    "banner": banner,
    "icon": icon,
    "number_of_children": number_of_children,
    // "links": links!.toJson(),
  };
}

class Links {
  Links({
    this.products,
    this.subCategories,
  });

  String? products;
  String? subCategories;

  factory Links.fromJson(Map<String, dynamic> json) => Links(
    products: json["products"],
    subCategories: json["sub_categories"],
  );

  Map<String, dynamic> toJson() => {
    "products": products,
    "sub_categories": subCategories,
  };
}
