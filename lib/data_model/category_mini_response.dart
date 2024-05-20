import 'dart:convert';

class CategoryListResponse {
  List<Category> categories;

  CategoryListResponse({required this.categories});

  factory CategoryListResponse.fromJson(List<dynamic> parsedJson) {
    List<Category> categories = parsedJson.map((i) => Category.fromMap(i)).toList();
    return CategoryListResponse(categories: categories);
  }
}

class Category {
    int? id;
    String? slug;
    String? parentId;
    String? treeId;
    String? level;
    String? parentTree;
    String? titleMetaTag;
    String? description;
    String? keywords;
    String? categoryOrder;
    String? featuredOrder;
    String? homepageOrder;
    String? visibility;
    String? isFeatured;
    String? showOnMainMenu;
    String? showImageOnMainMenu;
    String? showProductsOnIndex;
    String? showSubcategoryProducts;
    String? storage;
    String? image;
    DateTime? createdAt;

    Category({
        this.id,
        this.slug,
        this.parentId,
        this.treeId,
        this.level,
        this.parentTree,
        this.titleMetaTag,
        this.description,
        this.keywords,
        this.categoryOrder,
        this.featuredOrder,
        this.homepageOrder,
        this.visibility,
        this.isFeatured,
        this.showOnMainMenu,
        this.showImageOnMainMenu,
        this.showProductsOnIndex,
        this.showSubcategoryProducts,
        this.storage,
        this.image,
        this.createdAt,
    });

    factory Category.fromJson(String str) => Category.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory Category.fromMap(Map<String, dynamic> json) => Category(
        id: json["id"],
        slug: json["slug"],
        parentId: json["parent_id"],
        treeId: json["tree_id"],
        level: json["level"],
        parentTree: json["parent_tree"],
        titleMetaTag: json["title_meta_tag"],
        description: json["description"],
        keywords: json["keywords"],
        categoryOrder: json["category_order"],
        featuredOrder: json["featured_order"],
        homepageOrder: json["homepage_order"],
        visibility: json["visibility"],
        isFeatured: json["is_featured"],
        showOnMainMenu: json["show_on_main_menu"],
        showImageOnMainMenu: json["show_image_on_main_menu"],
        showProductsOnIndex: json["show_products_on_index"],
        showSubcategoryProducts: json["show_subcategory_products"],
        storage: json["storage"],
        image: json["image"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    );

    Map<String, dynamic> toMap() => {
        "id": id,
        "slug": slug,
        "parent_id": parentId,
        "tree_id": treeId,
        "level": level,
        "parent_tree": parentTree,
        "title_meta_tag": titleMetaTag,
        "description": description,
        "keywords": keywords,
        "category_order": categoryOrder,
        "featured_order": featuredOrder,
        "homepage_order": homepageOrder,
        "visibility": visibility,
        "is_featured": isFeatured,
        "show_on_main_menu": showOnMainMenu,
        "show_image_on_main_menu": showImageOnMainMenu,
        "show_products_on_index": showProductsOnIndex,
        "show_subcategory_products": showSubcategoryProducts,
        "storage": storage,
        "image": image,
        "created_at": createdAt?.toIso8601String(),
    };
}
