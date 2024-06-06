import 'package:active_ecommerce_flutter/custom/aiz_route.dart';
import 'package:active_ecommerce_flutter/custom/box_decorations.dart';
import 'package:active_ecommerce_flutter/custom/btn.dart';
import 'package:active_ecommerce_flutter/custom/device_info.dart';
import 'package:active_ecommerce_flutter/custom/text_styles.dart';
import 'package:active_ecommerce_flutter/custom/toast_component.dart';
import 'package:active_ecommerce_flutter/custom/useful_elements.dart';
import 'package:active_ecommerce_flutter/data_model/cart_response.dart';
import 'package:active_ecommerce_flutter/data_model/login_response.dart';
import 'package:active_ecommerce_flutter/helpers/auth_helper.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_flutter/helpers/shimmer_helper.dart';
import 'package:active_ecommerce_flutter/helpers/system_config.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:active_ecommerce_flutter/presenter/cart_counter.dart';
import 'package:active_ecommerce_flutter/repositories/cart_repository.dart';
import 'package:active_ecommerce_flutter/screens/login.dart';
import 'package:active_ecommerce_flutter/screens/select_address.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

import '../data_model/new_cart.dart';
import '../data_model/product_detail.dart';
import '../repositories/product_repository.dart';

class Cart extends StatefulWidget {
  Cart(
      {Key? key,
      this.has_bottomnav,
      this.from_navigation = false,
      this.counter})
      : super(key: key);
  final bool? has_bottomnav;
  final bool from_navigation;
  final CartCounter? counter;

  @override
  _CartState createState() => _CartState();
}

class _CartState extends State<Cart> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  ScrollController _mainScrollController = ScrollController();
  var _shopList = [];
  CartModel? _shopResponse;
  bool _isInitial = true;
  var _cartTotal = 0.00;
  var _cartTotalString = ". . .";
  ProductMiniDetail? _productDetails;
  int? _cartId;

  @override
  void initState() {
    super.initState();
    checkUser();
    fetchData();
  }

  //check if user is logged in if not roiute to Login 
  
  checkUser() async {
  //get user is logged in status
    LoginResponse res = await AuthHelper().getUserDetailsFromSharedPref();
    if (res.result == false) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Login(),
        ),
      );
    }
  }


  @override
  void dispose() {
    super.dispose();
    _mainScrollController.dispose();
  }

  getCartCount() {
    Provider.of<CartCounter>(context, listen: false).getCount();
  }

  fetchData() async {
    // getCartCount();
    LoginResponse res = await AuthHelper().getUserDetailsFromSharedPref();
    CartModel? cartResponseList =
        await CartRepository().getCartResponseList(res.user!.id!);

    if (cartResponseList!.cart != null) {
      _shopList = cartResponseList.cart!.items!;
      // _cartTotalString = cartResponseList.cartTotal.toString();
      _cartId = cartResponseList.cart!.id;
      getSetCartTotal();
      _isInitial = false;

      setState(() {});
    } else {
      _shopList = [];
      _isInitial = false;

      setState(() {});
    }
  }

  getSetCartTotal() async {
    LoginResponse res = await AuthHelper().getUserDetailsFromSharedPref();
    CartModel? cartResponseList =
        await CartRepository().getCartResponseList(res.user!.id);
    if (cartResponseList!.cart != null) {
      _cartTotalString = cartResponseList.cartTotal.toString();
      setState(() {});
    }
  }

  onQuantityIncrease(seller_index) async {
    if (int.tryParse(_shopList[seller_index].quantity)! <
        int.tryParse(_shopList[seller_index].product.stock)!) {
      try {
        int? currentQuantity = int.tryParse(_shopList[seller_index].quantity);
        if (currentQuantity != null) {
          currentQuantity++;
          _shopList[seller_index].quantity = currentQuantity.toString();
        }
        // ToastComponent.showDialog("Updating Cart...",
        //     gravity: Toast.center, duration: Toast.lengthLong);

        await CartRepository().getCartProcessResponse(
            _shopList[seller_index].id.toString(),
            _shopList[seller_index].quantity).then((value) => getSetCartTotal());
        // fetchData();
        // setState(() {});
      } catch (e) {
        print(e);
      }
    } else {
      ToastComponent.showDialog(
          "${AppLocalizations.of(context)!.cannot_order_more_than} ${_shopList[seller_index].product.stock!} ${AppLocalizations.of(context)!.items_of_this_all_lower}",
          gravity: Toast.center,
          duration: Toast.lengthLong);
    }
  }

  onQuantityDecrease(seller_index, item_index) async {
    if (int.tryParse(_shopList[seller_index].quantity)! > 1) {
      try {
        int? currentQuantity = int.tryParse(_shopList[seller_index].quantity);
        if (currentQuantity != null) {
          currentQuantity--;
          _shopList[seller_index].quantity = currentQuantity.toString();
        }
        // ToastComponent.showDialog("Updating Cart...",
        //     gravity: Toast.center, duration: Toast.lengthLong);
        await CartRepository().getCartProcessResponse(
            _shopList[seller_index].id.toString(),
            _shopList[seller_index].quantity).then((value) => getSetCartTotal());
        // fetchData();
        // setState(() {});
      } catch (e) {
        print(e);
      }
    } else {
      ToastComponent.showDialog(
          "${AppLocalizations.of(context)!.cannot_order_more_than} 1 ${AppLocalizations.of(context)!.items_of_this_all_lower}",
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
    LoginResponse res = await AuthHelper().getUserDetailsFromSharedPref();
    var cartDeleteResponse =
        await CartRepository().getCartDeleteResponse(cart_id, res.user!.id);

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
    LoginResponse res = await AuthHelper().getUserDetailsFromSharedPref();
    if (res.result == false) {  
      ToastComponent.showDialog(
          "You must be logged in to proceed to shipping",
          gravity: Toast.center,
          duration: Toast.lengthLong);
      //navigate to login
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Login(),
        ),
      );
      return;
      
    } else {
      if (_shopList.length == 0) {
        ToastComponent.showDialog(
            AppLocalizations.of(context)!.cart_is_empty,
            gravity: Toast.center,
            duration: Toast.lengthLong);
        return;
      }
    }
    AIZRoute.push(
        context,
        SelectAddress(
          cartList: _shopList,
          cartAmount: _cartTotalString,
          cartId: _cartId,
        )).then((value) {
      onPopped(value);
    });
    // }
    // }
  }

  Future<ProductMiniDetail?> fetchProductDetails(id) async {
    var productDetailsResponse =
        await ProductRepository().getProductDetails(slug: id.toString());

    // if (productDetailsResponse.products!.productDetail!.description != null) {
    _productDetails = productDetailsResponse;

    // setState(() {});
    return _productDetails;
  }

  reset() {
    _shopList = [];
    _isInitial = true;
    _cartTotal = 0.00;
    _cartTotalString = ". . .";
    getCartCount();
    setState(() {});
  }

  Future<void> _onRefresh() async {
    reset();
    fetchData();
    getCartCount();
  }

  onPopped(value) async {
    reset();
    fetchData();
    getCartCount();
  }

  @override
  Widget build(BuildContext context) {
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
                          child: buildCartSellerList(),
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
                child: buildBottomContainer(),
              )
            ],
          )),
    );
  }

  Container buildBottomContainer() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        /*border: Border(
                  top: BorderSide(color: MyTheme.light_grey,width: 1.0),
                )*/
      ),

      height: widget.has_bottomnav! ? 200 : 120,
      //color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4),
        child: Column(
          children: [
            Container(
              height: 40,
              width: double.infinity,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6.0),
                  color: MyTheme.soft_accent_color),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      AppLocalizations.of(context)!.total_amount_ucf,
                      style: TextStyle(
                          color: MyTheme.dark_font_grey,
                          fontSize: 16,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text("GH₵ " + _cartTotalString,
                        style: TextStyle(
                            color: MyTheme.accent_color,
                            fontSize: 18,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Container(
                    height: 58,
                    width: (MediaQuery.of(context).size.width - 48),
                    // width: (MediaQuery.of(context).size.width - 48) * (2 / 3),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border:
                            Border.all(color: MyTheme.accent_color, width: 1),
                        borderRadius: app_language_rtl.$!
                            ? const BorderRadius.only(
                                topLeft: const Radius.circular(6.0),
                                bottomLeft: const Radius.circular(6.0),
                                topRight: const Radius.circular(6.0),
                                bottomRight: const Radius.circular(6.0),
                              )
                            : const BorderRadius.only(
                                topLeft: const Radius.circular(6.0),
                                bottomLeft: const Radius.circular(6.0),
                                topRight: const Radius.circular(6.0),
                                bottomRight: const Radius.circular(6.0),
                              )),
                    child: Btn.basic(
                      minWidth: MediaQuery.of(context).size.width,
                      color: MyTheme.accent_color,
                      shape: app_language_rtl.$!
                          ? RoundedRectangleBorder(
                              borderRadius: const BorderRadius.only(
                              topLeft: const Radius.circular(6.0),
                              bottomLeft: const Radius.circular(6.0),
                              topRight: const Radius.circular(0.0),
                              bottomRight: const Radius.circular(0.0),
                            ))
                          : RoundedRectangleBorder(
                              borderRadius: const BorderRadius.only(
                              topLeft: const Radius.circular(0.0),
                              bottomLeft: const Radius.circular(0.0),
                              topRight: const Radius.circular(6.0),
                              bottomRight: const Radius.circular(6.0),
                            )),
                      child: Text(
                        "PROCEED TO SHIPPING",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700),
                      ),
                      onPressed: () {
                        onPressProceedToShipping();
                      },
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
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
        AppLocalizations.of(context)!.shopping_cart_ucf,
        style: TextStyles.buildAppBarTexStyle(),
      ),
      elevation: 0.0,
      titleSpacing: 0,
    );
  }

  buildCartSellerList() {
    if (_isInitial && _shopList.length == 0) {
      return SingleChildScrollView(
          child: ShimmerHelper()
              .buildListShimmer(item_count: 5, item_height: 100.0));
    } else if (_shopList.length > 0) {
      return buildCartSellerItemList();
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

  SingleChildScrollView buildCartSellerItemList() {
    return SingleChildScrollView(
      child: ListView.separated(
        separatorBuilder: (context, index) => SizedBox(
          height: 14,
        ),
        itemCount: _shopList.length,
        scrollDirection: Axis.vertical,
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return buildCartSellerItemCard(index, index);
        },
      ),
    );
  }

  buildCartSellerItemCard(seller_index, item_index) {
    return FutureBuilder(
      future: fetchProductDetails(_shopList[seller_index].productId),
      builder: (context, AsyncSnapshot<ProductMiniDetail?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ShimmerHelper().buildListShimmer(
              item_count: 5,
              item_height:
                  100.0); // Show loading indicator while waiting for data
        } else if (snapshot.hasError) {
          return Text(
              "Error: ${snapshot.error}"); // Show error if something went wrong
        } else if (snapshot.hasData) {
          var prod = snapshot.data; // Your product details object
          return Container(
            height: 120,
            decoration: BoxDecorations.buildBoxDecoration_1(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                            prod!.image![0]
                                .imageDefault!, // Assuming 'image' is the field for image URL
                        fit: BoxFit.cover,
                      )),
                ),
                Container(
                  //color: Colors.red,
                  width: DeviceInfo(context).width! / 3,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          prod.productDetails!.first.title ?? '',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: TextStyle(
                              color: MyTheme.font_grey,
                              fontSize: 12,
                              fontWeight: FontWeight.w400),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 23.0),
                          child: Row(
                            children: [
                              Text(
                                'GH₵ ' +
                                    _shopList[seller_index]
                                        .product
                                        .priceDiscounted!,
                                textAlign: TextAlign.left,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: TextStyle(
                                    color: MyTheme.accent_color,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                GestureDetector(
                  onTap: () {
                            onPressDelete(_shopList[seller_index].id);
                          },
                  child: Container(
                    width: 32,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 14.0),
                            child: Image.asset(
                              'assets/trash.png',
                              height: 16,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          onQuantityIncrease(seller_index);
                        },
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecorations
                              .buildCartCircularButtonDecoration(),
                          child: Icon(
                            Icons.add,
                            color: MyTheme.grey_153,
                            size: 12,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                        child: Text(
                          _shopList[seller_index].quantity.toString(),
                          style: TextStyle(
                              color: MyTheme.accent_color, fontSize: 16),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          onQuantityDecrease(seller_index, item_index);
                        },
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecorations
                              .buildCartCircularButtonDecoration(),
                          child: Icon(
                            Icons.remove,
                            color: MyTheme.grey_153,
                            size: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        } else {
          return Text(
              "No data available"); // Handle case where no data is returned
        }
      },
    );
  }

  buildCartSellerItemCard1(seller_index, item_index) {
    //get product details by porduct id
    var prod = fetchProductDetails(_shopList[seller_index].productId);
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
                      image: "",
                      fit: BoxFit.cover,
                    ))),
            Container(
              //color: Colors.red,
              width: DeviceInfo(context).width! / 3,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _shopList[seller_index].product.slug ?? '',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(
                          color: MyTheme.font_grey,
                          fontSize: 12,
                          fontWeight: FontWeight.w400),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 23.0),
                      child: Row(
                        children: [
                          Text(
                            'GH₵ ' +
                                _shopList[seller_index]
                                    .product
                                    .priceDiscounted!,
                            textAlign: TextAlign.left,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: TextStyle(
                                color: MyTheme.accent_color,
                                fontSize: 16,
                                fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Spacer(),
            Container(
              width: 32,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      onPressDelete(_shopList[seller_index].id);
                    },
                    child: Container(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 14.0),
                        child: Image.asset(
                          'assets/trash.png',
                          height: 16,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      onQuantityIncrease(seller_index);
                    },
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration:
                          BoxDecorations.buildCartCircularButtonDecoration(),
                      child: Icon(
                        Icons.add,
                        color: MyTheme.grey_153,
                        size: 12,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                    child: Text(
                      _shopList[seller_index].quantity.toString(),
                      style:
                          TextStyle(color: MyTheme.accent_color, fontSize: 16),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      onQuantityDecrease(seller_index, item_index);
                    },
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration:
                          BoxDecorations.buildCartCircularButtonDecoration(),
                      child: Icon(
                        Icons.remove,
                        color: MyTheme.grey_153,
                        size: 12,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ]),
    );
  }
}
