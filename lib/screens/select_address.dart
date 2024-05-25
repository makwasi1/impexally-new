import 'package:active_ecommerce_flutter/custom/btn.dart';
import 'package:active_ecommerce_flutter/custom/device_info.dart';
import 'package:active_ecommerce_flutter/custom/lang_text.dart';
import 'package:active_ecommerce_flutter/custom/toast_component.dart';
import 'package:active_ecommerce_flutter/custom/useful_elements.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_flutter/helpers/shimmer_helper.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:active_ecommerce_flutter/repositories/address_repository.dart';
import 'package:active_ecommerce_flutter/repositories/coupon_repository.dart';
import 'package:active_ecommerce_flutter/screens/address.dart';
import 'package:active_ecommerce_flutter/screens/checkout.dart';
import 'package:active_ecommerce_flutter/screens/shipping_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:toast/toast.dart';

import '../custom/box_decorations.dart';
import '../custom/enum_classes.dart';
import '../data_model/product_detail.dart';
import '../repositories/cart_repository.dart';
import '../repositories/product_repository.dart';

// ignore: must_be_immutable
class SelectAddress extends StatefulWidget {
  int? owner_id;
  final List<dynamic> cartList;
  SelectAddress({Key? key, this.owner_id, required this.cartList})
      : super(key: key);

  @override
  State<SelectAddress> createState() => _SelectAddressState();
}

class _SelectAddressState extends State<SelectAddress> {
  ScrollController _mainScrollController = ScrollController();

  // integer type variables
  int? _seleted_shipping_address = 0;
  String? _cartTotalString = ". . .";

  // list type variables
  List<dynamic> _shippingAddressList = [];
  ProductMiniDetail? _productDetails;

  TextEditingController _couponController = TextEditingController();
  // List<PickupPoint> _pickupList = [];
  // List<City> _cityList = [];
  // List<Country> _countryList = [];

  // String _shipping_cost_string = ". . .";

  // Boolean variables
  bool isVisible = true;
  bool _faceData = false;
  bool? _coupon_applied = false;

  //double variables
  double mWidth = 0;
  double mHeight = 0;

  fetchAll() {
    // if (is_logged_in.$ == true) {
    fetchShippingAddressList();
    //fetchPickupPoints();
    // }
    setState(() {});
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

  onCouponApply() async {
    var coupon_code = _couponController.text.toString();
    if (coupon_code == "") {
      ToastComponent.showDialog(AppLocalizations.of(context)!.enter_coupon_code,
          gravity: Toast.center, duration: Toast.lengthLong);
      return;
    }

    var couponApplyResponse =
        await CouponRepository().getCouponApplyResponse(coupon_code);
    if (couponApplyResponse.result == false) {
      ToastComponent.showDialog(couponApplyResponse.message,
          gravity: Toast.center, duration: Toast.lengthLong);
      return;
    }

    // reset_summary();
    // fetchSummary();
  }

  onCouponRemove() async {
    var couponRemoveResponse =
        await CouponRepository().getCouponRemoveResponse();

    if (couponRemoveResponse.result == false) {
      ToastComponent.showDialog(couponRemoveResponse.message,
          gravity: Toast.center, duration: Toast.lengthLong);
      return;
    }

    // reset_summary();
    // fetchSummary();
  }

  confirmDelete(cart_id) async {
    var cartDeleteResponse =
        await CartRepository().getCartDeleteResponse(cart_id);

    if (cartDeleteResponse.result == true) {
      ToastComponent.showDialog(cartDeleteResponse.message,
          gravity: Toast.center, duration: Toast.lengthLong);

      reset();
      // fetchData();
    } else {
      ToastComponent.showDialog(cartDeleteResponse.message,
          gravity: Toast.center, duration: Toast.lengthLong);
    }
  }

  onQuantityIncrease(seller_index) async {
    if (int.tryParse(widget.cartList[seller_index].quantity)! <
        int.tryParse(widget.cartList[seller_index].product.stock)!) {
      try {
        int? currentQuantity =
            int.tryParse(widget.cartList[seller_index].quantity);
        if (currentQuantity != null) {
          currentQuantity++;
          widget.cartList[seller_index].quantity = currentQuantity.toString();
        }
        ToastComponent.showDialog("Updating Cart...",
            gravity: Toast.center, duration: Toast.lengthLong);

        await CartRepository().getCartProcessResponse(
            widget.cartList[seller_index].id.toString(),
            widget.cartList[seller_index].quantity);
        // fetchData();
        setState(() {});
      } catch (e) {
        print(e);
      }
    } else {
      ToastComponent.showDialog(
          "${AppLocalizations.of(context)!.cannot_order_more_than} ${widget.cartList[seller_index].product.stock!} ${AppLocalizations.of(context)!.items_of_this_all_lower}",
          gravity: Toast.center,
          duration: Toast.lengthLong);
    }
  }

  onQuantityDecrease(seller_index, item_index) async {
    if (int.tryParse(widget.cartList[seller_index].quantity)! > 1) {
      try {
        int? currentQuantity =
            int.tryParse(widget.cartList[seller_index].quantity);
        if (currentQuantity != null) {
          currentQuantity--;
          widget.cartList[seller_index].quantity = currentQuantity.toString();
        }
        ToastComponent.showDialog("Updating Cart...",
            gravity: Toast.center, duration: Toast.lengthLong);
        await CartRepository().getCartProcessResponse(
            widget.cartList[seller_index].id.toString(),
            widget.cartList[seller_index].quantity);
        // fetchData();
        setState(() {});
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

  fetchShippingAddressList() async {
    var addressResponse = await AddressRepository().getAddressList();
    _shippingAddressList.addAll(addressResponse.addresses);
    if (_shippingAddressList.length > 0) {
      _seleted_shipping_address = _shippingAddressList[0].id;

      _shippingAddressList.forEach((address) {
        if (address.set_default == 1) {
          _seleted_shipping_address = address.id;
        }
      });
    }
    _faceData = true;
    setState(() {});

    // getSetShippingCost();
  }

  getSetCartTotal() {
    _cartTotalString = "560";
  }

  reset() {
    _shippingAddressList.clear();
    _faceData = false;
    _seleted_shipping_address = 0;
  }

  Future<void> _onRefresh() async {
    reset();
    // if (is_logged_in.$ == true) {
    fetchAll();
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

  onPopped(value) async {
    reset();
    fetchAll();
  }

  afterAddingAnAddress() {
    reset();
    fetchAll();
  }

  onPressProceed(context) async {
    if (_seleted_shipping_address == 0) {
      ToastComponent.showDialog(
          LangText(context).local!.choose_an_address_or_pickup_point,
          gravity: Toast.center,
          duration: Toast.lengthLong);
      return;
    }

    late var addressUpdateInCartResponse;

    if (_seleted_shipping_address != 0) {
      print(_seleted_shipping_address.toString() + "dddd");
      addressUpdateInCartResponse = await AddressRepository()
          .getAddressUpdateInCartResponse(
              address_id: _seleted_shipping_address);
    }
    if (addressUpdateInCartResponse.result == false) {
      ToastComponent.showDialog(addressUpdateInCartResponse.message,
          gravity: Toast.center, duration: Toast.lengthLong);
      return;
    }

    ToastComponent.showDialog(addressUpdateInCartResponse.message,
        gravity: Toast.center, duration: Toast.lengthLong);

    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return Checkout(
        order_id: 1,
        title: AppLocalizations.of(context)!.checkout_ucf,
        list: "offline",
        paymentFor: PaymentFor.ManualPayment,
        //offLinePaymentFor: OffLinePaymentFor.Order,
        rechargeAmount:
            0, // this is for wallet recharge amount, so set 0 for order))
      );
    })).then((value) {
      onPopped(value);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // if (is_logged_in.$ == true) {
    fetchAll();
    // }
  }

  @override
  void dispose() {
    super.dispose();
    _mainScrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    mHeight = MediaQuery.of(context).size.height;
    mWidth = MediaQuery.of(context).size.width;
    return Directionality(
      textDirection:
          app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          leading: UsefulElements.backButton(context),
          backgroundColor: MyTheme.white,
          title: buildAppbarTitle(context),
        ),
        backgroundColor: Colors.white,
        bottomNavigationBar: buildBottomAppBar(context),
        body: buildBody(context),
      ),
    );
  }

  RefreshIndicator buildBody(BuildContext context) {
    return RefreshIndicator(
      color: MyTheme.accent_color,
      backgroundColor: Colors.white,
      onRefresh: _onRefresh,
      displacement: 0,
      child: Container(
        child: buildBodyChildren(context),
      ),
    );
  }

  Widget buildBodyChildren(BuildContext context) {
    return buildShippingListContainer(context);
  }

  Container buildShippingListContainer(BuildContext context) {
    return Container(
      child: CustomScrollView(
        controller: _mainScrollController,
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          SliverList(
              delegate: SliverChildListDelegate([
            Padding(
                padding: const EdgeInsets.all(16.0),
                child: buildShippingInfoList()),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: buildAddOrEditAddress(context),
            ),
            SizedBox(
              height: 10,
            ),
            buildExpectedCartItems(),
            SizedBox(
              height: 10,
            ),
            Padding(
                padding: const EdgeInsets.all(16.0),
                child: buildCartSellerItemList()),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: buildApplyCouponRow(context),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(padding: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
              child: Text(
                "Order Details",
                // textAlign: TextAlign.start,
                style: TextStyle(
                   
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w700),
              ),),
            buildCartSummaryDetails(context),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: buildCartDeliveryGif(context),
            ),
          ]))
        ],
      ),
    );
  }


  //create a row with a with an car icon and a text widget
  Widget buildCartDeliveryGif(BuildContext context) {
    return Container(
  padding: EdgeInsets.all(16),
  color: Colors.grey[100],
  child: Row(
    children: [
      Container(
        width: 120,
        child: Icon(
          Icons.local_shipping_outlined,
          color: Colors.black,
          size: 34,
        ),
      ),
      Text(
        "Delivered by Impex Express",
        style: TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.w600),
      ),
    ],
  ),
);
  }

  //build order details summary widget
  Widget buildCartSummaryDetails(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(left:16, right: 16.0),
        child: Container(
          child: Column(
            children: [
              
              Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 120,
                        child: Text(
                         "Order Total",
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              color: MyTheme.font_grey,
                              fontSize: 14,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      Spacer(),
                      Text(
                        "GH₵ $_cartTotalString",
                        style: TextStyle(
                            color: MyTheme.font_grey,
                            fontSize: 14,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  )),
              Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 120,
                        child: Text(
                          "Bag Savings",
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              color: MyTheme.font_grey,
                              fontSize: 14,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      Spacer(),
                      Text(
                        "-GH₵.....",
                        style: TextStyle(
                            color: MyTheme.green,
                            fontSize: 14,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  )),
              Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 120,
                        child: Text(
                          "Coupon Discount",
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              color: MyTheme.font_grey,
                              fontSize: 14,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      Spacer(),
                      Text(
                       _coupon_applied! ? "GH₵ " : "No Coupon(s) Applied",
                        style: TextStyle(
                            color: MyTheme.accent_color,
                            fontSize: 14,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  )),
              Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 120,
                        child: Text(
                          "Delivery Fee",
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              color: MyTheme.font_grey,
                              fontSize: 14,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      Spacer(),
                      Text(
                        "GH₵ 15",
                        style: TextStyle(
                            color: MyTheme.font_grey,
                            fontSize: 14,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  )),
              Divider(),
              Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 120,
                        child: Text(
                          "Total Amount",
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              color: MyTheme.font_grey,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Spacer(),
                      Text(
                        "GH₵ ",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  )),
            ],
          ),
        ));
  }

  Widget buildExpectedCartItems() {
    return Container(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(left: 18, bottom: 10, top: 1),
            width: DeviceInfo(context).width,
            alignment: Alignment.centerLeft,
            child: Text(
              "Expected Deliveries",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w700),
            ),
          ),
          Container(
            color: MyTheme.white,
            child: Column(
              children: [],
            ),
          ),
        ],
      ),
    );
  }

  SingleChildScrollView buildCartSellerItemList() {
    return SingleChildScrollView(
      child: ListView.separated(
        separatorBuilder: (context, index) => SizedBox(
          height: 14,
        ),
        itemCount: widget.cartList.length,
        scrollDirection: Axis.vertical,
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return buildCartSellerItemCard(index, index);
        },
      ),
    );
  }

  Row buildApplyCouponRow(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 42,
          width: (MediaQuery.of(context).size.width - 32) * (2 / 3),
          child: TextFormField(
            controller: _couponController,
            readOnly: _coupon_applied!,
            autofocus: false,
            decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.enter_coupon_code,
                hintStyle:
                    TextStyle(fontSize: 14.0, color: MyTheme.textfield_grey),
                enabledBorder: app_language_rtl.$!
                    ? OutlineInputBorder(
                        borderSide: BorderSide(
                            color: MyTheme.textfield_grey, width: 0.5),
                        borderRadius: const BorderRadius.only(
                          topRight: const Radius.circular(8.0),
                          bottomRight: const Radius.circular(8.0),
                        ),
                      )
                    : OutlineInputBorder(
                        borderSide: BorderSide(
                            color: MyTheme.textfield_grey, width: 0.5),
                        borderRadius: const BorderRadius.only(
                          topLeft: const Radius.circular(8.0),
                          bottomLeft: const Radius.circular(8.0),
                        ),
                      ),
                focusedBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: MyTheme.medium_grey, width: 0.5),
                  borderRadius: const BorderRadius.only(
                    topLeft: const Radius.circular(8.0),
                    bottomLeft: const Radius.circular(8.0),
                  ),
                ),
                contentPadding: EdgeInsets.only(left: 16.0)),
          ),
        ),
        !_coupon_applied!
            ? Container(
                width: (MediaQuery.of(context).size.width - 32) * (1 / 3),
                height: 42,
                child: Btn.basic(
                  minWidth: MediaQuery.of(context).size.width,
                  color: MyTheme.accent_color,
                  shape: app_language_rtl.$!
                      ? RoundedRectangleBorder(
                          borderRadius: const BorderRadius.only(
                          topLeft: const Radius.circular(8.0),
                          bottomLeft: const Radius.circular(8.0),
                        ))
                      : RoundedRectangleBorder(
                          borderRadius: const BorderRadius.only(
                          topRight: const Radius.circular(8.0),
                          bottomRight: const Radius.circular(8.0),
                        )),
                  child: Text(
                    AppLocalizations.of(context)!.apply_coupon_all_capital,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                  ),
                  onPressed: () {
                    onCouponApply();
                  },
                ),
              )
            : Container(
                width: (MediaQuery.of(context).size.width - 32) * (1 / 3),
                height: 42,
                child: Btn.basic(
                  minWidth: MediaQuery.of(context).size.width,
                  color: MyTheme.accent_color,
                  shape: RoundedRectangleBorder(
                      borderRadius: const BorderRadius.only(
                    topRight: const Radius.circular(8.0),
                    bottomRight: const Radius.circular(8.0),
                  )),
                  child: Text(
                    AppLocalizations.of(context)!.remove_ucf,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                  ),
                  onPressed: () {
                    onCouponRemove();
                  },
                ),
              )
      ],
    );
  }

  buildCartSellerItemCard(seller_index, item_index) {
    return FutureBuilder(
      future: fetchProductDetails(widget.cartList[seller_index].productId),
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
                                    widget.cartList[seller_index].product
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
                          onPressDelete(widget.cartList[seller_index].id);
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
                          widget.cartList[seller_index].quantity.toString(),
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

  Widget buildAddOrEditAddress(BuildContext context) {
    return Container(
      height: 40,
      //add a box decoration to the container with a border of red
      decoration: BoxDecoration(
        border: Border.all(color: Colors.red),
      ),
      child: Center(
        child: InkWell(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return Address(
                from_shipping_info: true,
              );
            })).then((value) {
              onPopped(value);
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Add New Address",
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: MyTheme.accent_color),
            ),
          ),
        ),
      ),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      centerTitle: true,
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(CupertinoIcons.arrow_left, color: MyTheme.dark_grey),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      title: Text(
        "${LangText(context).local!.shipping_cost_ucf}",
        style: TextStyle(fontSize: 16, color: MyTheme.accent_color),
      ),
      elevation: 0.0,
      titleSpacing: 0,
    );
  }

  buildShippingInfoList() {
    if (!_faceData && _shippingAddressList.length == 0) {
      return SingleChildScrollView(
          child: ShimmerHelper()
              .buildListShimmer(item_count: 5, item_height: 100.0));
    } else if (_shippingAddressList.length > 0) {
      return SingleChildScrollView(
        child: ListView.builder(
          itemCount: _shippingAddressList.length,
          scrollDirection: Axis.vertical,
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: buildShippingInfoItemCard(index),
            );
          },
        ),
      );
    } else if (_faceData && _shippingAddressList.length == 0) {
      return Container(
          height: 100,
          child: Center(
              child: Text(
            LangText(context).local!.no_address_is_added,
            style: TextStyle(color: MyTheme.font_grey),
          )));
    }
  }

  GestureDetector buildShippingInfoItemCard(index) {
    return GestureDetector(
      onTap: () {
        if (_seleted_shipping_address != _shippingAddressList[index].id) {
          _seleted_shipping_address = _shippingAddressList[index].id;

          // onAddressSwitch();
        }
        //detectShippingOption();
        setState(() {});
      },
      child: Card(
        shape: RoundedRectangleBorder(
          side: _seleted_shipping_address == _shippingAddressList[index].id
              ? BorderSide(color: MyTheme.accent_color, width: 2.0)
              : BorderSide(color: MyTheme.light_grey, width: 1.0),
          borderRadius: BorderRadius.circular(8.0),
        ),
        elevation: 0.0,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: buildShippingInfoItemChildren(index),
        ),
      ),
    );
  }

  Column buildShippingInfoItemChildren(index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildShippingInfoItemAddress(index),
        buildShippingInfoItemCity(index),
        buildShippingInfoItemState(index),
        buildShippingInfoItemCountry(index),
        buildShippingInfoItemPostalCode(index),
        buildShippingInfoItemPhone(index),
      ],
    );
  }

  Padding buildShippingInfoItemPhone(index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 75,
            child: Text(
              LangText(context).local!.phone_ucf,
              style: TextStyle(
                color: MyTheme.grey_153,
              ),
            ),
          ),
          Container(
            width: 200,
            child: Text(
              _shippingAddressList[index].phone,
              maxLines: 2,
              style: TextStyle(
                  color: MyTheme.dark_grey, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Padding buildShippingInfoItemPostalCode(index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 75,
            child: Text(
              LangText(context).local!.postal_code,
              style: TextStyle(
                color: MyTheme.grey_153,
              ),
            ),
          ),
          Container(
            width: 200,
            child: Text(
              _shippingAddressList[index].postal_code,
              maxLines: 2,
              style: TextStyle(
                  color: MyTheme.dark_grey, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Padding buildShippingInfoItemCountry(index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 75,
            child: Text(
              LangText(context).local!.country_ucf,
              style: TextStyle(
                color: MyTheme.grey_153,
              ),
            ),
          ),
          Container(
            width: 200,
            child: Text(
              _shippingAddressList[index].country_name,
              maxLines: 2,
              style: TextStyle(
                  color: MyTheme.dark_grey, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Padding buildShippingInfoItemState(index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 75,
            child: Text(
              LangText(context).local!.state_ucf,
              style: TextStyle(
                color: MyTheme.grey_153,
              ),
            ),
          ),
          Container(
            width: 200,
            child: Text(
              _shippingAddressList[index].state_name,
              maxLines: 2,
              style: TextStyle(
                  color: MyTheme.dark_grey, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Padding buildShippingInfoItemCity(index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 75,
            child: Text(
              LangText(context).local!.city_ucf,
              style: TextStyle(
                color: MyTheme.grey_153,
              ),
            ),
          ),
          Container(
            width: 200,
            child: Text(
              _shippingAddressList[index].city_name,
              maxLines: 2,
              style: TextStyle(
                  color: MyTheme.dark_grey, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Padding buildShippingInfoItemAddress(index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 75,
            child: Text(
              LangText(context).local!.address_ucf,
              style: TextStyle(
                color: MyTheme.grey_153,
              ),
            ),
          ),
          Container(
            width: 175,
            child: Text(
              _shippingAddressList[index].address,
              maxLines: 2,
              style: TextStyle(
                  color: MyTheme.dark_grey, fontWeight: FontWeight.w600),
            ),
          ),
          Spacer(),
          buildShippingOptionsCheckContainer(
              _seleted_shipping_address == _shippingAddressList[index].id)
        ],
      ),
    );
  }

  Container buildShippingOptionsCheckContainer(bool check) {
    return check
        ? Container(
            height: 16,
            width: 16,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0), color: Colors.green),
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: Icon(Icons.check, color: Colors.white, size: 10),
            ),
          )
        : Container();
  }

  BottomAppBar buildBottomAppBar(BuildContext context) {
    return BottomAppBar(
      child: Container(
        color: Colors.transparent,
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              height: 50,
              child: Center(
                child: Text(
                  "GH₵ $_cartTotalString",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
              )
            ),
            Btn.minWidthFixHeight(
              minWidth: MediaQuery.of(context).size.width /2 ,
              height: 50,
              color: MyTheme.accent_color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0.0),
              ),
              child: Text(
                "GO TO PAYMENT",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
              onPressed: () {
                onPressProceed(context);
              },
            )
          ],
        ),
      ),
    );
  }

  Widget customAppBar(BuildContext context) {
    return Container(
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: MyTheme.white,
              child: Row(
                children: [
                  buildAppbarBackArrow(),
                ],
              ),
            ),
            // container for gaping into title text and title-bottom buttons
            Container(
              padding: EdgeInsets.only(top: 2),
              width: mWidth,
              color: MyTheme.light_grey,
              height: 1,
            ),
            //buildChooseShippingOption(context)
          ],
        ),
      ),
    );
  }

  Container buildAppbarTitle(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width - 40,
      child: Text(
        "${LangText(context).local!.shipping_info}",
        style: TextStyle(
          fontSize: 16,
          color: MyTheme.dark_font_grey,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Container buildAppbarBackArrow() {
    return Container(
      width: 40,
      child: UsefulElements.backButton(context),
    );
  }

/*
  Widget buildChooseShippingOption(BuildContext context) {
    // if(carrier_base_shipping.$){
    if (true) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 14),
        width: DeviceInfo(context).width,
        alignment: Alignment.center,
        child: Text(
          "Choose Shipping Area",
          style: TextStyle(
              color: MyTheme.dark_grey,
              fontSize: 14,
              fontWeight: FontWeight.w700),
        ),
      );
    }
    return Visibility(
      visible: pick_up_status.$,
      child: ScrollToHideWidget(
        child: Container(
          color: MyTheme.white,
          //MyTheme.light_grey,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              buildAddresOption(context),
              Container(
                width: 0.5,
                height: 30,
                color: MyTheme.grey_153,
              ),
              buildPockUpPointOption(context),
            ],
          ),
        ),
        scrollController: _mainScrollController,
        childHeight: 40,
      ),
    );
  }*/
/*
  FlatButton buildPockUpPointOption(BuildContext context) {
    return FlatButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        setState(() {
          changeShippingOption(false);
        });
      },
      child: Container(
        color: MyTheme.white,
        alignment: Alignment.center,
        height: 50,
        width: (mWidth / 2) - 1,
        child: Text(
          LangText(context).local.pickup_point,
          style: TextStyle(
              color: _shippingOptionIsAddress
                  ? MyTheme.medium_grey_50
                  : MyTheme.dark_grey,
              fontWeight: !_shippingOptionIsAddress
                  ? FontWeight.w700
                  : FontWeight.normal),
        ),
      ),
    );
  }


  FlatButton buildAddresOption(BuildContext context) {
    return FlatButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        setState(() {
          changeShippingOption(true);
        });
      },
      child: Container(
        color: MyTheme.white,
        height: 50,
        width: (mWidth / 2) - 1,
        alignment: Alignment.center,
        child: Text(
          LangText(context).local.address_screen_address,
          style: TextStyle(
              color: _shippingOptionIsAddress
                  ? MyTheme.dark_grey
                  : MyTheme.medium_grey_50,
              fontWeight: _shippingOptionIsAddress
                  ? FontWeight.w700
                  : FontWeight.normal),
        ),
      ),
    );
  }
  */
}
