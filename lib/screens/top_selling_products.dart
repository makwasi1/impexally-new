import 'package:active_ecommerce_flutter/data_model/product_mini_response.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_flutter/helpers/shimmer_helper.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:active_ecommerce_flutter/repositories/product_repository.dart';
import 'package:active_ecommerce_flutter/ui_elements/product_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../data_model/products_model.dart';

class TopSellingProducts extends StatefulWidget {
  @override
  _TopSellingProductsState createState() => _TopSellingProductsState();
}

class _TopSellingProductsState extends State<TopSellingProducts> {
  ScrollController? _scrollController;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: buildAppBar(context),
        body: buildProductList(context),
      ),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      // centerTitle: true,
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(CupertinoIcons.arrow_left, color: MyTheme.dark_grey),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      title: Text(
        AppLocalizations.of(context)!.top_selling_products_ucf,
        style: TextStyle(
            fontSize: 16,
            color: MyTheme.dark_font_grey,
            fontWeight: FontWeight.bold),
      ),
      elevation: 0.0,
      titleSpacing: 0,
    );
  }

  buildProductList(context) {
    return FutureBuilder(
        future: ProductRepository().getFilteredProducts(),
        builder: (context, AsyncSnapshot<ProductResponse> snapshot) {
          if (snapshot.hasError) {
            //snapshot.hasError
            //print("product error");
            //print(snapshot.error.toString());
            return Container();
          } else if (snapshot.hasData) {
            var homeData = snapshot.data;
            //print(productResponse.toString());
            return SingleChildScrollView(
              child: MasonryGridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                itemCount: homeData!.products!.length,
                shrinkWrap: true,
                padding:
                    EdgeInsets.only(top: 20.0, bottom: 10, left: 18, right: 18),
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  // 3
                  return ProductCard(
                    id: homeData.products![index].id,
                    slug: homeData.products![index].slug!,
                    image: homeData.products![index].image!.imageDefault,
                    name: homeData.products![index].productDetail!.title!,
                    main_price: homeData.products![index].price,
                    stroked_price:
                        homeData.products![index].priceDiscounted,
                    has_discount: true,
                    discount: homeData.products![index].priceDiscounted,
                    stock: homeData.products![index].stock,
                  );
                  ;
                },
              ),
            );
          } else {
            return ShimmerHelper()
                .buildProductGridShimmer(scontroller: _scrollController);
          }
        });
  }
}
