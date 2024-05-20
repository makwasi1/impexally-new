import 'package:active_ecommerce_flutter/custom/aiz_route.dart';
import 'package:active_ecommerce_flutter/custom/box_decorations.dart';
import 'package:active_ecommerce_flutter/custom/btn.dart';
import 'package:active_ecommerce_flutter/custom/device_info.dart';
import 'package:active_ecommerce_flutter/custom/text_styles.dart';
import 'package:active_ecommerce_flutter/custom/toast_component.dart';
import 'package:active_ecommerce_flutter/custom/useful_elements.dart';
import 'package:active_ecommerce_flutter/data_model/cart_response.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_flutter/helpers/shimmer_helper.dart';
import 'package:active_ecommerce_flutter/helpers/system_config.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:active_ecommerce_flutter/presenter/cart_counter.dart';
import 'package:active_ecommerce_flutter/repositories/cart_repository.dart';
import 'package:active_ecommerce_flutter/screens/select_address.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

import '../data_model/product_detail.dart';
import '../data_model/products_model.dart';
import 'cart.dart';

class ProductVariants extends StatefulWidget {
  ProductVariants(
      {Key? key,
      this.has_bottomnav,
      this.variation,
      this.from_navigation = false,
      this.counter})
      : super(key: key);
  final bool? has_bottomnav;
  final bool from_navigation;
  final CartCounter? counter;
  final ProductMiniDetail? variation;

  @override
  _ProductVariantsState createState() => _ProductVariantsState();
}

class _ProductVariantsState extends State<ProductVariants> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  ScrollController _mainScrollController = ScrollController();
  var _shopList = [];
  CartResponse? _shopResponse;
  bool _isInitial = true;
  var _cartTotal = 0.00;
  var _cartTotalString = ". . .";
  ProductMiniDetail? _singleProduct;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    fetchVariations();

    /*print("user data");
    print(is_logged_in.$);
    print(access_token.value);
    print(user_id.$);
    print(user_name.$);*/

    if (is_logged_in.$ == true) {
      fetchData();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _mainScrollController.dispose();
  }

  getCartCount() {
    Provider.of<CartCounter>(context, listen: false).getCount();
    // var res = await CartRepository().getCartCount();
    // widget.counter.controller.sink.add(res.count);
  }

  fetchVariations() async {
    if (widget.variation != null) {
      _singleProduct = widget.variation;
    }
    print("Variation ${widget.variation}");
    setState(() {});
  }

  onPressAddToCart(context, snackbar) {
    addToCart(mode: "add_to_cart", context: context, snackbar: snackbar);
  }

  addToCart({mode, BuildContext? context, snackbar = null, ProductMiniDetail? variation}) async {
    var cartAddResponse = await CartRepository().getCartAddResponse(
        6, "5", 18, 10, 10);

    if (cartAddResponse.result == false) {
      ToastComponent.showDialog(cartAddResponse.message,
          gravity: Toast.center, duration: Toast.lengthLong);
      return;
    } else {
      Provider.of<CartCounter>(context!, listen: false).getCount();

      if (mode == "add_to_cart") {
        if (snackbar != null && context != null) {
          ScaffoldMessenger.of(context).showSnackBar(snackbar);
        }
        reset();
        // fetchAll();
      } else if (mode == 'buy_now') {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return ProductVariants(has_bottomnav: false, variation: variation);
        })).then((value) {
          onPopped(value);
        });
      }
    }
  }

  fetchData() async {
    getCartCount();
    CartResponse cartResponseList =
        await CartRepository().getCartResponseList(user_id.$);

    if (cartResponseList != null || cartResponseList.data!.length > 0) {
      _shopList = cartResponseList.data!;
      _shopResponse = cartResponseList;
      getSetCartTotal();
    }
    _isInitial = false;

    setState(() {});
  }

  getSetCartTotal() {
    _cartTotalString = _shopResponse!.grandTotal!.replaceAll(
        SystemConfig.systemCurrency!.code!,
        SystemConfig.systemCurrency!.symbol!);

    setState(() {});
  }

  onQuantityIncrease(seller_index, item_index) {
    if (_shopList[seller_index].cartItems[item_index].quantity <
        _shopList[seller_index].cartItems[item_index].upperLimit) {
      _shopList[seller_index].cartItems[item_index].quantity++;
      // getSetCartTotal();
      setState(() {});
      process(mode: "update");
    } else {
      ToastComponent.showDialog(
          "${AppLocalizations.of(context)!.cannot_order_more_than} ${_shopList[seller_index].cartItems[item_index].upperLimit} ${AppLocalizations.of(context)!.items_of_this_all_lower}",
          gravity: Toast.center,
          duration: Toast.lengthLong);
    }
  }

  onQuantityDecrease(seller_index, item_index) {
    if (_shopList[seller_index].cartItems[item_index].quantity >
        _shopList[seller_index].cartItems[item_index].lowerLimit) {
      _shopList[seller_index].cartItems[item_index].quantity--;
      // getSetCartTotal();
      setState(() {});
      process(mode: "update");
    } else {
      ToastComponent.showDialog(
          "${AppLocalizations.of(context)!.cannot_order_more_than} ${_shopList[seller_index].cartItems[item_index].lowerLimit} ${AppLocalizations.of(context)!.items_of_this_all_lower}",
          gravity: Toast.center,
          duration: Toast.lengthLong);
    }
  }

  onPressDelete(cart_id) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              contentPadding: EdgeInsets.only(
                  top: 16.0, left: 2.0, right: 2.0, bottom: 2.0),
              content: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Text(
                  AppLocalizations.of(context)!
                      .are_you_sure_to_remove_this_item,
                  maxLines: 3,
                  style: TextStyle(color: MyTheme.font_grey, fontSize: 14),
                ),
              ),
              actions: [
                Btn.basic(
                  child: Text(
                    AppLocalizations.of(context)!.cancel_ucf,
                    style: TextStyle(color: MyTheme.medium_grey),
                  ),
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                ),
                Btn.basic(
                  color: MyTheme.soft_accent_color,
                  child: Text(
                    AppLocalizations.of(context)!.confirm_ucf,
                    style: TextStyle(color: MyTheme.dark_grey),
                  ),
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                    confirmDelete(cart_id);
                  },
                ),
              ],
            ));
  }

  confirmDelete(cart_id) async {
    var cartDeleteResponse =
        await CartRepository().getCartDeleteResponse(cart_id);

    if (cartDeleteResponse.result == true) {
      ToastComponent.showDialog(cartDeleteResponse.message,
          gravity: Toast.center, duration: Toast.lengthLong);

      reset();
      fetchData();
    } else {
      ToastComponent.showDialog(cartDeleteResponse.message,
          gravity: Toast.center, duration: Toast.lengthLong);
    }
  }

  onPressUpdate() {
    process(mode: "update");
  }

  onPressProceedToShipping() {
    process(mode: "proceed_to_shipping");
  }

  process({mode}) async {
    var cart_ids = [];
    var cart_quantities = [];
    if (_shopList.length > 0) {
      _shopList.forEach((shop) {
        if (shop.cartItems.length > 0) {
          shop.cartItems.forEach((cart_item) {
            cart_ids.add(cart_item.id);
            cart_quantities.add(cart_item.quantity);
          });
        }
      });
    }

    if (cart_ids.length == 0) {
      ToastComponent.showDialog(AppLocalizations.of(context)!.cart_is_empty,
          gravity: Toast.center, duration: Toast.lengthLong);
      return;
    }

    var cart_ids_string = cart_ids.join(',').toString();
    var cart_quantities_string = cart_quantities.join(',').toString();

    print(cart_ids_string);
    print(cart_quantities_string);

    var cartProcessResponse = await CartRepository()
        .getCartProcessResponse(cart_ids_string, cart_quantities_string);

    if (cartProcessResponse.result == false) {
      ToastComponent.showDialog(cartProcessResponse.message,
          gravity: Toast.center, duration: Toast.lengthLong);
    } else {
      // cart update message
      // remove on
      // ToastComponent.showDialog(cartProcessResponse.message,
      //     gravity: Toast.center, duration: Toast.lengthLong);

      if (mode == "update") {
        // reset();
        fetchData();
      } else if (mode == "proceed_to_shipping") {
        AIZRoute.push(context, SelectAddress()).then((value) {
          onPopped(value);
        });
      }
    }
  }

  reset() {
    _shopList = [];
    _isInitial = true;
    _cartTotal = 0.00;
    _cartTotalString = ". . .";

    setState(() {});
  }

  Future<void> _onRefresh() async {
    reset();
    fetchData();
  }

  onPopped(value) async {
    reset();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    SnackBar _addedToCartSnackbar = SnackBar(
      content: Text(
        AppLocalizations.of(context)!.added_to_cart,
        style: TextStyle(color: MyTheme.font_grey),
      ),
      backgroundColor: MyTheme.soft_accent_color,
      duration: const Duration(seconds: 3),
      action: SnackBarAction(
        label: AppLocalizations.of(context)!.show_cart_all_capital,
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return Cart(has_bottomnav: false);
          })).then((value) {
            onPopped(value);
          });
        },
        textColor: MyTheme.accent_color,
        disabledTextColor: Colors.grey,
      ),
    );
    return Directionality(
      textDirection:
          app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
          key: _scaffoldKey,
          //drawer: MainDrawer(),
          backgroundColor: Colors.white,
          appBar: buildAppBar(context),
          body: Stack(
            children: [
              RefreshIndicator(
                color: MyTheme.accent_color,
                backgroundColor: Colors.white,
                onRefresh: _onRefresh,
                displacement: 0,
                child: CustomScrollView(
                  controller: _mainScrollController,
                  physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()),
                  slivers: [
                    SliverList(
                      delegate: SliverChildListDelegate([
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: _singleProduct != null
                              ? buildCartSellerItemCard()
                              : Container(),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 16.0, right: 16.0),
                          child: Divider(
                            color: MyTheme.light_grey,
                            thickness: 1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: buildVariationsSection(),
                        ),
                        Container(
                          height: widget.has_bottomnav! ? 140 : 100,
                        )
                      ]),
                    )
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: buildBottomContainer(_addedToCartSnackbar),
              )
            ],
          )),
    );
  }

  Widget buildBottomContainer(_addedToCartSnackbar) {
    return BottomAppBar(
      color: MyTheme.white.withOpacity(0.9),
      child: Row(
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: EdgeInsets.all(1.0),
            child: IconButton(
              icon: Icon(Icons.call),
              color: MyTheme.dark_font_grey,
              onPressed: () {
                // Add your chat functionality here
              },
            ),
          ),
          SizedBox(
            width: 3,
          ),
          Container(
            padding: EdgeInsets.all(1.0),
            child: IconButton(
              icon: Icon(Icons.shopping_cart_outlined),
              color: MyTheme.dark_font_grey,
              onPressed: () {
                onPressAddToCart(context, _addedToCartSnackbar);
              },
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            height: 40,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 45, vertical: 5),
                  backgroundColor: MyTheme.accent_color // foreground
                  ),
              onPressed: () {
                // onPressBuyNow(context, _productDetails!.products!.variation);
              },
              child: Text(
                "Place Order Now",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      leading: Builder(
        builder: (context) => widget.from_navigation
            ? UsefulElements.backToMain(context, go_back: false)
            : UsefulElements.backButton(context),
      ),
      title: Text(
        "Comfirm Color & Size",
        style: TextStyles.buildAppBarTexStyle(),
      ),
      elevation: 0.0,
      titleSpacing: 0,
    );
  }

  buildCartSellerList() {
    if (is_logged_in.$ == false) {
      return Container(
          height: 100,
          child: Center(
              child: Text(
            AppLocalizations.of(context)!.please_log_in_to_see_the_cart_items,
            style: TextStyle(color: MyTheme.font_grey),
          )));
    } else if (_isInitial && _shopList.length == 0) {
      return SingleChildScrollView(
          child: ShimmerHelper()
              .buildListShimmer(item_count: 5, item_height: 100.0));
    } else if (_shopList.length > 0) {
      return SingleChildScrollView(
        child: ListView.separated(
          separatorBuilder: (context, index) => SizedBox(
            height: 26,
          ),
          itemCount: _shopList.length,
          scrollDirection: Axis.vertical,
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    children: [
                      Text(
                        _shopList[index].name,
                        style: TextStyle(
                            color: MyTheme.dark_font_grey,
                            fontWeight: FontWeight.w700,
                            fontSize: 12),
                      ),
                      Spacer(),
                      Text(
                        _shopList[index].subTotal.replaceAll(
                                SystemConfig.systemCurrency!.code,
                                SystemConfig.systemCurrency!.symbol) ??
                            '',
                        style: TextStyle(
                            color: MyTheme.accent_color,
                            fontWeight: FontWeight.w700,
                            fontSize: 12),
                      ),
                    ],
                  ),
                ),
                buildCartSellerItemList(index),
              ],
            );
          },
        ),
      );
    } else if (!_isInitial && _shopList.length == 0) {
      return Container(
          height: 100,
          child: Center(
              child: Text(
            AppLocalizations.of(context)!.cart_is_empty,
            style: TextStyle(color: MyTheme.font_grey),
          )));
    }
  }

  SingleChildScrollView buildCartSellerItemList(seller_index) {
    return SingleChildScrollView(
      child: ListView.separated(
        separatorBuilder: (context, index) => SizedBox(
          height: 14,
        ),
        itemCount: _shopList[seller_index].cartItems.length,
        scrollDirection: Axis.vertical,
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return buildCartSellerItemCard();
        },
      ),
    );
  }

  buildVariationsItems() {
    return ListView.builder(
      itemCount: _singleProduct!.products!.variation!.length,
      itemBuilder: (context, index) {
        return Container(
          child: Column(
            children: [
              Row(
                children: [
                  Flexible(
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: Colors.red, // Border color
                        ),
                        color: Color.fromARGB(
                            255, 241, 199, 199), // Background color
                      ),
                      child: Text(
                        "Select Product " +
                            _singleProduct!
                                .products!.variation![index].labelNames!,
                        style: TextStyle(
                          color: const Color.fromARGB(255, 171, 15, 4),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "(" +
                            "32" +
                            ")" +
                            _singleProduct!
                                .products!.variation![index].labelNames! +
                            " is Selected",
                      ),
                    ),
                  )
                ],
              ),
              Divider(
                color: MyTheme.light_grey,
                thickness: 1,
              ),
            ],
          ),
        );
      },
    );
  }

  String getVariationOptionName(String variationOption) {
    String optionName = "";
    String serialized = variationOption;
    RegExp regExp = RegExp(r's:11:"option_name";s:\d+:"(.*?)"');

    var matches = regExp.allMatches(serialized);
    for (Match match in matches) {
      optionName = match.group(1)!;
    }
    return optionName;
  }

  Widget buildVariationsOptions(idx) {
    return ListView.builder(
      itemCount:
          _singleProduct!.products!.variation![idx].variationOptions!.length,
      itemBuilder: (context, index) {
        return Container(
          child: Row(
            children: _singleProduct!
                .products!.variation![idx].variationOptions!
                .map((option) {
              return Flexible(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: Colors.red, // Border color
                    ),
                    color:
                        Color.fromARGB(255, 241, 199, 199), // Background color
                  ),
                  child: Text(
                    getVariationOptionName(option.optionNames!),
                    style: TextStyle(
                      color: const Color.fromARGB(255, 171, 15, 4),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  buildVariationsSection() {
    // print("Variation ${widget.variation!.image!.imageDefault}");
    return Container(
      height: 500,
      decoration: BoxDecorations.buildBoxDecoration_1(),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            //build a list of all the variation
            Container(
              width: DeviceInfo(context).width! / 1.2,
              height: DeviceInfo(context).height! / 1,
              child: buildVariations(),
            ),

            Spacer(),
          ]),
    );
  }

  buildCartSellerItemCard() {
    // print("Variation ${widget.variation!.image!.imageDefault}");
    return Container(
      height: 120,
      decoration: BoxDecorations.buildBoxDecoration_1(),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
                width: DeviceInfo(context).width! / 4,
                height: 120,
                child: ClipRRect(
                    borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(6), right: Radius.zero),
                    child: FadeInImage.assetNetwork(
                      placeholder: 'assets/placeholder.png',
                      image: "https://seller.impexally.com/uploads/images/" +
                          widget.variation!.image![0].imageDefault!,
                      fit: BoxFit.cover,
                    ))),
            Container(
              //color: Colors.red,
              width: DeviceInfo(context).width! / 2,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.variation != null
                          ? widget.variation!.productDetails![0].title!
                          : "",
                      maxLines: 2,
                      style: TextStyle(
                          color: MyTheme.dark_font_grey,
                          fontSize: 16,
                          fontWeight: FontWeight.w400),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 18.0),
                      child: Row(
                        children: [
                          Text(
                            SystemConfig.currency +
                                " " +
                                widget.variation!.products!.priceDiscounted!,
                            style: TextStyle(
                                color: MyTheme.accent_color,
                                fontSize: 14,
                                fontWeight: FontWeight.w700),
                          ),
                          SizedBox(width: 10),
                          Text(
                            SystemConfig.currency +
                                " " +
                                widget.variation!.products!.price!,
                            style: TextStyle(
                                decoration: TextDecoration.lineThrough,
                                color: MyTheme.accent_color,
                                fontSize: 14,
                                fontWeight: FontWeight.w700),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [],
              ),
            )
          ]),
    );
  }

  buildVariations() {
    return Column(
      children: [
        // Product Size Selection
        buildSizeSelection(),
        Divider(color: MyTheme.light_grey, thickness: 1),

        // Product Color Selection
        buildColorSelection(),
        Divider(color: MyTheme.light_grey, thickness: 1),

        // Product Quantity Selection
        buildQuantitySelection(),
      ],
    );
  }

  Widget buildSizeSelection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: Colors.red, // Border color
              ),
              color: Color.fromARGB(255, 241, 199, 199), // Background color
            ),
            child: Text(
              "Select Product Size",
              style: TextStyle(
                color: const Color.fromARGB(255, 171, 15, 4),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          SizedBox(height: 8),
          Row(
            children: List.generate(_singleProduct!.products!.variation!.length,
                (index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    // Handle size selection
                  });
                },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: Colors.red, // Border color
                    ),
                    color:
                        Color.fromARGB(255, 241, 199, 199), // Background color
                  ),
                  child: Text(
                    _singleProduct!.products!.variation![index].labelNames!,
                    style: TextStyle(
                      color: Color.fromARGB(255, 194, 29, 17),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget buildColorSelection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: Colors.red, // Border color
              ),
              color: Color.fromARGB(255, 241, 199, 199), // Background color
            ),
            child: Text(
              "Select Product Color",
              style: TextStyle(
                color: const Color.fromARGB(255, 171, 15, 4),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          SizedBox(height: 8),
          Row(
            children: List.generate(_singleProduct!.products!.variation!.length,
                (index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    // Handle color selection
                  });
                },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: Colors.red, // Border color
                    ),
                    color:
                        Color.fromARGB(255, 241, 199, 199), // Background color
                  ),
                  child: Image.network(
                    "https://seller.impexally.com/uploads/images/" +
                        _singleProduct!.image![index].imageDefault!,
                    width: 50,
                    height: 50,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget buildQuantitySelection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: Colors.red, // Border color
              ),
              color: Color.fromARGB(255, 241, 199, 199), // Background color
            ),
            child: Text(
              "Select Product Qty.",
              style: TextStyle(
                color: const Color.fromARGB(255, 171, 15, 4),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          SizedBox(width: 18),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.remove),
                onPressed: () {
                  setState(() {
                    // Handle quantity decrease
                  });
                },
              ),
              Text(
                "1", // Display selected quantity
                style: TextStyle(
                  color: MyTheme.accent_color,
                  fontSize: 16,
                ),
              ),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  setState(() {
                    // Handle quantity increase
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
