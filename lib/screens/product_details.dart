import 'dart:async';
import 'dart:math';

import 'package:active_ecommerce_flutter/app_config.dart';
import 'package:active_ecommerce_flutter/custom/box_decorations.dart';
import 'package:active_ecommerce_flutter/custom/btn.dart';
import 'package:active_ecommerce_flutter/custom/device_info.dart';
import 'package:active_ecommerce_flutter/custom/quantity_input.dart';
import 'package:active_ecommerce_flutter/custom/text_styles.dart';
import 'package:active_ecommerce_flutter/custom/toast_component.dart';
import 'package:active_ecommerce_flutter/data_model/products_model.dart';
import 'package:active_ecommerce_flutter/helpers/color_helper.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_flutter/helpers/shimmer_helper.dart';
import 'package:active_ecommerce_flutter/helpers/system_config.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:active_ecommerce_flutter/presenter/cart_counter.dart';
import 'package:active_ecommerce_flutter/repositories/chat_repository.dart';
import 'package:active_ecommerce_flutter/repositories/product_repository.dart';
import 'package:active_ecommerce_flutter/repositories/review_repositories.dart';
import 'package:active_ecommerce_flutter/repositories/wishlist_repository.dart';
import 'package:active_ecommerce_flutter/screens/cart.dart';
import 'package:active_ecommerce_flutter/screens/chat.dart';
import 'package:active_ecommerce_flutter/screens/product_reviews.dart';
import 'package:active_ecommerce_flutter/screens/product_variants.dart';
import 'package:active_ecommerce_flutter/screens/seller_details.dart';
import 'package:active_ecommerce_flutter/ui_elements/list_product_card.dart';
import 'package:active_ecommerce_flutter/ui_elements/mini_product_card.dart';
import 'package:active_ecommerce_flutter/ui_elements/product_card.dart';
import 'package:badges/badges.dart' as badges;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:social_share/social_share.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../data_model/product_detail.dart';
import '../data_model/vendor_response.dart';

class ProductDetails extends StatefulWidget {
  String slug;

  ProductDetails({Key? key, required this.slug}) : super(key: key);

  @override
  _ProductDetailsState createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails>
    with TickerProviderStateMixin {
  bool _showCopied = false;
  String? _appbarPriceString = ". . .";
  int _currentImage = 0;
  ScrollController _mainScrollController =
      ScrollController(initialScrollOffset: 0.0);
  ScrollController _colorScrollController = ScrollController();
  ScrollController _variantScrollController = ScrollController();
  ScrollController _imageScrollController = ScrollController();
  TextEditingController sellerChatTitleController = TextEditingController();
  TextEditingController sellerChatMessageController = TextEditingController();

  double _scrollPosition = 0.0;

  Animation? _colorTween;
  late AnimationController _ColorAnimationController;
  WebViewController controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..enableZoom(false);
  double webViewHeight = 350.0;

  CarouselController _carouselController = CarouselController();
  late BuildContext loadingcontext;

  //init values

  bool _isInWishList = false;
  ProductMiniDetail? _productDetails;
  VendorDetails? _vendorDetails;
  var _productImageList = [];
  var _colorList = [];
  int _selectedColorIndex = 0;
  var _selectedChoices = [];
  var _choiceString = "";
  String? _totalPrice = "...";
  var _singlePriceString;
  int? _quantity = 1;
  int? _stock = 0;
  List<dynamic> _reviewList = [];
  bool _isInitial = true;
  int _page = 1;
  int? _totalData = 0;
  double _my_rating_temp = 0.0;
  double opacity = 0;

  List<dynamic> _relatedProducts = [];
  bool _relatedProductInit = false;
  List<dynamic> _topProducts = [];
  bool _topProductInit = false;

  @override
  void initState() {
    quantityText.text = "${_quantity ?? 0}";
    controller;
    _ColorAnimationController =
        AnimationController(vsync: this, duration: Duration(seconds: 0));

    _colorTween = ColorTween(begin: Colors.transparent, end: Colors.white)
        .animate(_ColorAnimationController);

    _mainScrollController.addListener(() {
      _scrollPosition = _mainScrollController.position.pixels;

      if (_mainScrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (100 > _scrollPosition && _scrollPosition > 1) {
          opacity = _scrollPosition / 100;
        }
      }

      if (_mainScrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (100 > _scrollPosition && _scrollPosition > 1) {
          opacity = _scrollPosition / 100;

          if (100 > _scrollPosition) {
            opacity = 1;
          }
        }
      }
      //print("opachity{} $_scrollPosition");

      setState(() {});
    });
    fetchAll();
    fetchData();
    super.initState();
  }

  @override
  void dispose() {
    _mainScrollController.dispose();
    _variantScrollController.dispose();
    _imageScrollController.dispose();
    _colorScrollController.dispose();
    _ColorAnimationController.dispose();
    super.dispose();
  }

  fetchAll() {
    fetchProductDetails();
    if (is_logged_in.$ == true) {
      fetchWishListCheckInfo();
    }
    // fetchRelatedProducts();
    fetchTopProducts();
  }

  fetchData() async {
    var reviewResponse = await ReviewRepository().getReviewResponse(
      widget.slug,
      page: 1,
    );
    _reviewList.addAll(reviewResponse.reviews);
    //user fold method to count all rating in the
    //review list and then divide by the length of the list
    //to get the average rating

    if (_reviewList.length > 0) {
      double totalRating = 0.0;
      for (var review in _reviewList) {
        totalRating += review.rating;
      }
      _my_rating_temp = totalRating / _reviewList.length;
    }
    _isInitial = false;
    _totalData = _reviewList.length;
    setState(() {});
  }

  //get vendor details
  Future<VendorDetails?> fetchVendorDetails(String id) async {
    var vendorDetailsResponse =
        await ProductRepository().getVendorDetails(id: id);
    _vendorDetails = vendorDetailsResponse;
    return _vendorDetails;
  }

  // fetchVariantPrice() async {
  //   var response = await ProductRepository()
  //       .getVariantPrice(id: widget.slug, quantity: _quantity);
  //
  //   print(response);
  //   _totalPrice = response.data.price;
  //   setState(() {});
  // }

  fetchProductDetails() async {
    var productDetailsResponse =
        await ProductRepository().getProductDetails(slug: widget.slug);

    // if (productDetailsResponse.products!.productDetail!.description != null) {
    _productDetails = productDetailsResponse;
    sellerChatTitleController.text = "";
    // }

    fetchVendorDetails(_productDetails!.products!.userId.toString());

    setProductDetailValues();

    setState(() {});
  }

  // fetchRelatedProducts() async {
  //   var relatedProductResponse = await ProductRepository()
  //       .getRelatedProducts(slug: _productDetails!.products!.categoryId!);
  //   _relatedProducts.addAll(relatedProductResponse.products!);
  //   _relatedProductInit = true;

  //   setState(() {});
  // }

  fetchTopProducts() async {
    var topProductResponse = await ProductRepository().getFilteredProducts();

    // Get the number of products to add
    int numProductsToAdd = min(10, topProductResponse.products!.length);

    // Add only the first numProductsToAdd products to _topProducts
    _topProducts.addAll(topProductResponse.products!.take(numProductsToAdd));

    _topProductInit = true;
  }

  setProductDetailValues() {
    if (_productDetails != null) {
      controller.loadHtmlString(
          makeHtml(_productDetails!.productDetails![0].description!));
      _appbarPriceString = _productDetails!.products!.price;
      _singlePriceString = _productDetails!.products!.price;
      // fetchVariantPrice();
      _stock = int.tryParse(_productDetails!.products!.stock!);
      _productDetails!.image!.forEach((photo) {
        _productImageList.add("https://seller.impexally.com/uploads/images/" +
            photo.imageDefault!);
      });

      // _productDetails!.choice_options!.forEach((choice_opiton) {
      _selectedChoices.add("");
      // });
      // _productDetails!.colors!.forEach((color) {
      _colorList.add("#ffffff");
      _colorList.add("#ff3447");
      _colorList.add("#0f3447");
      // });

      setChoiceString();

      // if (_productDetails!.colors.length > 0 ||
      //     _productDetails!.choice_options.length > 0) {
      //   fetchAndSetVariantWiseInfo(change_appbar_string: true);
      // }
      fetchAndSetVariantWiseInfo(change_appbar_string: true);

      setState(() {});
    }
  }

  setChoiceString() {
    _choiceString = _selectedChoices.join(",").toString();
    print(_choiceString);
    setState(() {});
  }

  fetchWishListCheckInfo() async {
    var wishListCheckResponse =
        await WishListRepository().isProductInUserWishList(
      product_id: widget.slug,
    );

    //print("p&u:" + widget.slug.toString() + " | " + _user_id.toString());
    _isInWishList = wishListCheckResponse.is_in_wishlist;
    setState(() {});
  }

  addToWishList() async {
    var wishListCheckResponse =
        await WishListRepository().add(product_id: widget.slug);

    //print("p&u:" + widget.slug.toString() + " | " + _user_id.toString());
    _isInWishList = wishListCheckResponse.is_in_wishlist;
    setState(() {});
  }

  removeFromWishList() async {
    var wishListCheckResponse =
        await WishListRepository().remove(product_id: widget.slug);

    //print("p&u:" + widget.slug.toString() + " | " + _user_id.toString());
    _isInWishList = wishListCheckResponse.is_in_wishlist;
    setState(() {});
  }

  onWishTap() {
    if (is_logged_in.$ == false) {
      ToastComponent.showDialog(
          AppLocalizations.of(context)!.you_need_to_log_in,
          gravity: Toast.center,
          duration: Toast.lengthLong);
      return;
    }

    if (_isInWishList!) {
      _isInWishList = false;
      setState(() {});
      removeFromWishList();
    } else {
      _isInWishList = true;
      setState(() {});
      addToWishList();
    }
  }

  setQuantity(quantity) {
    quantityText.text = "${quantity ?? 0}";
  }

  fetchAndSetVariantWiseInfo({bool change_appbar_string = true}) async {
    var color_string = _colorList.length > 0
        ? _colorList[_selectedColorIndex].toString().replaceAll("#", "")
        : "";

    /*print("color string: "+color_string);
    return;*/

    var variantResponse = await ProductRepository().getVariantWiseInfo(
        slug: widget.slug,
        color: color_string,
        variants: _choiceString,
        qty: _quantity);
    // print("single price ${variantResponse.variantData!.price}");
    /*print("vr"+variantResponse.toJson().toString());
    return;*/

    // _singlePrice = variantResponse.price;
    _stock = 10;
    if (_quantity! > _stock!) {
      _quantity = _stock;
    }

    //fetchVariantPrice();
    // _singlePriceString = variantResponse.price_string;
    _totalPrice = "";

    // if (change_appbar_string) {
    //   _appbarPriceString = "${variantResponse.variant} ${_singlePriceString}";
    // }

    int pindex = 0;
    _productDetails!.image?.forEach((photo) {
      //print('con:'+ (photo.variant == _variant && variantResponse.image != "").toString());
      if (photo.imageSmall != "") {
        _currentImage = pindex;
        _carouselController.jumpToPage(pindex);
      }
      pindex++;
    });
    setQuantity(_quantity);
    setState(() {});
  }

  reset() {
    restProductDetailValues();
    _currentImage = 0;
    _productImageList.clear();
    _colorList.clear();
    _selectedChoices.clear();
    _relatedProducts.clear();
    _topProducts.clear();
    _choiceString = "";
    _selectedColorIndex = 0;
    _quantity = 1;
    _isInWishList = false;
    sellerChatTitleController.clear();
    setState(() {});
  }

  restProductDetailValues() {
    _appbarPriceString = " . . .";
    _productDetails = null;
    _productImageList.clear();
    _currentImage = 0;
    setState(() {});
  }

  Future<void> _onPageRefresh() async {
    reset();
    fetchAll();
  }

  // calculateTotalPrice() {
  //   print("sing $_singlePrice");
  //
  //   _totalPrice = (_singlePrice * _quantity).toStringAsFixed(2);
  //   setState(() {});
  // }

  _onVariantChange(_choice_options_index, value) {
    _selectedChoices[_choice_options_index] = value;
    setChoiceString();
    setState(() {});
    fetchAndSetVariantWiseInfo();
  }

  _onColorChange(index) {
    _selectedColorIndex = index;
    setState(() {});
    fetchAndSetVariantWiseInfo();
  }

  onPressAddToCart(context, snackbar) {
    addToCart(mode: "add_to_cart", context: context, snackbar: snackbar);
  }

  onPressBuyNow(context, ProductMiniDetail? variation) {
    addToCart(mode: "buy_now", context: context, variation: variation);
  }

  addToCart(
      {mode,
      BuildContext? context,
      snackbar = null,
      ProductMiniDetail? variation}) async {
    Navigator.push(context!, MaterialPageRoute(builder: (context) {
      return ProductVariants(has_bottomnav: false, variation: variation);
    })).then((value) {
      onPopped(value);
    });
  }

  onPopped(value) async {
    reset();
    fetchAll();
  }

  onCopyTap(setState) {
    setState(() {
      _showCopied = true;
    });
    Timer timer = Timer(Duration(seconds: 3), () {
      setState(() {
        _showCopied = false;
      });
    });
  }

  createDynamicLink(String productId) async {
    SocialShare.shareOptions(
        'Check out this product: https://ghana.impexally.com/product/$productId');
  }

  onPressShare(context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, StateSetter setState) {
            return AlertDialog(
              insetPadding: EdgeInsets.symmetric(horizontal: 10),
              contentPadding: EdgeInsets.only(
                  top: 36.0, left: 36.0, right: 36.0, bottom: 2.0),
              content: Container(
                width: 400,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Btn.minWidthFixHeight(
                          minWidth: 75,
                          height: 26,
                          color: Color.fromRGBO(253, 253, 253, 1),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              side:
                                  BorderSide(color: Colors.black, width: 1.0)),
                          child: Text(
                            AppLocalizations.of(context)!.copy_product_link_ucf,
                            style: TextStyle(
                              color: MyTheme.medium_grey,
                            ),
                          ),
                          onPressed: () {
                            onCopyTap(setState);
                            Clipboard.setData(ClipboardData(text: ""));
                            createDynamicLink(widget.slug);

                            // SocialShare.copyToClipboard(
                            //     text: _productDetails!.link, image: "");
                          },
                        ),
                      ),
                      _showCopied
                          ? Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                AppLocalizations.of(context)!.copied_ucf,
                                style: TextStyle(
                                    color: MyTheme.medium_grey, fontSize: 12),
                              ),
                            )
                          : Container(),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Btn.minWidthFixHeight(
                          minWidth: 75,
                          height: 26,
                          color: Colors.blue,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              side:
                                  BorderSide(color: Colors.black, width: 1.0)),
                          child: Text(
                            AppLocalizations.of(context)!.share_options_ucf,
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            createDynamicLink(widget.slug);
                            SocialShare.shareOptions(
                                _productDetails!.products!.slug!);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Padding(
                      padding: app_language_rtl.$!
                          ? EdgeInsets.only(left: 8.0)
                          : EdgeInsets.only(right: 8.0),
                      child: Btn.minWidthFixHeight(
                        minWidth: 75,
                        height: 30,
                        color: Color.fromRGBO(253, 253, 253, 1),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            side: BorderSide(
                                color: MyTheme.font_grey, width: 1.0)),
                        child: Text(
                          "CLOSE",
                          style: TextStyle(
                            color: MyTheme.font_grey,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context, rootNavigator: true).pop();
                        },
                      ),
                    ),
                  ],
                )
              ],
            );
          });
        });
  }

  onTapSellerChat() {
    return showDialog(
        context: context,
        builder: (_) => Directionality(
              textDirection:
                  app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
              child: AlertDialog(
                insetPadding: EdgeInsets.symmetric(horizontal: 10),
                contentPadding: EdgeInsets.only(
                    top: 36.0, left: 36.0, right: 36.0, bottom: 2.0),
                content: Container(
                  width: 400,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(AppLocalizations.of(context)!.title_ucf,
                              style: TextStyle(
                                  color: MyTheme.font_grey, fontSize: 12)),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Container(
                            height: 40,
                            child: TextField(
                              controller: sellerChatTitleController,
                              autofocus: false,
                              decoration: InputDecoration(
                                  hintText: AppLocalizations.of(context)!
                                      .enter_title_ucf,
                                  hintStyle: TextStyle(
                                      fontSize: 12.0,
                                      color: MyTheme.textfield_grey),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: MyTheme.textfield_grey,
                                        width: 0.5),
                                    borderRadius: const BorderRadius.all(
                                      const Radius.circular(8.0),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: MyTheme.textfield_grey,
                                        width: 1.0),
                                    borderRadius: const BorderRadius.all(
                                      const Radius.circular(8.0),
                                    ),
                                  ),
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 8.0)),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                              "${AppLocalizations.of(context)!.message_ucf} *",
                              style: TextStyle(
                                  color: MyTheme.font_grey, fontSize: 12)),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Container(
                            height: 55,
                            child: TextField(
                              controller: sellerChatMessageController,
                              autofocus: false,
                              maxLines: null,
                              keyboardType: TextInputType.multiline,
                              decoration: InputDecoration(
                                  hintText: AppLocalizations.of(context)!
                                      .enter_message_ucf,
                                  hintStyle: TextStyle(
                                      fontSize: 12.0,
                                      color: MyTheme.textfield_grey),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: MyTheme.textfield_grey,
                                        width: 0.5),
                                    borderRadius: const BorderRadius.all(
                                      const Radius.circular(8.0),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: MyTheme.textfield_grey,
                                        width: 1.0),
                                    borderRadius: const BorderRadius.all(
                                      const Radius.circular(8.0),
                                    ),
                                  ),
                                  contentPadding: EdgeInsets.only(
                                      right: 16.0,
                                      left: 8.0,
                                      top: 16.0,
                                      bottom: 16.0)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Btn.minWidthFixHeight(
                          minWidth: 75,
                          height: 30,
                          color: Color.fromRGBO(253, 253, 253, 1),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              side: BorderSide(
                                  color: MyTheme.light_grey, width: 1.0)),
                          child: Text(
                            AppLocalizations.of(context)!.close_all_capital,
                            style: TextStyle(
                              color: MyTheme.font_grey,
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context, rootNavigator: true).pop();
                          },
                        ),
                      ),
                      SizedBox(
                        width: 1,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28.0),
                        child: Btn.minWidthFixHeight(
                          minWidth: 75,
                          height: 30,
                          color: MyTheme.accent_color,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              side: BorderSide(
                                  color: MyTheme.light_grey, width: 1.0)),
                          child: Text(
                            AppLocalizations.of(context)!.send_all_capital,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600),
                          ),
                          onPressed: () {
                            Navigator.of(context, rootNavigator: true).pop();
                            onPressSendMessage();
                          },
                        ),
                      )
                    ],
                  )
                ],
              ),
            ));
  }

  loading() {
    showDialog(
        context: context,
        builder: (context) {
          loadingcontext = context;
          return AlertDialog(
              content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(
                width: 10,
              ),
              Text("${AppLocalizations.of(context)!.please_wait_ucf}"),
            ],
          ));
        });
  }

  showLoginWarning() {
    return ToastComponent.showDialog(
        AppLocalizations.of(context)!.you_need_to_log_in,
        gravity: Toast.center,
        duration: Toast.lengthLong);
  }

  onPressSendMessage() async {
    if (!is_logged_in.$) {
      showLoginWarning();
      return;
    }
    loading();
    var title = sellerChatTitleController.text.toString();
    var message = sellerChatMessageController.text.toString();

    if (title == "" || message == "") {
      ToastComponent.showDialog(
          AppLocalizations.of(context)!.title_or_message_empty_warning,
          gravity: Toast.center,
          duration: Toast.lengthLong);
      return;
    }

    var conversationCreateResponse = await ChatRepository()
        .getCreateConversationResponse(
            product_id: widget.slug, title: title, message: message);

    Navigator.of(loadingcontext).pop();

    if (conversationCreateResponse.result == false) {
      ToastComponent.showDialog(
          AppLocalizations.of(context)!.could_not_create_conversation,
          gravity: Toast.center,
          duration: Toast.lengthLong);
      return;
    }

    sellerChatTitleController.clear();
    sellerChatMessageController.clear();
    setState(() {});

    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return Chat(
        conversation_id: conversationCreateResponse.conversation_id,
        messenger_name: conversationCreateResponse.shop_name,
        messenger_title: conversationCreateResponse.title,
        messenger_image: conversationCreateResponse.shop_logo,
      );
      ;
    })).then((value) {
      onPopped(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
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
          extendBody: true,
          bottomNavigationBar: buildBottomAppBar(context, _addedToCartSnackbar),
          //appBar: buildAppBar(statusBarHeight, context),
          body: RefreshIndicator(
            color: MyTheme.accent_color,
            backgroundColor: Colors.white,
            onRefresh: _onPageRefresh,
            child: CustomScrollView(
              controller: _mainScrollController,
              physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              slivers: <Widget>[
                SliverAppBar(
                  elevation: 0,
                  backgroundColor: Colors.white.withOpacity(opacity),
                  pinned: true,
                  automaticallyImplyLeading: false,
                  //titleSpacing: 0,
                  title: Row(
                    children: [
                      Builder(
                        builder: (context) => InkWell(
                          onTap: () {
                            return Navigator.of(context).pop();
                          },
                          child: Container(
                            decoration: BoxDecorations
                                .buildCircularButtonDecoration_1(),
                            width: 36,
                            height: 36,
                            child: Center(
                              child: Icon(
                                CupertinoIcons.arrow_left,
                                color: MyTheme.dark_font_grey,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),

                      //Show product name in appbar
                      AnimatedOpacity(
                          opacity: _scrollPosition > 350 ? 1 : 0,
                          duration: Duration(milliseconds: 200),
                          child: Container(
                              padding: EdgeInsets.only(left: 8),
                              width: DeviceInfo(context).width! / 3,
                              child: Text(
                                "${_productDetails != null ? _productDetails!.productDetails![0].title : ''}",
                                style: TextStyle(
                                    color: MyTheme.dark_font_grey,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold),
                              ))),
                      Spacer(),
                      InkWell(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return Cart(has_bottomnav: false);
                          })).then((value) {
                            onPopped(value);
                          });
                        },
                        child: Container(
                          decoration:
                              BoxDecorations.buildCircularButtonDecoration_1(),
                          width: 36,
                          height: 36,
                          padding: EdgeInsets.all(8),
                          child: badges.Badge(
                            badgeStyle: badges.BadgeStyle(
                              shape: badges.BadgeShape.circle,
                              badgeColor: MyTheme.accent_color,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            badgeAnimation: badges.BadgeAnimation.slide(
                              toAnimate: true,
                            ),
                            stackFit: StackFit.loose,
                            child: Image.asset(
                              "assets/cart.png",
                              color: MyTheme.dark_font_grey,
                              height: 16,
                            ),
                            badgeContent: Consumer<CartCounter>(
                              builder: (context, cart, child) {
                                return Text(
                                  "${cart.cartCounter}",
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.white),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 15),
                      InkWell(
                        onTap: () {
                          createDynamicLink(widget.slug);
                        },
                        child: Container(
                          decoration:
                              BoxDecorations.buildCircularButtonDecoration_1(),
                          width: 36,
                          height: 36,
                          child: Center(
                            child: Icon(
                              Icons.share_outlined,
                              color: MyTheme.dark_font_grey,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 15),
                      InkWell(
                        onTap: () {
                          onWishTap();
                        },
                        child: Container(
                          decoration:
                              BoxDecorations.buildCircularButtonDecoration_1(),
                          width: 36,
                          height: 36,
                          child: Center(
                            child: Icon(
                              Icons.favorite,
                              color: _isInWishList
                                  ? Color.fromRGBO(230, 46, 4, 1)
                                  : MyTheme.dark_font_grey,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  expandedHeight: 375.0,
                  flexibleSpace: FlexibleSpaceBar(
                    background: buildProductSliderImageSection(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    //padding: EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecorations.buildBoxDecoration_1(),
                    margin: EdgeInsets.symmetric(horizontal: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildProductImageSection(),
                        Padding(
                          padding:
                              EdgeInsets.only(top: 14, left: 14, right: 14),
                          child: _productDetails != null
                              ? Text(
                                  _productDetails!.productDetails![0].title!,
                                  style: TextStyles.smallTitleTexStyle(),
                                  maxLines: 2,
                                )
                              : ShimmerHelper().buildBasicShimmer(
                                  height: 30.0,
                                ),
                        ),
                        Visibility(
                          visible: true,
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: 14.0, right: 14.0, top: 14),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Purchase Qty. / FOB Price",
                                  style: TextStyle(
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w200,
                                    color: MyTheme.font_grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (_productDetails != null &&
                            _productDetails!.products!.rating != null)
                          Padding(
                            padding:
                                EdgeInsets.only(top: 8, left: 14, right: 14),
                            child: _productDetails != null
                                ? buildMainPriceRow()
                                : ShimmerHelper().buildBasicShimmer(
                                    height: 20.0,
                                  ),
                          ),
                        Padding(
                          padding: EdgeInsets.only(top: 2, left: 14, right: 14),
                          child: _productDetails != null
                              ? Text(
                                  "In Stock: ${_productDetails!.products!.stock} Pieces/Units Available",
                                  style: TextStyle(
                                      color: MyTheme.font_grey,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600),
                                )
                              : ShimmerHelper().buildBasicShimmer(
                                  height: 20.0,
                                ),
                        ),
                        Visibility(
                          visible: club_point_addon_installed.$,
                          child: Padding(
                            padding:
                                EdgeInsets.only(top: 14, left: 14, right: 14),
                            child: _productDetails != null
                                ? buildClubPointRow()
                                : ShimmerHelper().buildBasicShimmer(
                                    height: 30.0,
                                  ),
                          ),
                        ),
                        Padding(
                          padding:
                              EdgeInsets.only(top: 14, left: 14, right: 14),
                          child: _productDetails != null
                              ? buildBrandRow()
                              : ShimmerHelper().buildBasicShimmer(
                                  height: 50.0,
                                ),
                        ),
                        Container(
                          color: MyTheme.light_grey,
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        ),
                        Visibility(
                          visible: true,
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: 14.0, right: 14.0, top: 14),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Reviews" + " (${_totalData.toString()})",
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ProductReviews(
                                                      id: widget.slug))),
                                      child: Text(
                                        "View All",
                                        style: TextStyle(
                                          fontSize: 13.0,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 5.0),
                                    Icon(Icons.arrow_forward_ios,
                                        size: 13.0, color: MyTheme.font_grey),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding:
                              EdgeInsets.only(top: 14, left: 14, right: 14),
                          child: _productDetails != null
                              ? buildRatingAndWishButtonRow()
                              : ShimmerHelper().buildBasicShimmer(
                                  height: 30.0,
                                ),
                        ),
                        Divider(
                          color: MyTheme.light_grey,
                          thickness: 1,
                          indent: 20,
                          endIndent: 20,
                          height: 15,
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 4, left: 14, right: 14),
                          child: _productDetails != null
                              ? buildShippingTime()
                              : ShimmerHelper().buildBasicShimmer(
                                  height: 20.0,
                                ),
                        ),
                        Container(
                          color: MyTheme.light_grey,
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        ),
                        Padding(
                          padding:
                              EdgeInsets.only(top: 34, left: 14, right: 14),
                          child: _productDetails != null
                              ? buildFullfilment()
                              : ShimmerHelper().buildBasicShimmer(
                                  height: 30.0,
                                ),
                        ),
                        Container(
                          color: MyTheme.light_grey,
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        ),
                        Padding(
                          padding:
                              EdgeInsets.only(top: 14, left: 14, right: 14),
                          child: _productDetails != null
                              ? (_colorList.length > 0
                                  ? buileQuickView(context)
                                  : Container())
                              : ShimmerHelper().buildBasicShimmer(
                                  height: 30.0,
                                ),
                        ),
                        Container(
                          color: MyTheme.light_grey,
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 14),
                          child: _productDetails != null
                              ? buildSellerRow(context)
                              : ShimmerHelper().buildBasicShimmer(
                                  height: 50.0,
                                ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 14, bottom: 14),
                          child: _productDetails != null
                              ? Container() //buildTotalPriceRow()
                              : ShimmerHelper().buildBasicShimmer(
                                  height: 30.0,
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          color: MyTheme.white,
                          margin: EdgeInsets.only(top: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16.0,
                                  20.0,
                                  16.0,
                                  10.0,
                                ),
                                child: Text(
                                  "Product Description",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16.0,
                                  0.0,
                                  8.0,
                                  8.0,
                                ),
                                child: _productDetails != null
                                    ? buildExpandableDescription()
                                    : Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0, vertical: 8.0),
                                        child:
                                            ShimmerHelper().buildBasicShimmer(
                                          height: 60.0,
                                        )),
                              ),
                            ],
                          ),
                        ),
                      ]),
                ),
                SliverList(
                  delegate: SliverChildListDelegate([
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        18.0,
                        24.0,
                        18.0,
                        0.0,
                      ),
                      child: Text(
                        "Recommended For You",
                        style: TextStyle(
                            color: MyTheme.dark_font_grey,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    (_productDetails?.products?.userId != null)
                        ? buildProductList(context)
                        : Container(),
                  ]),
                ),

                //Top selling product
                SliverList(
                  delegate: SliverChildListDelegate([
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        18.0,
                        24.0,
                        18.0,
                        0.0,
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.top_selling_products_ucf,
                        style: TextStyle(
                            color: MyTheme.dark_font_grey,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        16.0,
                        0.0,
                        16.0,
                        0.0,
                      ),
                      child: buildTopSellingProductList(),
                    ),
                    Container(
                      height: 83,
                    )
                  ]),
                )
              ],
            ),
          )),
    );
  }

  buildProductList(context) {
    return FutureBuilder(
        future: ProductRepository()
            .getFilteredProductsFromSeller(_productDetails!.products!.userId),
        builder: (context, AsyncSnapshot<ProductResponse> snapshot) {
          if (snapshot.hasError) {
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
                  return MiniProductCard(
                    id: homeData.products![index].id,
                    slug: homeData.products![index].slug!,
                    image: homeData.products![index].image!.imageDefault,
                    name: homeData.products![index].productDetail!.title!,
                    main_price: homeData.products![index].price,
                    stroked_price: homeData.products![index].priceDiscounted,
                    has_discount: true,
                    discount: homeData.products![index].priceDiscounted,
                  );
                },
              ),
            );
          } else {
            return Row(
              children: [
                Padding(
                    padding: app_language_rtl.$!
                        ? EdgeInsets.only(left: 8.0)
                        : EdgeInsets.only(right: 8.0),
                    child: ShimmerHelper().buildBasicShimmer(
                        height: 120.0,
                        width: (MediaQuery.of(context).size.width - 32) / 3)),
                Padding(
                    padding: app_language_rtl.$!
                        ? EdgeInsets.only(left: 8.0)
                        : EdgeInsets.only(right: 8.0),
                    child: ShimmerHelper().buildBasicShimmer(
                        height: 120.0,
                        width: (MediaQuery.of(context).size.width - 32) / 3)),
                Padding(
                    padding: const EdgeInsets.only(right: 0.0),
                    child: ShimmerHelper().buildBasicShimmer(
                        height: 120.0,
                        width: (MediaQuery.of(context).size.width - 32) / 3)),
              ],
            );
          }
        });
  }

  Widget buileQuickView(BuildContext ctx) {
    //create 4 rows and two columns with some data about a product
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(left: 0.0, right: 0.0, top: 1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Quick Details",
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      "View All",
                      style: TextStyle(
                        fontSize: 13.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 5.0),
                    Icon(Icons.arrow_forward_ios,
                        size: 13.0, color: MyTheme.font_grey),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "ModelNo.:",
                style: TextStyle(
                    color: MyTheme.font_grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
              ),
              SizedBox(width: 10),
              Text(
                "IMOOOOOO67",
                style: TextStyle(
                    color: MyTheme.dark_font_grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Group:",
                style: TextStyle(
                    color: MyTheme.font_grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
              ),
              SizedBox(width: 10),
              Text(
                "E-Commerce & Online Shopping",
                style: TextStyle(
                    color: MyTheme.dark_font_grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Material:",
                style: TextStyle(
                    color: MyTheme.font_grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
              ),
              SizedBox(width: 10),
              Text(
                "N/A",
                style: TextStyle(
                    color: MyTheme.dark_font_grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Type:",
                style: TextStyle(
                    color: MyTheme.font_grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
              ),
              SizedBox(width: 10),
              Text(
                "Online Shopping in Ghana",
                style: TextStyle(
                    color: MyTheme.dark_font_grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Application:",
                style: TextStyle(
                    color: MyTheme.font_grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
              ),
              SizedBox(width: 10),
              Text(
                "International",
                style: TextStyle(
                    color: MyTheme.dark_font_grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "OEM Service:",
                style: TextStyle(
                    color: MyTheme.font_grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
              ),
              SizedBox(width: 10),
              Text(
                "Yes",
                style: TextStyle(
                    color: MyTheme.dark_font_grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildSellerRow(BuildContext context) {
    //print("sl:" +  _productDetails!.shop_logo);
    return Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Column(children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SellerDetails(
                                slug: "",
                              )));
                },
                child: Padding(
                  padding: app_language_rtl.$!
                      ? EdgeInsets.only(left: 8.0)
                      : EdgeInsets.only(right: 8.0),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6.0),
                      border: Border.all(
                          color: Color.fromRGBO(112, 112, 112, .3), width: 1),
                      //shape: BoxShape.rectangle,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.0),
                      child: Image.asset(
                        'assets/placeholder.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * (.5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        _vendorDetails != null ? _vendorDetails!.username! : "",
                        style: TextStyle(
                          color: MyTheme.dark_font_grey,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        )),
                  ],
                ),
              ),
              Spacer(),
              Visibility(
                visible: true,
                child: Container(
                    padding: EdgeInsets.all(10),
                    decoration:
                        BoxDecorations.buildCircularButtonDecoration_1(),
                    child: Row(
                      children: [
                        InkWell(
                            onTap: () {
                              if (is_logged_in == false) {
                                ToastComponent.showDialog("You need to log in",
                                    gravity: Toast.center,
                                    duration: Toast.lengthLong);
                                return;
                              }

                              onTapSellerChat();
                            },
                            child: Image.asset('assets/chat.png',
                                height: 16,
                                width: 16,
                                color: MyTheme.dark_grey)),
                      ],
                    )),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //home icon
              Icon(Icons.home_outlined, color: MyTheme.dark_grey, size: 26),

              Padding(
                padding: EdgeInsets.all(4),
                child: Text("Business Type: Ecommerce/Online Trading",
                    style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                        fontWeight: FontWeight.normal)),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //home icon
              Icon(Icons.location_pin, color: MyTheme.dark_grey, size: 26),
              SizedBox(width: 10),
              Text(
                _vendorDetails?.address != null ? _vendorDetails!.address! : "",
                style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                    fontWeight: FontWeight.normal),
              ),
            ],
          ),
          // a rounded button with a text "View More"
          SizedBox(height: 20),
          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SellerDetails(
                            slug: _productDetails?.products!.userId ?? "1",
                          )));
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 100, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: MyTheme.dark_grey, width: 1),
                color: MyTheme.light_grey,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "Visit Seller Store",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ]));
  }

  Widget buildTotalPriceRow() {
    return Container(
      height: 40,
      color: MyTheme.amber,
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          Container(
            child: Padding(
              padding: app_language_rtl.$!
                  ? EdgeInsets.only(left: 8.0)
                  : EdgeInsets.only(right: 8.0),
              child: Container(
                width: 75,
                child: Text(
                  AppLocalizations.of(context)!.total_price_ucf,
                  style: TextStyle(
                      color: Color.fromRGBO(153, 153, 153, 1), fontSize: 10),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 5.0),
            child: Text(
              "GH" + _totalPrice.toString(),
              style: TextStyle(
                  color: MyTheme.accent_color,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600),
            ),
          )
        ],
      ),
    );
  }

  Row buildQuantityRow() {
    return Row(
      children: [
        Padding(
          padding: app_language_rtl.$!
              ? EdgeInsets.only(left: 8.0)
              : EdgeInsets.only(right: 8.0),
          child: Container(
            width: 75,
            child: Text(
              AppLocalizations.of(context)!.quantity_ucf,
              style: TextStyle(color: Color.fromRGBO(153, 153, 153, 1)),
            ),
          ),
        ),
        Container(
          height: 36,
          width: 120,
          /*decoration: BoxDecoration(
              border:
                  Border.all(color: Color.fromRGBO(222, 222, 222, 1), width: 1),
              borderRadius: BorderRadius.circular(36.0),
              color: Colors.white),*/
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              buildQuantityDownButton(),
              /* Container(
                  width: 36,
                  child: Center(
                      child: Text(
                    _quantity.toString(),
                    style: TextStyle(fontSize: 18, color: MyTheme.dark_grey),
                  ))),*/
              Container(
                  width: 36,
                  child: Center(
                      child: QuantityInputField.show(quantityText,
                          isDisable: _quantity == 0, onSubmitted: () {
                    _quantity = int.parse(quantityText.text);
                    print(_quantity);
                    fetchAndSetVariantWiseInfo();
                  }))),
              buildQuantityUpButton()
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            "",
            style: TextStyle(
                color: Color.fromRGBO(152, 152, 153, 1), fontSize: 14),
          ),
        ),
      ],
    );
  }

  TextEditingController quantityText = TextEditingController(text: "0");

  Padding buildVariantShimmers() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16.0,
        0.0,
        8.0,
        0.0,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: [
                Padding(
                  padding: app_language_rtl.$!
                      ? EdgeInsets.only(left: 8.0)
                      : EdgeInsets.only(right: 8.0),
                  child: ShimmerHelper()
                      .buildBasicShimmer(height: 30.0, width: 60),
                ),
                Padding(
                  padding: app_language_rtl.$!
                      ? EdgeInsets.only(left: 8.0)
                      : EdgeInsets.only(right: 8.0),
                  child: ShimmerHelper()
                      .buildBasicShimmer(height: 30.0, width: 60),
                ),
                Padding(
                  padding: app_language_rtl.$!
                      ? EdgeInsets.only(left: 8.0)
                      : EdgeInsets.only(right: 8.0),
                  child: ShimmerHelper()
                      .buildBasicShimmer(height: 30.0, width: 60),
                ),
                Padding(
                  padding: app_language_rtl.$!
                      ? EdgeInsets.only(left: 8.0)
                      : EdgeInsets.only(right: 8.0),
                  child: ShimmerHelper()
                      .buildBasicShimmer(height: 30.0, width: 60),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: [
                Padding(
                  padding: app_language_rtl.$!
                      ? EdgeInsets.only(left: 8.0)
                      : EdgeInsets.only(right: 8.0),
                  child: ShimmerHelper()
                      .buildBasicShimmer(height: 30.0, width: 60),
                ),
                Padding(
                  padding: app_language_rtl.$!
                      ? EdgeInsets.only(left: 8.0)
                      : EdgeInsets.only(right: 8.0),
                  child: ShimmerHelper()
                      .buildBasicShimmer(height: 30.0, width: 60),
                ),
                Padding(
                  padding: app_language_rtl.$!
                      ? EdgeInsets.only(left: 8.0)
                      : EdgeInsets.only(right: 8.0),
                  child: ShimmerHelper()
                      .buildBasicShimmer(height: 30.0, width: 60),
                ),
                Padding(
                  padding: app_language_rtl.$!
                      ? EdgeInsets.only(left: 8.0)
                      : EdgeInsets.only(right: 8.0),
                  child: ShimmerHelper()
                      .buildBasicShimmer(height: 30.0, width: 60),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  // buildChoiceOptionList() {
  //   return ListView.builder(
  //     itemCount: _productDetails!.choice_options!.length,
  //     scrollDirection: Axis.vertical,
  //     shrinkWrap: true,
  //     padding: EdgeInsets.zero,
  //     physics: NeverScrollableScrollPhysics(),
  //     itemBuilder: (context, index) {
  //       return Padding(
  //         padding: const EdgeInsets.only(bottom: 8.0),
  //         child: buildChoiceOpiton(_productDetails!.choice_options, index),
  //       );
  //     },
  //   );
  // }

  buildChoiceOpiton(choice_options, choice_options_index) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        0.0,
        14.0,
        0.0,
        0.0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: app_language_rtl.$!
                ? EdgeInsets.only(left: 8.0)
                : EdgeInsets.only(right: 8.0),
            child: Container(
              width: 75,
              child: Text(
                choice_options[choice_options_index].title,
                style: TextStyle(color: Color.fromRGBO(153, 153, 153, 1)),
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width - (107 + 45),
            child: Scrollbar(
              controller: _variantScrollController,
              trackVisibility: false,
              child: Wrap(
                children: List.generate(
                    choice_options[choice_options_index].options.length,
                    (index) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Container(
                          width: 75,
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: buildChoiceItem(
                              choice_options[choice_options_index]
                                  .options[index],
                              choice_options_index,
                              index),
                        ))),
              ),

              /*ListView.builder(
                itemCount: choice_options[choice_options_index].options.length,
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return
                },
              ),*/
            ),
          )
        ],
      ),
    );
  }

  buildQuickView() {
    return Container(
      child: GridView.count(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        childAspectRatio: 3,
        children: List.generate(6, (index) {
          return Container(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Text('Detail ${index + 1}'),
                ),
                Expanded(
                  child: Text('Value ${index + 1}'),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  buildChoiceItem(option, choice_options_index, index) {
    return Padding(
      padding: app_language_rtl.$!
          ? EdgeInsets.only(left: 8.0)
          : EdgeInsets.only(right: 8.0),
      child: InkWell(
        onTap: () {
          _onVariantChange(choice_options_index, option);
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
                color: _selectedChoices[choice_options_index] == option
                    ? MyTheme.accent_color
                    : MyTheme.noColor,
                width: 1.5),
            borderRadius: BorderRadius.circular(3.0),
            color: MyTheme.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 6,
                spreadRadius: 1,
                offset: Offset(0.0, 3.0), // shadow direction: bottom right
              )
            ],
          ),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 3.0),
            child: Center(
              child: Text(
                option,
                style: TextStyle(
                    color: _selectedChoices[choice_options_index] == option
                        ? MyTheme.accent_color
                        : Color.fromRGBO(224, 224, 225, 1),
                    fontSize: 12.0,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ),
    );
  }

  buildColorRow() {
    return Row(
      children: [
        Padding(
          padding: app_language_rtl.$!
              ? EdgeInsets.only(left: 8.0)
              : EdgeInsets.only(right: 8.0),
          child: Container(
            width: 75,
            child: Text(
              AppLocalizations.of(context)!.color_ucf,
              style: TextStyle(color: Color.fromRGBO(153, 153, 153, 1)),
            ),
          ),
        ),
        Container(
          alignment: app_language_rtl.$!
              ? Alignment.centerRight
              : Alignment.centerLeft,
          height: 40,
          width: MediaQuery.of(context).size.width - (107 + 44),
          child: Scrollbar(
            controller: _colorScrollController,
            child: ListView.separated(
              separatorBuilder: (context, index) {
                return SizedBox(
                  width: 10,
                );
              },
              itemCount: _colorList.length,
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    buildColorItem(index),
                  ],
                );
              },
            ),
          ),
        )
      ],
    );
  }

  Widget buildColorItem(index) {
    return InkWell(
      onTap: () {
        _onColorChange(index);
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 400),
        width: _selectedColorIndex == index ? 30 : 25,
        height: _selectedColorIndex == index ? 30 : 25,
        decoration: BoxDecoration(
          // border: Border.all(
          //     color: _selectedColorIndex == index
          //         ? Colors.purple
          //         : Colors.white,
          //     width: 1),
          borderRadius: BorderRadius.circular(16.0),
          color: ColorHelper.getColorFromColorCode(_colorList[index]),
          boxShadow: [
            BoxShadow(
              color: Colors.black
                  .withOpacity(_selectedColorIndex == index ? 0.25 : 0.12),
              blurRadius: 10,
              spreadRadius: 2.0,
              offset: Offset(0.0, 6.0), // shadow direction: bottom right
            )
          ],
        ),
        child: _selectedColorIndex == index
            ? buildColorCheckerContainer()
            : Container(
                height: 25,
              ),
        /*Padding(
          padding: const EdgeInsets.all(2.0),
          child: Container(
            height: 24,
            width: 24,
            decoration: BoxDecoration(
                // border: Border.all(
                //     color: Color.fromRGBO(222, 222, 222, 1), width: 1),
               // borderRadius: BorderRadius.circular(16.0),
                color: ColorHelper.getColorFromColorCode(_colorList[index])),
            child: _selectedColorIndex == index
                ? buildColorCheckerContainer()
                : Container(),
          ),
        ),*/
      ),
    );
  }

  buildColorCheckerContainer() {
    return Padding(
        padding: const EdgeInsets.all(3),
        child: /*Icon(Icons.check, color: Colors.white, size: 16),*/
            Image.asset(
          "assets/white_tick.png",
          width: 16,
          height: 16,
        ));
  }

  // Widget buildWholeSaleQuantityPrice() {
  //   return DataTable(
  //     // clipBehavior:Clip.antiAliasWithSaveLayer,
  //     columnSpacing: DeviceInfo(context).width! * 0.125,

  //     columns: [
  //       DataColumn(
  //           label: Text(LangText(context).local.min_qty_ucf,
  //               style: TextStyle(fontSize: 12, color: MyTheme.dark_grey))),
  //       DataColumn(
  //           label: Text(LangText(context).local.max_qty_ucf,
  //               style: TextStyle(fontSize: 12, color: MyTheme.dark_grey))),
  //       DataColumn(
  //           label: Text(LangText(context).local.unit_price_ucf,
  //               style: TextStyle(fontSize: 12, color: MyTheme.dark_grey))),
  //     ],
  //     rows: List<DataRow>.generate(
  //       _productDetails!.wholesale!.length,
  //       (index) {
  //         return DataRow(cells: <DataCell>[
  //           DataCell(
  //             Text(
  //               '${_productDetails!.wholesale![index].minQty.toString()}',
  //               style: TextStyle(
  //                   color: Color.fromRGBO(152, 152, 153, 1), fontSize: 12),
  //             ),
  //           ),
  //           DataCell(
  //             Text(
  //               '${_productDetails!.wholesale![index].maxQty.toString()}',
  //               style: TextStyle(
  //                   color: Color.fromRGBO(152, 152, 153, 1), fontSize: 12),
  //             ),
  //           ),
  //           DataCell(
  //             Text(
  //               convertPrice(
  //                   _productDetails!.wholesale![index].price.toString()),
  //               style: TextStyle(
  //                   color: Color.fromRGBO(152, 152, 153, 1), fontSize: 12),
  //             ),
  //           ),
  //         ]);
  //       },
  //     ),
  //   );
  // }

  Widget buildClubPointRow() {
    return Container(
      constraints: BoxConstraints(maxWidth: 130),
      //width: ,
      decoration: BoxDecoration(
          //border: Border.all(color: MyTheme.golden, width: 1),
          borderRadius: BorderRadius.circular(6.0),
          color:
              //Colors.red,),
              Color.fromRGBO(253, 235, 212, 1)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset(
                  "assets/clubpoint.png",
                  width: 18,
                  height: 12,
                ),
                SizedBox(
                  width: 5,
                ),
                Text(
                  AppLocalizations.of(context)!.club_point_ucf,
                  style: TextStyle(color: MyTheme.font_grey, fontSize: 10),
                ),
              ],
            ),
            Text(
              _productDetails!.products!.rating.toString(),
              style: TextStyle(color: MyTheme.golden, fontSize: 12.0),
            ),
          ],
        ),
      ),
    );
  }

  Row buildMainPriceRow() {
    return Row(
      children: [
        Text(
          SystemConfig.systemCurrency != null
              ? _singlePriceString.replaceAll(SystemConfig.systemCurrency!.code,
                  SystemConfig.systemCurrency!.symbol)
              : "${SystemConfig.currency} ${_singlePriceString} - ${_productDetails!.products!.priceDiscounted} ",
          // _singlePriceString,
          style: TextStyle(
              color: MyTheme.accent_color,
              fontSize: 16.0,
              fontWeight: FontWeight.w800),
        ),
        Visibility(
          visible: true,
          child: Padding(
            padding: EdgeInsets.only(left: 1.0),
            child: Text(
              " / Piece",
              style: TextStyles.largeBoldAccentTexStyle(),
            ),
          ),
        ),
      ],
    );
  }

  AppBar buildAppBar(double statusBarHeight, BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(CupertinoIcons.arrow_left, color: MyTheme.dark_grey),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      title: Container(
        height: kToolbarHeight +
            statusBarHeight -
            (MediaQuery.of(context).viewPadding.top > 40 ? 32.0 : 16.0),
        //MediaQuery.of(context).viewPadding.top is the statusbar height, with a notch phone it results almost 50, without a notch it shows 24.0.For safety we have checked if its greater than thirty
        child: Container(
            width: 300,
            child: Padding(
              padding: const EdgeInsets.only(top: 22.0),
              child: Text(
                _appbarPriceString!,
                style: TextStyle(fontSize: 16, color: MyTheme.font_grey),
              ),
            )),
      ),
      elevation: 0.0,
      titleSpacing: 0,
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
          child: IconButton(
            icon: Icon(Icons.share_outlined, color: MyTheme.dark_grey),
            onPressed: () {
              createDynamicLink(_productDetails!.products!.id.toString());
            },
          ),
        ),
      ],
    );
  }

  Future<void> _makePhoneCall() async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: _vendorDetails!.phoneNumber!,
    );
    if (await canLaunch(launchUri.toString())) {
      await launch(launchUri.toString());
    } else {
      throw 'Could not launch $launchUri';
    }
  }

  Widget buildBottomAppBar(BuildContext context, _addedToCartSnackbar) {
    return BottomAppBar(
      color: MyTheme.white.withOpacity(0.9),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(1.0),
            child: IconButton(
              icon: Icon(Icons.call),
              color: MyTheme.dark_font_grey,
              onPressed: () {
                _makePhoneCall();
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(1.0),
            child: IconButton(
              icon: Image.asset("assets/new-chat.png"),
              color: MyTheme.dark_font_grey,
              onPressed: () {
                onPressAddToCart(context, _addedToCartSnackbar);
              },
            ),
          ),
          Expanded(
            // Use Expanded here
            child: Container(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  backgroundColor: MyTheme.accent_color,
                ),
                onPressed: () {
                  onPressBuyNow(context, _productDetails);
                },
                child: Text(
                  AppLocalizations.of(context)!.buy_now_ucf,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBottomAppBar2(BuildContext context, _addedToCartSnackbar) {
    return BottomNavigationBar(
      backgroundColor: MyTheme.white.withOpacity(0.9),
      items: [
        BottomNavigationBarItem(
          backgroundColor: Colors.transparent,
          label: '',
          icon: InkWell(
            onTap: () {
              onPressAddToCart(context, _addedToCartSnackbar);
            },
            child: Container(
              margin: EdgeInsets.only(
                left: 18,
                right: 18,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6.0),
                color: MyTheme.accent_color,
                boxShadow: [
                  BoxShadow(
                    color: MyTheme.accent_color_shadow,
                    blurRadius: 20,
                    spreadRadius: 0.0,
                    offset: Offset(0.0, 10.0), // shadow direction: bottom right
                  )
                ],
              ),
              height: 50,
              child: Center(
                child: Text(
                  AppLocalizations.of(context)!.add_to_cart_ucf,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ),
        BottomNavigationBarItem(
          label: "",
          icon: InkWell(
            onTap: () {
              onPressBuyNow(context, _productDetails);
            },
            child: Container(
              margin: EdgeInsets.only(left: 18, right: 18),
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6.0),
                color: MyTheme.golden,
                boxShadow: [
                  BoxShadow(
                    color: MyTheme.golden_shadow,
                    blurRadius: 20,
                    spreadRadius: 0.0,
                    offset: Offset(0.0, 10.0), // shadow direction: bottom right
                  )
                ],
              ),
              child: Center(
                child: Text(
                  AppLocalizations.of(context)!.buy_now_ucf,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        )
        /*Container(
          color: Colors.white.withOpacity(0.95),
          height: 83,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 18,
              ),

              SizedBox(
                width: 14,
              ),

              SizedBox(
                width: 18,
              ),
            ],
          ),
        )*/
      ],
    );
  }

  buildRatingAndWishButtonRow() {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: RichText(
            text: TextSpan(
              children: <TextSpan>[
                TextSpan(
                  text: _my_rating_temp.toString(),
                  style: TextStyle(color: Colors.black, fontSize: 18),
                ),
                TextSpan(
                  text: "/5",
                  style: TextStyle(color: Colors.black, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
        RatingBar(
          itemSize: 15.0,
          ignoreGestures: true,
          initialRating: _my_rating_temp,
          direction: Axis.horizontal,
          allowHalfRating: false,
          itemCount: 5,
          ratingWidget: RatingWidget(
            full: Icon(Icons.star, color: Colors.amber),
            half: Icon(Icons.star_half, color: Colors.amber),
            empty: Icon(Icons.star, color: Color.fromRGBO(224, 224, 225, 1)),
          ),
          itemPadding: EdgeInsets.only(right: 1.0),
          onRatingUpdate: (rating) {
            //print(rating);
          },
        ),
      ],
    );
  }

  buildShippingTime() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 1.0),
            child: Image.network(
              "https://image.flylandexpress.com/images/home-page/flylan-express-officia-1.webp",
              height: 50,
              width: 100,
            )),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(
            "Order Now and Get it Today",
            style:
                TextStyle(color: Color.fromRGBO(38, 38, 39, 1), fontSize: 10),
          ),
        ),
      ],
    );
  }

  buildFullfilment() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0, top: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                "Fulfilment: ",
                style: TextStyle(
                    color: Color.fromRGBO(153, 153, 153, 1), fontSize: 12),
              )),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              "Express, SAMEDAY DELIVERY",
              style:
                  TextStyle(color: Color.fromRGBO(38, 38, 39, 1), fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  buildBrandRow() {
    return
        //  _productDetails!.brandId > 0
        //     ? InkWell(
        //         onTap: () {
        //           Navigator.push(context, MaterialPageRoute(builder: (context) {
        //             return BrandProducts(
        //               slug: _productDetails!.slug!,
        //             );
        //           }));
        //         },
        //         child: Row(
        //           children: [
        //             Padding(
        //               padding: app_language_rtl.$!
        //                   ? EdgeInsets.only(left: 8.0)
        //                   : EdgeInsets.only(right: 8.0),
        //               child: Container(
        //                 width: 75,
        //                 child: Text(
        //                   AppLocalizations.of(context)!.brand_ucf,
        //                   style: TextStyle(
        //                       color: Color.fromRGBO(
        //                         153,
        //                         153,
        //                         153,
        //                         1,
        //                       ),
        //                       fontSize: 10),
        //                 ),
        //               ),
        //             ),
        //             Padding(
        //               padding: const EdgeInsets.symmetric(horizontal: 4.0),
        //               child: Text(
        //                 _productDetails!.brand!.name!,
        //                 style: TextStyle(
        //                     color: MyTheme.font_grey,
        //                     fontWeight: FontWeight.bold,
        //                     fontSize: 10),
        //               ),
        //             ),
        //             /*Spacer(),
        //             Container(
        //               width: 36,
        //               height: 36,
        //               decoration: BoxDecoration(
        //                 borderRadius: BorderRadius.circular(5),
        //                 border: Border.all(
        //                     color: Color.fromRGBO(112, 112, 112, .3), width: 1),
        //                 //shape: BoxShape.rectangle,
        //               ),
        //               child: ClipRRect(
        //                   borderRadius: BorderRadius.circular(5),
        //                   child: FadeInImage.assetNetwork(
        //                     placeholder: 'assets/placeholder.png',
        //                     image: _productDetails!.brand.logo,
        //                     fit: BoxFit.contain,
        //                   )),
        //             ),*/
        //           ],
        //         ),
        //       )
        //     :
        Container();
  }

  buildExpandableDescription() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: DeviceInfo(context).width,
            height: webViewHeight * 2,
            child: WebViewWidget(
              controller: controller,
            ),
          ),
          Btn.basic(
            onPressed: () async {
              if (webViewHeight > 50) {
                webViewHeight = double.parse(
                  (await controller.runJavaScriptReturningResult(
                          "document.getElementById('scaled-frame').clientHeight"))
                      .toString(),
                );
                print(webViewHeight);
                print(MediaQuery.of(context).devicePixelRatio);

                // webViewHeight =( webViewHeight / MediaQuery.of(context).devicePixelRatio)+400;
                print(webViewHeight);
              } else {
                webViewHeight = 50;
              }
              setState(() {});
            },
          )
        ],
      ),
    );
    /*ExpandableNotifier(
        child: ScrollOnExpand(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expandable(
            collapsed: Container(
                height: 50, child: Html(data: _productDetails!.description)),
            expanded: Container(child: Html(
              data: _productDetails!.description,
            )
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Builder(
                builder: (context) {
                  var controller = ExpandableController.of(context)!;
                  return Btn.basic(
                    child: Text(
                      !controller.expanded
                          ? AppLocalizations.of(context)!.view_more_ucf
                          : AppLocalizations.of(context)!.show_less_ucf,
                      style: TextStyle(color: MyTheme.font_grey, fontSize: 11),
                    ),
                    onPressed: () {
                      controller.toggle();
                    },
                  );
                },
              ),
            ],
          ),
        ],
      ),
    ));*/
  }

  buildTopSellingProductList() {
    if (_topProductInit == false && _topProducts.length == 0) {
      return Column(
        children: [
          Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: ShimmerHelper().buildBasicShimmer(
                height: 75.0,
              )),
          Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: ShimmerHelper().buildBasicShimmer(
                height: 75.0,
              )),
          Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: ShimmerHelper().buildBasicShimmer(
                height: 75.0,
              )),
        ],
      );
    } else if (_topProducts.length > 0) {
      return SingleChildScrollView(
        child: ListView.separated(
          separatorBuilder: (context, index) => SizedBox(
            height: 14,
          ),
          itemCount: _topProducts.length,
          scrollDirection: Axis.vertical,
          padding: EdgeInsets.only(top: 14),
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return ListProductCard(
                id: _topProducts[index].id,
                slug: _topProducts[index].slug,
                image: _topProducts[index].image.imageDefault,
                name: _topProducts[index].productDetail.title,
                main_price: _topProducts[index].price,
                stroked_price: _topProducts[index].priceDiscounted,
                has_discount: true);
          },
        ),
      );
    } else {
      return Container(
          height: 100,
          child: Center(
              child: Text(
                  AppLocalizations.of(context)!
                      .no_top_selling_products_from_this_seller,
                  style: TextStyle(color: MyTheme.font_grey))));
    }
  }

  buildProductsMayLikeList() {
    if (_relatedProductInit == false && _relatedProducts.length == 0) {
      return Row(
        children: [
          Padding(
              padding: app_language_rtl.$!
                  ? EdgeInsets.only(left: 8.0)
                  : EdgeInsets.only(right: 8.0),
              child: ShimmerHelper().buildBasicShimmer(
                  height: 120.0,
                  width: (MediaQuery.of(context).size.width - 32) / 3)),
          Padding(
              padding: app_language_rtl.$!
                  ? EdgeInsets.only(left: 8.0)
                  : EdgeInsets.only(right: 8.0),
              child: ShimmerHelper().buildBasicShimmer(
                  height: 120.0,
                  width: (MediaQuery.of(context).size.width - 32) / 3)),
          Padding(
              padding: const EdgeInsets.only(right: 0.0),
              child: ShimmerHelper().buildBasicShimmer(
                  height: 120.0,
                  width: (MediaQuery.of(context).size.width - 32) / 3)),
        ],
      );
    } else if (_relatedProducts.length > 0) {
      return SingleChildScrollView(
        child: SizedBox(
          height: 248,
          child: ListView.separated(
            separatorBuilder: (context, index) => SizedBox(
              width: 16,
            ),
            padding: const EdgeInsets.all(16),
            itemCount: _relatedProducts.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              return MiniProductCard(
                  id: _relatedProducts[index].id,
                  slug: _relatedProducts[index].slug,
                  image: _relatedProducts[index].image.imageDefault,
                  name: _relatedProducts[index].productDetail.title,
                  main_price: _relatedProducts[index].priceDiscounted,
                  stroked_price: _relatedProducts[index].price,
                  is_wholesale: true,
                  discount: _relatedProducts[index].priceDiscounted,
                  has_discount: true);
            },
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

  buildQuantityUpButton() => Container(
        decoration: BoxDecorations.buildCircularButtonDecoration_1(),
        width: 36,
        child: IconButton(
            icon: Icon(Icons.add, size: 16, color: MyTheme.dark_grey),
            onPressed: () {
              if (_quantity! < _stock!) {
                _quantity = (_quantity!) + 1;
                setState(() {});
                //fetchVariantPrice();

                fetchAndSetVariantWiseInfo();
                // calculateTotalPrice();
              }
            }),
      );

  buildQuantityDownButton() => Container(
      decoration: BoxDecorations.buildCircularButtonDecoration_1(),
      width: 36,
      child: IconButton(
          icon: Icon(Icons.remove, size: 16, color: MyTheme.dark_grey),
          onPressed: () {
            if (_quantity! > 1) {
              _quantity = _quantity! - 1;
              setState(() {});
              // calculateTotalPrice();
              // fetchVariantPrice();
              fetchAndSetVariantWiseInfo();
            }
          }));

  openPhotoDialog(BuildContext context, path) => showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: Container(
                child: Stack(
              children: [
                PhotoView(
                  enableRotation: true,
                  heroAttributes: const PhotoViewHeroAttributes(tag: "someTag"),
                  imageProvider: NetworkImage(path),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    decoration: ShapeDecoration(
                      color: MyTheme.medium_grey_50,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(25),
                          bottomRight: Radius.circular(25),
                          topRight: Radius.circular(25),
                          topLeft: Radius.circular(25),
                        ),
                      ),
                    ),
                    width: 40,
                    height: 40,
                    child: IconButton(
                      icon: Icon(Icons.clear, color: MyTheme.white),
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).pop();
                      },
                    ),
                  ),
                ),
              ],
            )),
          );
        },
      );

  buildProductImageSection() {
    if (_productImageList.length == 0) {
      return Row(
        children: [
          Container(
            width: 40,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: ShimmerHelper()
                      .buildBasicShimmer(height: 40.0, width: 40.0),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: ShimmerHelper()
                      .buildBasicShimmer(height: 40.0, width: 40.0),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: ShimmerHelper()
                      .buildBasicShimmer(height: 40.0, width: 40.0),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: ShimmerHelper()
                      .buildBasicShimmer(height: 40.0, width: 40.0),
                ),
              ],
            ),
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: ShimmerHelper().buildBasicShimmer(
                height: 190.0,
              ),
            ),
          ),
        ],
      );
    } else {
      return Row(
        // mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: 64,
            width: 350,
            child: Scrollbar(
              controller: _imageScrollController,
              trackVisibility: false,
              thickness: 4.0,
              child: Padding(
                padding: app_language_rtl.$!
                    ? EdgeInsets.only(left: 8.0)
                    : EdgeInsets.only(right: 8.0),
                child: ListView.builder(
                    itemCount: _productImageList.length,
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      int itemIndex = index;
                      return GestureDetector(
                        onTap: () {
                          _currentImage = itemIndex;
                          print("test ${_currentImage}");
                          setState(() {
                            _currentImage = index;
                          });
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          margin: EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 2.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: _currentImage == itemIndex
                                    ? MyTheme.accent_color
                                    : Color.fromRGBO(112, 112, 112, .3),
                                width: _currentImage == itemIndex ? 2 : 1),
                            //shape: BoxShape.rectangle,
                          ),
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child:
                                  /*Image.asset(
                                        singleProduct.product_images[index])*/
                                  FadeInImage.assetNetwork(
                                placeholder: 'assets/placeholder.png',
                                image: _productImageList[index],
                                fit: BoxFit.contain,
                              )),
                        ),
                      );
                    }),
              ),
            ),
          ),
        ],
      );
    }
  }

  Widget buildProductSliderImageSection() {
    if (_productImageList.length == 0) {
      return ShimmerHelper().buildBasicShimmer(
        height: 190.0,
      );
    } else {
      return CarouselSlider(
        carouselController: _carouselController,
        options: CarouselOptions(
            aspectRatio: 355 / 375,
            viewportFraction: 1,
            initialPage: _currentImage,
            autoPlay: false,
            autoPlayInterval: Duration(seconds: 5),
            autoPlayAnimationDuration: Duration(milliseconds: 1000),
            autoPlayCurve: Curves.easeInExpo,
            enlargeCenterPage: false,
            scrollDirection: Axis.horizontal,
            onPageChanged: (index, reason) {
              print(index);
              setState(() {
                _currentImage = index;
              });
            }),
        items: _productImageList.map((i) {
          return Builder(
            builder: (BuildContext context) {
              return Container(
                child: Stack(
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                        openPhotoDialog(
                            context, _productImageList[_currentImage]);
                      },
                      child: Container(
                          padding: EdgeInsets.only(left: 18, right: 18),
                          height: double.infinity,
                          width: double.infinity,
                          child: FadeInImage.assetNetwork(
                            placeholder: 'assets/placeholder.png',
                            image: _productImageList[_currentImage],
                            fit: BoxFit.fitWidth,
                          )),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                              _productImageList.length,
                              (index) => Container(
                                    width: 7.0,
                                    height: 7.0,
                                    margin: EdgeInsets.symmetric(
                                        vertical: 10.0, horizontal: 4.0),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _currentImage == index
                                          ? MyTheme.font_grey
                                          : Colors.grey.withOpacity(0.2),
                                    ),
                                  ))),
                    ),
                  ],
                ),
              );
            },
          );
        }).toList(),
      );
    }
  }

  Widget divider() {
    return Container(
      color: MyTheme.light_grey,
      height: 5,
    );
  }

  String makeHtml(String string) {
    return """
<!DOCTYPE html>
<html>

<head>

<meta name="viewport" content="width=device-width, initial-scale=1.0">

    <link rel="stylesheet" href="${AppConfig.RAW_BASE_URL}/public/assets/css/vendors.css">
  <style>
  *{
  margin:0 !important;
  padding:0 !important;
  }

    #scaled-frame {
    }
  </style>
</head>

<body id="main_id">
  <div id="scaled-frame">
$string
  </div>
</body>

</html>
""";
  }
}
