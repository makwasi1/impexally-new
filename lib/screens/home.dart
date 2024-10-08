import 'package:active_ecommerce_flutter/app_config.dart';
import 'package:active_ecommerce_flutter/custom/aiz_image.dart';
import 'package:active_ecommerce_flutter/custom/box_decorations.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_flutter/helpers/shimmer_helper.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:active_ecommerce_flutter/presenter/home_presenter.dart';
import 'package:active_ecommerce_flutter/screens/category_products.dart';
import 'package:active_ecommerce_flutter/screens/filter.dart';
import 'package:active_ecommerce_flutter/screens/flash_deal_list.dart';
import 'package:active_ecommerce_flutter/screens/import_china.dart';
import 'package:active_ecommerce_flutter/screens/profile.dart';
import 'package:active_ecommerce_flutter/screens/seller_admin.dart';
import 'package:active_ecommerce_flutter/screens/todays_deal_products.dart';
import 'package:active_ecommerce_flutter/ui_elements/mini_product_card.dart';
import 'package:active_ecommerce_flutter/ui_elements/product_card.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../custom/common_functions.dart';

class Home extends StatefulWidget {
  Home({
    Key? key,
    this.title,
    this.show_back_button = false,
    go_back = true,
  }) : super(key: key);

  final String? title;
  bool show_back_button;
  late bool go_back;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  HomePresenter homeData = HomePresenter();

  @override
  void initState() {
    Future.delayed(Duration.zero).then((value) {
      change();
    });
    // change();
    // TODO: implement initState
    super.initState();
  }

  change() {
    homeData.onRefresh();
    homeData.mainScrollListener();
    homeData.initPiratedAnimation(this);
  }

  @override
  void dispose() {
    homeData.pirated_logo_controller.dispose();
    //  ChangeNotifierProvider<HomePresenter>.value(value: value)
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return WillPopScope(
      onWillPop: () async {
        CommonFunctions(context).appExitDialog();
        print("Will scope home");
        return widget.go_back;
      },
      child: Directionality(
        textDirection:
            app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
        child: SafeArea(
          child: Scaffold(
              key: homeData.scaffoldKey,
              appBar: buildAppBar(statusBarHeight, context)
              // preferredSize: Size.fromHeight(50),
              ,
              //drawer: MainDrawer(),
              body: ListenableBuilder(
                  listenable: homeData,
                  builder: (context, child) {
                    return Stack(
                      children: [
                        RefreshIndicator(
                          color: MyTheme.accent_color,
                          backgroundColor: Colors.white,
                          onRefresh: homeData.onRefresh,
                          displacement: 0,
                          child: CustomScrollView(
                            controller: homeData.mainScrollController,
                            physics: const BouncingScrollPhysics(
                                parent: AlwaysScrollableScrollPhysics()),
                            slivers: <Widget>[
                              SliverList(
                                delegate: SliverChildListDelegate([
                                  AppConfig.purchase_code == ""
                                      ? Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                            9.0,
                                            16.0,
                                            9.0,
                                            0.0,
                                          ),
                                          child: Container(
                                            height: 140,
                                            color: Colors.black,
                                            child: Stack(
                                              children: [
                                                Positioned(
                                                    left: 20,
                                                    top: 0,
                                                    child: AnimatedBuilder(
                                                        animation: homeData
                                                            .pirated_logo_animation,
                                                        builder:
                                                            (context, child) {
                                                          return Image.asset(
                                                            "assets/pirated_square.png",
                                                            height: homeData
                                                                .pirated_logo_animation
                                                                .value,
                                                            color: Colors.white,
                                                          );
                                                        })),
                                                Center(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 24.0,
                                                            left: 24,
                                                            right: 24),
                                                    child: Text(
                                                      "hkhahfjhjfkahf.",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 18),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      : Container(),
                                  buildInfoBar(context),
                                  buildHomeCarouselSlider(context, homeData),
                                  // buildPromoItems(),
                                  // buildHomeMenuRow1(context, homeData),

                                  buildPromoItems(),

                                  buildHomeRow(),
                                  // buildHomeBannerOne(context, homeData),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      8.0,
                                      0.0,
                                      8.0,
                                      0.0,
                                    ),
                                    child: buildHomeMenuRow2(context),
                                  ),
                                ]),
                              ),
                              SliverList(
                                delegate: SliverChildListDelegate([
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      18.0,
                                      20.0,
                                      18.0,
                                      0.0,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [],
                                    ),
                                  ),
                                ]),
                              ),
                              // SliverToBoxAdapter(
                              //   child: SizedBox(
                              //     height: 154,
                              //     child: buildHomeFeaturedCategories(
                              //         context, homeData),
                              //   ),
                              // ),
                              SliverList(
                                delegate: SliverChildListDelegate([
                                  Container(
                                    color: MyTheme.accent_color,
                                    child: Stack(
                                      children: [
                                        Container(
                                          height: 180,
                                          width: double.infinity,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Image.asset(
                                                  "assets/background_1.png")
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 10.0,
                                                  right: 18.0,
                                                  left: 18.0),
                                              child: Text(
                                                AppLocalizations.of(context)!
                                                    .featured_products_ucf,
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.w700),
                                              ),
                                            ),
                                            buildHomeFeatureProductHorizontalList(
                                                homeData)
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ]),
                              ),
                              // SliverList(
                              //   delegate: SliverChildListDelegate(
                              //     [
                              //       buildHomeBannerTwo(context, homeData),
                              //     ],
                              //   ),
                              // ),
                              SliverList(
                                delegate: SliverChildListDelegate([
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      18.0,
                                      18.0,
                                      20.0,
                                      0.0,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)!
                                              .all_products_ucf,
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        buildHomeAllProducts2(
                                            context, homeData),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    height: 80,
                                  )
                                ]),
                              ),
                            ],
                          ),
                        ),
                        Align(
                            alignment: Alignment.center,
                            child: buildProductLoadingContainer(homeData))
                      ],
                    );
                  })),
        ),
      ),
    );
  }

  Widget buildHomeAllProducts(context, HomePresenter homeData) {
    if (homeData.isAllProductInitial && homeData.allProductList.length == 0) {
      return SingleChildScrollView(
          child: ShimmerHelper().buildProductGridShimmer(
              scontroller: homeData.allProductScrollController));
    } else if (homeData.allProductList.length > 0) {
      //snapshot.hasData

      return GridView.builder(
        // 2
        //addAutomaticKeepAlives: true,
        itemCount: homeData.allProductList.length,
        controller: homeData.allProductScrollController,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.618),
        padding: EdgeInsets.all(16.0),
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index) {
          // 3
          return ProductCard(
            id: homeData.allProductList[index].id,
            slug: homeData.allProductList[index].slug,
            image: homeData.allProductList[index].image.imageDefault,
            name: homeData.allProductList[index].productDetail.title,
            main_price: homeData.allProductList[index].price,
            stroked_price: homeData.allProductList[index].priceDiscounted,
            has_discount: true,
            discount: homeData.allProductList[index].priceDiscounted,
          );
        },
      );
    } else if (homeData.totalAllProductData == 0) {
      return Center(
          child: Text(AppLocalizations.of(context)!.no_product_is_available));
    } else {
      return Container(); // should never be happening
    }
  }

  Widget buildHomeAllProducts2(context, HomePresenter homeData) {
    // if (homeData.isAllProductInitial && homeData.allProductList.length == 0) {
    if (homeData.isAllProductInitial) {
      return SingleChildScrollView(
          child: ShimmerHelper().buildProductGridShimmer(
              scontroller: homeData.allProductScrollController));
    } else if (homeData.allProductList.length > 0) {
      return MasonryGridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          itemCount: homeData.allProductList.length,
          shrinkWrap: true,
          padding: EdgeInsets.only(top: 20.0, bottom: 10, left: 5, right: 5),
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return ProductCard(
              id: homeData.allProductList[index].id,
              slug: homeData.allProductList[index].slug,
              image: homeData.allProductList[index].image?.imageDefault ?? "",
              name: homeData.allProductList[index].productDetail?.title,
              main_price: homeData.allProductList[index].price,
              stroked_price: homeData.allProductList[index].priceDiscounted,
              has_discount: true,
              stock: homeData.allProductList[index].stock,
              discount: homeData.allProductList[index].priceDiscounted,
              is_wholesale: true,
            );
          });
    } else if (homeData.totalAllProductData == 0) {
      return Center(
          child: Text(AppLocalizations.of(context)!.no_product_is_available));
    } else {
      return Container(); // should never be happening
    }
  }

  Widget buildHomeFeaturedCategories(context, HomePresenter homeData) {
    if (homeData.isCategoryInitial &&
        homeData.featuredCategoryList.length == 0) {
      return ShimmerHelper().buildHorizontalGridShimmerWithAxisCount(
          crossAxisSpacing: 14.0,
          mainAxisSpacing: 14.0,
          item_count: 10,
          mainAxisExtent: 170.0,
          controller: homeData.featuredCategoryScrollController);
    } else if (homeData.featuredCategoryList.length > 0) {
      //snapshot.hasData
      return GridView.builder(
          padding:
              const EdgeInsets.only(left: 18, right: 18, top: 13, bottom: 20),
          scrollDirection: Axis.horizontal,
          controller: homeData.featuredCategoryScrollController,
          itemCount: homeData.featuredCategoryList.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3 / 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              mainAxisExtent: 170.0),
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return CategoryProducts(
                    slug: homeData.featuredCategoryList[index].id.toString(),
                    // category_name: homeData.featuredCategoryList[index].name,
                  );
                }));
              },
              child: Container(
                decoration: BoxDecorations.buildBoxDecoration_1(),
                child: Row(
                  children: <Widget>[
                    Container(
                        child: ClipRRect(
                            borderRadius: BorderRadius.horizontal(
                                left: Radius.circular(6), right: Radius.zero),
                            child:
                                homeData.featuredCategoryList[index].image != ""
                                    ? FadeInImage.assetNetwork(
                                        placeholder: 'assets/placeholder.png',
                                        image: "https://seller.impexally.com/" +
                                            homeData.featuredCategoryList[index]
                                                .image,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.asset(
                                        'assets/placeholder.png',
                                        fit: BoxFit.cover,
                                      ))),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          homeData.featuredCategoryList[index].titleMetaTag,
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 3,
                          softWrap: true,
                          style:
                              TextStyle(fontSize: 12, color: MyTheme.font_grey),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
    } else if (!homeData.isCategoryInitial &&
        homeData.featuredCategoryList.length == 0) {
      return Container(
          height: 100,
          child: Center(
              child: Text(
            AppLocalizations.of(context)!.no_category_found,
            style: TextStyle(color: MyTheme.font_grey),
          )));
    } else {
      // should not be happening
      return Container(
        height: 100,
      );
    }
  }

  Widget buildHomeFeatureProductHorizontalList(HomePresenter homeData) {
    if (homeData.isFeaturedProductInitial == true &&
        homeData.featuredProductList.length == 0) {
      return Row(
        children: [
          Padding(
              padding: const EdgeInsets.all(16.0),
              child: ShimmerHelper().buildBasicShimmer(
                  height: 120.0,
                  width: (MediaQuery.of(context).size.width - 64) / 3)),
          Padding(
              padding: const EdgeInsets.all(16.0),
              child: ShimmerHelper().buildBasicShimmer(
                  height: 120.0,
                  width: (MediaQuery.of(context).size.width - 64) / 3)),
          Padding(
              padding: const EdgeInsets.all(16.0),
              child: ShimmerHelper().buildBasicShimmer(
                  height: 120.0,
                  width: (MediaQuery.of(context).size.width - 160) / 3)),
        ],
      );
    } else if (homeData.featuredProductList.length > 0) {
      return SingleChildScrollView(
        child: SizedBox(
          height: 260,
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (scrollInfo.metrics.pixels ==
                  scrollInfo.metrics.maxScrollExtent) {
                homeData.fetchFeaturedProducts();
              }
              return true;
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(18.0),
              separatorBuilder: (context, index) => SizedBox(
                width: 14,
              ),
              itemCount: homeData.totalFeaturedProductData! >
                      homeData.featuredProductList.length
                  ? homeData.featuredProductList.length + 1
                  : homeData.featuredProductList.length,
              scrollDirection: Axis.horizontal,
              //itemExtent: 135,

              physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              itemBuilder: (context, index) {
                return (index == 4)
                    ? SpinKitFadingFour(
                        itemBuilder: (BuildContext context, int index) {
                          return DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.white,
                            ),
                          );
                        },
                      )
                    : MiniProductCard(
                        id: homeData.featuredProductList[index].id,
                        slug: homeData.featuredProductList[index].slug,
                        image: homeData
                            .featuredProductList[index].image.imageDefault,
                        name: homeData
                            .featuredProductList[index].productDetail.title,
                        main_price: homeData.featuredProductList[index].price,
                        stroked_price:
                            homeData.featuredProductList[index].priceDiscounted,
                        has_discount: true,
                        is_wholesale: true,
                        discount:
                            homeData.featuredProductList[index].priceDiscounted,
                      );
              },
            ),
          ),
        ),
      );
    } else {
      return Container(
          height: 100,
          child: Center(
              child: Text(
            AppLocalizations.of(context)!.no_related_product,
            style: TextStyle(color: MyTheme.font_grey),
          )));
    }
  }

  Widget buildHomeMenuRow1(BuildContext context, HomePresenter homeData) {
    return Row(
      children: [
        if (homeData.isTodayDeal)
          Flexible(
            flex: 1,
            fit: FlexFit.tight,
            child: GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return TodaysDealProducts();
                }));
              },
              child: Container(
                height: 90,
                decoration: BoxDecorations.buildBoxDecoration_1(),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                          height: 20,
                          width: 20,
                          child: Image.asset("assets/todays_deal.png")),
                    ),
                    Text(AppLocalizations.of(context)!.todays_deal_ucf,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Color.fromRGBO(132, 132, 132, 1),
                            fontWeight: FontWeight.w300)),
                  ],
                ),
              ),
            ),
          ),
        if (homeData.isTodayDeal && homeData.isFlashDeal) SizedBox(width: 14.0),
        if (homeData.isFlashDeal)
          Flexible(
            flex: 1,
            fit: FlexFit.tight,
            child: GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return FlashDealList();
                }));
              },
              child: Container(
                height: 90,
                decoration: BoxDecorations.buildBoxDecoration_1(),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                          height: 20,
                          width: 20,
                          child: Image.asset("assets/flash_deal.png")),
                    ),
                    Text(AppLocalizations.of(context)!.flash_deal_ucf,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Color.fromRGBO(132, 132, 132, 1),
                            fontWeight: FontWeight.w300)),
                  ],
                ),
              ),
            ),
          )
      ],
    );
  }

  Widget buildHomeMenuRow2(BuildContext context) {
    return GestureDetector(
      onTap: () => _makePhoneCall(),
      child: Container(
          padding: EdgeInsets.only(top: 5, bottom: 10),
          child: CachedNetworkImage(
            imageUrl: "https://image.impexally.com/images/ae/athleisure1.png",
            placeholder: (context, url) => Container(), // Placeholder widget
            errorWidget: (context, url, error) =>
                Icon(Icons.error), // Error widget
            // Adjust the height as needed
          )),
    );
  }

  Widget buildInfoBar(BuildContext context) {
    return Container(
      height: 40,
      color: MyTheme.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 1.0),
            child: Image.asset(
              "assets/loaction_pin.jpg",
              height: 30,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 5.0),
            child: Text(
              "🇬🇭 Impexpress - Sameday Delivery Across Ghana Accra",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 11,
                  fontWeight: FontWeight.normal),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildHomeCarouselSlider(context, HomePresenter homeData) {
    if (homeData.isCarouselInitial && homeData.carouselImageList.length == 0) {
      return Padding(
        padding: const EdgeInsets.only(
          left: 18,
          right: 18,
          top: 0,
          bottom: 10,
        ),
        child: ShimmerHelper().buildBasicShimmer(
          height: 120,
        ),
      );
    } else if (homeData.carouselImageList.length > 0) {
      return CarouselSlider(
        options: CarouselOptions(
          height: 150,
          viewportFraction: 1,
          initialPage: 0,
          enableInfiniteScroll: true,
          reverse: false,
          autoPlay: true,
          autoPlayInterval: Duration(seconds: 5),
          autoPlayAnimationDuration: Duration(milliseconds: 1000),
          autoPlayCurve: Curves.easeInExpo,
          enlargeCenterPage: false,
          scrollDirection: Axis.horizontal,
          onPageChanged: (index, reason) {
            homeData.incrementCurrentSlider(index);
          },
        ),
        items: homeData.carouselImageList.map((i) {
          return Builder(
            builder: (BuildContext context) {
              return Padding(
                padding: const EdgeInsets.only(
                    left: 18, right: 18, top: 10, bottom: 20),
                child: Stack(
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      height: 180,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return Filter();
                          }));
                        },
                        child: AIZImage.radiusImage(i.photo, 6),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: homeData.carouselImageList.map((url) {
                          int index = homeData.carouselImageList.indexOf(url);
                          return Container(
                            width: 7.0,
                            height: 7.0,
                            margin: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 4.0),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: homeData.current_slider == index
                                  ? MyTheme.white
                                  : Color.fromRGBO(112, 112, 112, .3),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }).toList(),
      );
    } else if (!homeData.isCarouselInitial &&
        homeData.carouselImageList.length == 0) {
      return Container(
          height: 100,
          child: Center(
              child: Text(
            AppLocalizations.of(context)!.no_carousel_image_found,
            style: TextStyle(color: MyTheme.font_grey),
          )));
    } else {
      // should not be happening
      return Container(
        height: 100,
      );
    }
  }

  Future<void> _makePhoneCall() async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: '+233533181114',
    );
    if (await canLaunch(launchUri.toString())) {
      await launch(launchUri.toString());
    } else {
      throw 'Could not launch $launchUri';
    }
  }

  Widget buildPromoItems() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  _makePhoneCall();
                  // launchUrl(Uri.parse("https://app.impexally.com/riders-info"));
                },
                child: Column(
                  children: [
                    Container(
                        height: 70,
                        padding: EdgeInsets.only(left: 10),
                        child: CachedNetworkImage(
                          imageUrl:
                              "https://image.impexally.com/images/agents/riderz.png",
                          placeholder: (context, url) =>
                              Container(), // Placeholder widget
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error), // Error widget
                          // Adjust the height as needed
                        )),
                    Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: Text(
                        "Get Riders",
                        style: TextStyle(
                            overflow: TextOverflow.ellipsis,
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ImportFromChinaWebView(
                              url:
                                  "https://app.impexally.com/import-from-china",
                            )),
                  );
                },
                child: Column(
                  children: [
                    Container(
                        height: 70,
                        padding: EdgeInsets.only(left: 10),
                        child: CachedNetworkImage(
                          imageUrl:
                              "https://image.impexally.com/images/ae/home-page/import-from-china.png",
                          placeholder: (context, url) =>
                              Container(), // Placeholder widget
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error), // Error widget
                          // Adjust the height as needed
                        )),
                    Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: Text(
                        "From China",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return CategoryProducts(
                      slug: homeData.featuredCategoryList[2].id.toString(),
                      // category_name: homeData.featuredCategoryList[index].name,
                    );
                  }));
                },
                child: Column(
                  children: [
                    Container(
                        height: 70,
                        padding: EdgeInsets.only(left: 10),
                        child: CachedNetworkImage(
                          imageUrl:
                              "https://image.impexally.com/images/ae/home-page/z5.png",
                          placeholder: (context, url) =>
                              Container(), // Placeholder widget
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error), // Error widget
                          // Adjust the height as needed
                        )),
                    Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: Text(
                        "Deals",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return CategoryProducts(
                      slug: homeData.featuredCategoryList[3].id.toString(),
                      // category_name: homeData.featuredCategoryList[index].name,
                    );
                  }));
                },
                child: Column(
                  children: [
                    Container(
                        height: 70,
                        padding: EdgeInsets.only(right: 10),
                        child: CachedNetworkImage(
                          imageUrl:
                              "https://image.impexally.com/images/ae/home-page/12.png",
                          placeholder: (context, url) =>
                              Container(), // Placeholder widget
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error), // Error widget
                          // Adjust the height as needed
                        )),
                    Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: Text(
                        "Featured",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return CategoryProducts(
                      slug: homeData.featuredCategoryList[4].id.toString(),
                      // category_name: homeData.featuredCategoryList[index].name,
                    );
                  }));
                },
                child: Column(
                  children: [
                    Container(
                        height: 70,
                        padding: EdgeInsets.only(right: 10),
                        child: CachedNetworkImage(
                          imageUrl:
                              "https://image.impexally.com/images/ae/home-page/z2.png",
                          placeholder: (context, url) =>
                              Container(), // Placeholder widget
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error), // Error widget
                          // Adjust the height as needed
                        )),
                    Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: Text(
                        "Special Offer",
                        style: TextStyle(
                            overflow: TextOverflow.ellipsis,
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ],
    );
  }

  Widget buildHomeRow() {
    return Container(
      padding: EdgeInsets.only(top: 10, bottom: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: GestureDetector(
                  onTap: () {
                    _makePhoneCall();
                  },
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.only(left: 10),
                        child: CachedNetworkImage(
                          imageUrl:
                              "https://image.impexally.com/images/app/impexally/Impexally-express-banner.webp",
                          placeholder: (context, url) =>
                              Container(), // Placeholder widget
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error), // Error widget
                          // Adjust the height as needed
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Pickup & Delivery",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Flexible(
                child: GestureDetector(
                  onTap: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SellerMain()),
                    );
                  },
                  child: Column(
                    children: [
                      Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.only(right: 10),
                          child: CachedNetworkImage(
                            imageUrl:
                                "https://image.impexally.com/images/app/impexally/make-mone-online.png",
                            placeholder: (context, url) =>
                                Container(), // Placeholder widget
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error), // Error widget
                            // Adjust the height as needed
                          )),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Start Selling now",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget buildHomeBannerOne(context, HomePresenter homeData) {
    if (homeData.isBannerOneInitial &&
        homeData.bannerOneImageList.length == 0) {
      return Padding(
          padding:
              const EdgeInsets.only(left: 18.0, right: 18, top: 10, bottom: 20),
          child: ShimmerHelper().buildBasicShimmer(height: 120));
    } else if (homeData.bannerOneImageList.length > 0) {
      return Padding(
        padding: app_language_rtl.$!
            ? const EdgeInsets.only(right: 9.0)
            : const EdgeInsets.only(left: 9.0),
        child: CarouselSlider(
          options: CarouselOptions(
              aspectRatio: 200 / 150,
              viewportFraction: .75,
              initialPage: 0,
              padEnds: false,
              enableInfiniteScroll: false,
              reverse: false,
              autoPlay: true,
              onPageChanged: (index, reason) {
                setState(() {
                  homeData.current_slider = index;
                });
              }),
          items: homeData.bannerOneImageList.map((i) {
            return Builder(
              builder: (BuildContext context) {
                return Padding(
                  padding: const EdgeInsets.only(
                      left: 9.0, right: 9, top: 20.0, bottom: 20),
                  child: Container(
                    //color: Colors.amber,
                    width: double.infinity,
                    child: InkWell(
                      onTap: () {
                        var url =
                            i.url?.split(AppConfig.DOMAIN_PATH).last ?? "";
                        print(url);
                        GoRouter.of(context).go(url);
                      },
                      child: AIZImage.radiusImage(i.photo, 6),
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
      );
    } else if (!homeData.isBannerOneInitial &&
        homeData.bannerOneImageList.length == 0) {
      return Container(
          height: 100,
          child: Center(
              child: Text(
            AppLocalizations.of(context)!.no_carousel_image_found,
            style: TextStyle(color: MyTheme.font_grey),
          )));
    } else {
      // should not be happening
      return Container(
        height: 100,
      );
    }
  }

  Widget buildHomeBannerTwo(context, HomePresenter homeData) {
    if (homeData.isBannerTwoInitial &&
        homeData.bannerTwoImageList.length == 0) {
      return Padding(
          padding:
              const EdgeInsets.only(left: 18.0, right: 18, top: 10, bottom: 10),
          child: ShimmerHelper().buildBasicShimmer(height: 120));
    } else if (homeData.bannerTwoImageList.length > 0) {
      return Padding(
        padding: app_language_rtl.$!
            ? const EdgeInsets.only(right: 9.0)
            : const EdgeInsets.only(left: 9.0),
        child: CarouselSlider(
          options: CarouselOptions(
              aspectRatio: 270 / 120,
              viewportFraction: 0.7,
              enableInfiniteScroll: true,
              reverse: false,
              autoPlay: false,
              autoPlayInterval: Duration(seconds: 5),
              autoPlayAnimationDuration: Duration(milliseconds: 1000),
              autoPlayCurve: Curves.easeInExpo,
              enlargeCenterPage: false,
              scrollDirection: Axis.horizontal,
              onPageChanged: (index, reason) {
                // setState(() {
                //   homeData.current_slider = index;
                // });
              }),
          items: homeData.bannerTwoImageList.map((i) {
            return Builder(
              builder: (BuildContext context) {
                return Padding(
                  padding: const EdgeInsets.only(
                      left: 1.0, right: 1, top: 20.0, bottom: 10),
                  child: Container(
                      width: double.infinity,
                      child: InkWell(
                          onTap: () {
                            var url =
                                i.url?.split(AppConfig.DOMAIN_PATH).last ?? "";
                            print(url);
                            GoRouter.of(context).go(url);
                          },
                          child: AIZImage.radiusImage(i.photo, 6))),
                );
              },
            );
          }).toList(),
        ),
      );
    } else if (!homeData.isCarouselInitial &&
        homeData.carouselImageList.length == 0) {
      return Container(
          height: 100,
          child: Center(
              child: Text(
            AppLocalizations.of(context)!.no_carousel_image_found,
            style: TextStyle(color: MyTheme.font_grey),
          )));
    } else {
      // should not be happening
      return Container(
        height: 100,
      );
    }
  }

  AppBar buildAppBar(double statusBarHeight, BuildContext context) {
    return AppBar(
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.red, // <-- SEE HERE
        statusBarIconBrightness:
            Brightness.dark, //<-- For Android SEE HERE (dark icons)
        statusBarBrightness:
            Brightness.light, //<-- For iOS SEE HERE (dark icons)
      ),
      automaticallyImplyLeading: false,
      // Don't show the leading button
      backgroundColor: Colors.white,
      centerTitle: false,
      elevation: 0,
      flexibleSpace: Padding(
          // padding:
          //     const EdgeInsets.only(top: 40.0, bottom: 22, left: 18, right: 18),
          padding:
              const EdgeInsets.only(top: 10.0, bottom: 10, left: 0, right: 18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: Image.asset(
                  'assets/impexally.png',
                  height: 36,
                ),
              ),
              Expanded(child: buildHomeSearchBox(context)),
              SizedBox(width: 10),
              buildCartIcon(),
            ],
          )),
    );
  }

  buildCartIcon() {
    return GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return Profile();
          }));
        },
        child: Container(
          width: 36,
          height: 36,
          padding: EdgeInsets.all(8),
          child: Icon(
            Icons.person_outlined,
            color: const Color.fromARGB(255, 46, 41, 41),
            size: 25,
          ),
        ));
  }

  buildHomeSearchBox(BuildContext context) {
    return GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return Filter();
          }));
        },
        child: Container(
          height: 40,
          decoration: BoxDecorations.buildBoxDecoration_2(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  AppLocalizations.of(context)!.search_anything,
                  style:
                      TextStyle(fontSize: 13.0, color: MyTheme.textfield_grey),
                ),
                Image.asset(
                  'assets/search.png',
                  height: 16,
                  //color: MyTheme.dark_grey,
                  color: MyTheme.dark_grey,
                )
              ],
            ),
          ),
        ));
  }

  Container buildProductLoadingContainer(HomePresenter homeData) {
    return Container(
      height: homeData.showAllLoadingContainer ? 36 : 0,
      width: double.infinity,
      color: Colors.white,
      child: Center(
        child: Text(
            homeData.totalAllProductData == homeData.allProductList.length
                ? AppLocalizations.of(context)!.no_more_products_ucf
                : AppLocalizations.of(context)!.loading_more_products_ucf),
      ),
    );
  }
}
