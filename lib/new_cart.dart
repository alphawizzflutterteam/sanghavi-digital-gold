import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:atticadesign/Helper/Session.dart';
import 'package:atticadesign/Helper/paynow.dart';
import 'package:atticadesign/Model/address_model.dart';
import 'package:atticadesign/Model/cart_model.dart';
import 'package:atticadesign/Model/voucher_model.dart';
import 'package:atticadesign/Utils/ApiBaseHelper.dart';
import 'package:atticadesign/Utils/Razorpay.dart';
import 'package:atticadesign/Utils/Session.dart';
import 'package:atticadesign/Utils/colors.dart';
import 'package:atticadesign/Utils/constant.dart';
import 'package:atticadesign/Utils/widget.dart';
import 'package:atticadesign/screen/cart_product_view.dart';
import 'package:atticadesign/screen/voucher_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'Api/api.dart';
import 'Helper/Color.dart';
import 'Helper/order _Confirmed.dart';
import 'Model/UserDetailsModel.dart';
import 'Utils/Common.dart';
import 'screen/address_list_view.dart';

class NewCart extends StatefulWidget {
  // final String gramValue;
  // final itemCount;
  // final bool isGold;
  // final int type;
  // final bool buyNow;
  const NewCart({
    Key? key,
    // required this.gramValue,
    // this.itemCount,
    // required this.isGold,
    // required this.type,
    // required this.buyNow
  }) : super(key: key);

  @override
  State<NewCart> createState() => _NewCartState();
}

class _NewCartState extends State<NewCart> {
  TextEditingController controller = new TextEditingController();
  TimeOfDay selectedTime = TimeOfDay.now();
  ApiBaseHelper apiBase = new ApiBaseHelper();
  bool isNetwork = false;
  VoucherModel? model;
  bool loading = true;
  String selectTime = "Schedule Delivery time";
  double subTotal = 0,
      deliveryCharge = 0,
      amountWithoutTax = 0,
      tax = 0,
      taxPer = 0,
      restAmount = 0,
      totalAmount = 0,
      tempTotal = 0,
      amountPasValue = 0,
      proDiscount = 0;
  String? size;
  double? voucher;
  bool isWallet = false;
  bool isGoldWallet = false;
  bool isSilverWallet = false;
  bool isRazor = false;
  TextEditingController choiceAmountController = TextEditingController();

  getTotal() async {
    try {
      Map params = {
        "get_user_cart": "1",
        "user_id": App.localStorage.getString("userId").toString(),
      };
      Map response = await apiBase.postAPICall(
          Uri.parse(baseUrl + "get_user_cart"), params);
      setState(() {
        loading = true;
      });
      if (!response['error']) {
        // for (var v in response['cart_data']) {
        //   setState(() {
        //     productId.add(v['product_variant_id']);
        //     quantity.add(v['qty']);
        //     tax = response['tax_amount'];
        //     taxPer = response['tax_percentage'];
        //   });
        // }
        // print("@@ this is ${productId} && ${quantity}");

        setState(() {
          subTotal = double.parse(response['overall_amount'].toString());
          amountWithoutTax = double.parse(response['sub_total'].toString());
          if (response['delivery_charge'] != null) {
            deliveryCharge =
                double.parse(response['delivery_charge'].toString());
          }
          if (response['tax_amount'] != null) {
            tax = double.parse(response['tax_amount'].toString());
            // taxPer = double.parse(response['tax_percentage']);
          }

          // print('${subTotal}______________kjfhjksfhs');
          print('${amountWithoutTax}______________kjfhjksfhs');

          totalAmount = amountWithoutTax + tax;
          // + deliveryCharge
          // + tax;
          tempTotal = totalAmount;
        });
      } else {}
    } on TimeoutException catch (_) {
      setSnackbar("Something Went Wrong", context);
      setState(() {
        loading = true;
      });
    }
  }

  addVoucher(total, promoCode, model1) async {
    try {
      Map params = {
        "validate_promo_code": "1",
        "user_id": App.localStorage.getString("userId").toString(),
        "final_total": amountWithoutTax.toString(),
        "promo_code": promoCode.toString(),
      };
      Map response = await apiBase.postAPICall(
          Uri.parse(baseUrl + "validate_promo_code"), params);

      if (!response['error']) {
        setState(() {
          model = model1;
          voucher =
              double.parse(response['data'][0]['final_discount'].toString());

          totalAmount =
              double.parse(response['data'][0]['final_total'].toString()) + tax;
          // deliveryCharge +
          // tax;
        });
      } else {
        setSnackbar(response['message'], context);
      }
    } on TimeoutException catch (_) {
      setSnackbar("Something Went Wrong", context);
      setState(() {
        loading = true;
      });
    }
  }

  bool saveStatus = true;
  List<String> typeList = ["Home", "Office", "Other"];
  String? selectType;
  List<AddModel> addressList = [];
  int totalCount = 0;

  getAddress() async {
    try {
      setState(() {
        //curIndex = null;
        selectType = null;
        addressList.clear();
        saveStatus = false;
      });
      Map params = {
        "get_addresses": "1",
        "user_id": App.localStorage.getString("userId").toString(),
      };
      Map response =
          await apiBase.postAPICall(Uri.parse(baseUrl + "get_address"), params);
      setState(() {
        saveStatus = true;
      });
      if (!response['error']) {
        for (var v in response['data']) {
          setState(() {
            if (v['type'] != "") {
              addressList.add(new AddModel.fromJson(v));
            }
          });
        }
      } else {
        setSnackbar(response['message'], context);
      }
    } on TimeoutException catch (_) {
      setSnackbar("Something Went Wrong", context);
      setState(() {
        saveStatus = true;
      });
    }
  }

  void addCart(i) {
    Map data = {};
    int count = parseInt(cartList[i].qty);
    setState(() {
      count++;
      String? aad = cartList[i].qty.toString();
      aad = count.toString();
      totalCount++;
    });
    data = {
      "add_to_cart": "1",
      "user_id": App.localStorage.getString("userId").toString(),
      "product_id": cartList[i].productId,
      "product_variant_id": cartList[i].productDetails![0].variants![0].id,
      "qty": count.toString(),
      "size": cartList[i].size.toString()
    };
    print("data @@ $data");
    callApi("manage_cart", data, "", i);
  }

  void callApi(String url, Map data, String check, int i) async {
    isNetwork = await isNetworkAvailable();
    if (isNetwork) {
      try {
        setState(() {
          loading = false;
        });
        Map response =
            await apiBase.postAPICall(Uri.parse(baseUrl + url), data);
        setState(() {
          loading = true;
        });
        if (!response['error']) {
          if (check == "remove") {
            getCart();
            getTotal();
          } else {
            getCart();
            getTotal();
          }
        } else {
          if (i != -1) {
            int count = parseInt(cartList[i].qty);
            setState(() {
              count--;
              var asd = cartList[i].qty;
              asd = count.toString();
              totalCount--;
            });
          }
          setSnackbar(response['message'], context);
        }
      } on TimeoutException catch (_) {
        setSnackbar("Something Went Wrong", context);
        setState(() {
          loading = true;
        });
      }
    } else {
      setSnackbar("No Internet Available", context);
    }
  }

  void removeCart(i) {
    Map data1 = {};

    int count = parseInt(cartList[i].qty);
    if (count == 1) {
      setState(() {
        count--;
        String? aad = cartList[i].qty;
        aad = count.toString();
        totalCount--;
      });

      data1 = {
        "remove_from_cart": "1",
        "user_id": App.localStorage.getString("userId").toString(),
        "qty": count.toString(),
        "product_variant_id": cartList[i].productDetails![0].variants![0].id,
        "size": cartList[i].size.toString()
      };
      print("data ## $data1");
      callApi("manage_cart", data1, "remove", -1);
    } else {
      setState(() {
        count--;
        String? aad = cartList[i].qty;
        aad = count.toString();
        totalCount--;
      });
      data1 = {
        "add_to_cart": "1",
        "user_id": App.localStorage.getString("userId").toString(),
        "product_id": cartList[i].productId,
        "product_variant_id": cartList[i].productDetails![0].variants![0].id,
        "qty": count.toString(),
        "size": cartList[i].size.toString()
      };
      print("data ## $data1");
      print("ok");
      callApi("manage_cart", data1, "", -1);
    }
  }

  void remove(i) {
    Map data;
    data = {
      "remove_from_cart": "1",
      "user_id": App.localStorage.getString("userId").toString(),
      "product_variant_id": cartList[i].productDetails![0].variants![0].id,
      "qty": cartList[i].qty,
      "size": cartList[i].size.toString()
    };
    print("data ^^ $data");
    callApi("remove_from_cart", data, "remove", -1);
  }

  // void getWallet() async {
  //   userDetailsModel =
  //   await userDetails(App.localStorage.getString("userId").toString());
  //   if (userDetailsModel != null &&
  //       userDetailsModel.data![0].silverWallet != null &&
  //       userDetailsModel.data![0].silverWallet != "") {
  //     setState(() {
  //       print(userDetailsModel.data![0].silverWallet.toString());
  //       availebaleSilveGram =
  //           double.parse(userDetailsModel.data![0].silverWallet.toString());
  //       silverWallet =
  //           double.parse(userDetailsModel.data![0].silverWallet.toString()) *
  //               silverGram;
  //     });
  //   }
  //   if (userDetailsModel != null &&
  //       userDetailsModel.data![0].goldWallet != null &&
  //       userDetailsModel.data![0].goldWallet != "") {
  //     setState(() {
  //       print(userDetailsModel.data![0].goldWallet.toString());
  //       availeGoldgram =
  //           double.parse(userDetailsModel.data![0].goldWallet.toString());
  //       goldenWallet =
  //           double.parse(userDetailsModel.data![0].goldWallet.toString()) *
  //               goldGram;
  //     });
  //   }
  //   if (userDetailsModel != null &&
  //       userDetailsModel.data![0].balance != null &&
  //       userDetailsModel.data![0].balance != "") {
  //     setState(() {
  //       print(userDetailsModel.data![0].balance.toString());
  //       totalBalance =
  //           double.parse(userDetailsModel.data![0].balance.toString());
  //     });
  //   }
  //
  // }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCart();
    getAddress();
    getTotal();
    getWallet();
  }

  /* void addCart(i) {
    Map data1 = {};
    Map data = {};

    data = {
      "add_to_cart": "1",
      "user_id": App.localStorage.getString("userId").toString(),
      "product_id": widget.productId,
      "product_variant_id": cartList[i].productDetails![0].variants![0].id,
      "qty": cartList[i].qty,
    };
    callApi("manage_cart", data, "", i);
  }*/

  double priceRange = 0;

  int type = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: colors.secondary2,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: colors.primaryNew,
        //colors.secondary2,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back,
            color: colors.secondary2,
          ),
        ),
        title: Text(
          "Cart",
          style: TextStyle(
            color: colors.blackTemp,
            fontSize: 20,
          ),
        ),
      ),
      body: !loadingCart
          ? cartList.isEmpty
              ? Container(
                  height: getHeight(600),
                  child: Center(
                    child: text(
                      "No Items Found!!",
                      textColor: Theme.of(context).colorScheme.black,
                    ),
                  ),
                )
              : SafeArea(
                  child: SingleChildScrollView(
                      child: Container(
                    // height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.symmetric(horizontal: getWidth1(20)),
                    decoration: BoxDecoration(
                        //     image: DecorationImage(
                        //   image: AssetImage(
                        //     'assets/homepage/vertical.png',
                        //   ),
                        //   fit: BoxFit.cover,
                        // )
                        ),
                    child: Column(
                      children: [
                        boxHeight(30),
                        ListView.builder(
                            itemCount: cartList.length,
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              cartList[index].productDetails![0].categoryName ==
                                      "Gold"
                                  ? type = 1
                                  : type = 2;
                              return CartProductView(
                                  cartList[index],
                                  () {
                                    setState(() {
                                      currentIndex = index;
                                    });
                                    removeCart(index);
                                  },
                                  () {
                                    setState(() {
                                      currentIndex = index;
                                    });
                                    addCart(index);
                                  },
                                  () {},
                                  () {
                                    setState(() {
                                      currentIndex = index;
                                    });
                                    showDialog(
                                      context: context,
                                      builder: (ctxt) => new AlertDialog(
                                        backgroundColor: colors.secondary2,
                                        title: Text(
                                          "Are you sure you want to remove this product",
                                          style: TextStyle(
                                              fontWeight: FontWeight.normal,
                                              color: colors.blackTemp),
                                        ),
                                        actions: [
                                          TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text(
                                                "Cancel",
                                                style: TextStyle(
                                                    color: colors.blackTemp),
                                              )),

                                          TextButton(
                                              onPressed: () {
                                                remove(index);
                                                Navigator.pop(context);
                                              },
                                              child: Text(
                                                "Yes",
                                                style: TextStyle(
                                                    color: colors.blackTemp),
                                              )),
                                          // GestureDetector(
                                          //   child: Text("Cancel"),
                                          //   onTap: (){
                                          //     Navigator.pop(context);
                                          //   },
                                          // ),
                                          // GestureDetector(
                                          //   child: Center(child: Text("Yes")),
                                          //   onTap: (){
                                          //     remove(index);
                                          //     Navigator.pop(context);
                                          //   },
                                          // )
                                        ],
                                      ),
                                    );
                                  },
                                  currentIndex == index ? loading : true);
                            }),
                        boxHeight(20),
                        // Container(
                        //   decoration: boxDecoration(
                        //     bgColor: colors.secondary2,
                        //     radius: 10,
                        //   ),
                        //   padding: EdgeInsets.all(getWidth1(10)),
                        //   child: DropdownButton<String>(
                        //     underline: SizedBox(),
                        //     iconSize: getHeight(40),
                        //     dropdownColor: colors.secondary2,
                        //     isDense: true,
                        //     isExpanded: true,
                        //     icon: Icon(Icons.keyboard_arrow_down_outlined),
                        //     iconEnabledColor: MyColorName.primaryDark,
                        //     value: selectType,
                        //     items: typeList.map((p) {
                        //       return DropdownMenuItem<String>(
                        //         value: p,
                        //         child: text(p,
                        //             fontSize: 12.sp,
                        //             fontFamily: fontMedium,
                        //             textColor: colors.blackTemp),
                        //       );
                        //     }).toList(),
                        //     hint: text("Choose Address Type",
                        //         fontSize: 12.sp,
                        //         fontFamily: fontMedium,
                        //         textColor: colors.blackTemp),
                        //     onChanged: (value) {
                        //       setState(() {
                        //         selectType = value;
                        //         curIndex = null;
                        //       });
                        //       int i = addressList.indexWhere((element) =>
                        //           element.type!.toLowerCase() ==
                        //           selectType!.toLowerCase());
                        //       if (i != -1) {
                        //         setState(() {
                        //           curIndex = i;
                        //         });
                        //       } else {}
                        //     },
                        //   ),
                        // ),
                        // boxHeight(10),
                        Container(
                          decoration: boxDecoration(
                            bgColor: colors.secondary2.withOpacity(0.5),
                            radius: 10,
                          ),
                          padding: EdgeInsets.all(getWidth1(10)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on_outlined,
                                        color: colors.blackTemp,
                                      ),
                                      boxWidth(10),
                                      text("Delivery Address",
                                          fontSize: 10.sp,
                                          fontFamily: fontMedium,
                                          textColor: colors.blackTemp),
                                    ],
                                  ),
                                  /*PopupMenuButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0)),
                          color: colors.blackTemp,
                          //Theme.of(context).colorScheme.black,
                          onSelected: (value) async {
                            var result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      AddressList(false, false, curIndex)),
                            );
                            print('thisis address data $result');
                            if (result != null) {
                              setState(() {
                                address = result['address'];
                                selectType = result['type'];
                              });

                              int i = addressList.indexWhere((element) =>
                              element.type!.toLowerCase() ==
                                  selectType!.toLowerCase());
                              if (i != -1) {
                                setState(() {
                                  curIndex = i;
                                });
                              }
                            }
                          },
                          itemBuilder: (BuildContext bc) {
                            return const [
                              PopupMenuItem(
                                child: InkWell(
                                  child: ListTile(
                                    leading: Icon(
                                      Icons.edit,
                                      color: colors.whiteTemp,
                                    ),
                                    title: Text(
                                      "Edit",
                                      style: TextStyle(color: colors.whiteTemp),
                                    ),
                                  ),
                                ),
                                value: 'Edit',
                              ),
                              PopupMenuItem(
                                child: ListTile(
                                  leading: Icon(
                                    Icons.add_circle_outline,
                                    color: colors.whiteTemp,
                                  ),
                                  title: Text(
                                    "Add",
                                    style: TextStyle(color: colors.whiteTemp),
                                  ),
                                ),
                                value: 'Add',
                              ),
                              PopupMenuItem(
                                child: ListTile(
                                  leading: Icon(
                                    Icons.delete_forever,
                                    color: colors.whiteTemp,
                                  ),
                                  title: Text(
                                    "Delete",
                                    style: TextStyle(color: colors.whiteTemp),
                                  ),
                                ),
                                value: 'Delete',
                              )
                            ];
                          },
                        ),*/
                                ],
                              ),
                              boxHeight(10),
                              InkWell(
                                onTap: () async {
                                  var result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => AddressList(
                                            false, false, curIndex)),
                                  );
                                  print(
                                      'this is result ${result['address']} ${result['type']}');
                                  if (result != null) {
                                    setState(() {
                                      address = result['address'];
                                      selectType = result['type'];
                                    });

                                    int i = addressList.indexWhere((element) =>
                                        element.address!.toLowerCase() ==
                                        address.toLowerCase());
                                    if (i != -1) {
                                      setState(() {
                                        curIndex = i;
                                      });
                                    }
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.only(
                                      left: 10, right: 10, top: 8, bottom: 8),
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                    color: colors.secondary2.withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: colors.blackTemp),
                                    boxShadow: <BoxShadow>[
                                      BoxShadow(
                                          color: Colors.black54,
                                          blurRadius: 1.0,
                                          offset: Offset(0.00, 0.75))
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      text(
                                          addressList.isNotEmpty
                                              ? curIndex != null
                                                  ? addressList[curIndex!]
                                                      .address
                                                      .toString()
                                                  : "Select Or Add Address"
                                              : "Select Or Add Address",
                                          fontSize: 10.sp,
                                          fontFamily: fontMedium,
                                          textColor: colors.blackTemp),
                                      text("Change",
                                          fontSize: 8.sp,
                                          fontFamily: fontMedium,
                                          textColor: colors.blackTemp),
                                    ],
                                  ),
                                ),
                              ),
                              boxHeight(5),
                              Divider(),
                              TextFormField(
                                controller: controller,
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  fillColor: Colors.transparent,
                                  filled: true,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.transparent),
                                  ),
                                  prefixIcon: Container(
                                    height: getHeight1(16),
                                    width: getWidth1(16),
                                    padding: EdgeInsets.all(getWidth1(10)),
                                    child: Icon(
                                      Icons.speaker_notes,
                                      color: colors.blackTemp,
                                    ),
                                  ),
                                  label: text("Add Notes For Your Delivery",
                                      fontFamily: fontRegular),
                                ),
                              )
                            ],
                          ),
                        ),

                        boxHeight(35),
                        voucherView(),
                        model != null ? boxHeight(35) : SizedBox(),
                        model != null ? promoCode() : SizedBox(),
                        boxHeight(16),

                        boxHeight(16),
                        // text(
                        //   "Product Details",
                        //   fontFamily: fontMedium,
                        //   fontSize: 14.sp,
                        //   textColor: Theme.of(context).colorScheme.black
                        // ),
                        // boxHeight(16),
                        text("Your Cart Summary",
                            fontFamily: fontMedium,
                            fontSize: 14.sp,
                            textColor: Theme.of(context).colorScheme.black),
                        boxHeight(16),

                        priceView(),
                        boxHeight(16),
                        text("Use Wallet",
                            fontFamily: fontMedium,
                            fontSize: 14.sp,
                            textColor: Theme.of(context).colorScheme.black),
                        boxHeight(16),
                        paymentMode(),
                        boxHeight(15),

                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  width: getWidth1(283),
                                  height: getHeight1(85),
                                  decoration: boxDecoration(
                                    radius: 48,
                                    bgColor: colors.secondary2,
                                    color: colors.secondary2,
                                  ),
                                  child: Center(
                                    child: text("Cancel",
                                        fontFamily: fontMedium,
                                        fontSize: 22,
                                        textColor: colors.blackTemp),
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  print('${curIndex}__________');
                                  if (curIndex == null) {
                                    setSnackbar("Please Select or Add Address",
                                        context);
                                    return;
                                  }
                                  addressId =
                                      addressList[curIndex!].id.toString();
                                  latitude = double.parse(addressList[curIndex!]
                                      .latitude
                                      .toString());
                                  longitude = double.parse(
                                      addressList[curIndex!]
                                          .longitude
                                          .toString());
                                  print(
                                      'this is my available data $availeGoldgram $total916Weight $availebaleSilveGram $total999Weight');

                                  print(
                                      'this is my available data ${availebaleSilveGram < total999Weight}');

                                  if (total916Weight != 0 &&
                                      availeGoldgram < total916Weight) {
                                    validarionDialog();
                                  } else if (total999Weight != 0 &&
                                      availebaleSilveGram < total999Weight) {
                                    validarionDialog();
                                  } else {
                                    if (isWallet ||
                                        isGoldWallet ||
                                        isSilverWallet) {
                                      orderWithWaleet();
                                    } else {
                                      var a =
                                          double.parse(totalAmount.toString()) *
                                              100;
                                      RazorPayHelper razorHelper =
                                          new RazorPayHelper(
                                              totalAmount.toString(), context,
                                              (result) {
                                        if (result == "success") {
                                          addOrder();
                                        } else {
                                          // addOrder();
                                        }
                                      },
                                              App.localStorage
                                                  .getString("userId")
                                                  .toString(),
                                              // widget.gramValue.toString()
                                              '',
                                              false,
                                              true);
                                      razorHelper.initiated(true,
                                          amount: a.toString());
                                      // addOrder();
                                    }
                                  }

                                  // setSnackbar("Your vault balance is lower than your chosen products weight!", context);

                                  // Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //       builder: (context) => PayNow(
                                  //           voucher,
                                  //           totalAmount,
                                  //           model,
                                  //           "",
                                  //           controller.text,
                                  //           subTotal + tax,
                                  //           "NotAvailable",
                                  //           deliveryCharge.toString(),
                                  //           widget.gramValue, widget.isGold)),
                                  // );
                                },
                                child: Container(
                                  width: getWidth1(283),
                                  height: getHeight1(85),
                                  decoration: boxDecoration(
                                      radius: 48, bgColor: colors.secondary2),
                                  child: Center(
                                    child: text("Pay Now",
                                        fontFamily: fontMedium,
                                        fontSize: 22,
                                        textColor: colors.blackTemp),
                                  ),
                                ),
                              ),
                            ]),
                        boxHeight(30),
                      ],
                    ),
                  )),
                )
          : Container(
              height: getHeight(600),
              child: Center(
                child: CircularProgressIndicator(
                  color: MyColorName.primaryDark,
                ),
              ),
            ),

      // bottomNavigationBar: Container(
      //   margin: EdgeInsets.all(20),
      //   child: Row(
      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //     children: [
      //       Expanded(
      //         flex: 1,
      //         child:
      //         InkWell(
      //           onTap: () {
      //             var a = double.parse(totalAmount.toString()) * 100;
      //             RazorPayHelper razorHelper = new RazorPayHelper(
      //                 totalAmount.toString(), context, (result) {
      //               if (result == "error") {
      //                 setState(() {
      //                   saveStatus = true;
      //                 });
      //               } else {
      //                 addOrder();
      //               }
      //             }, App.localStorage.getString("userId").toString(),
      //                 widget.gramValue.toString(), false, true);
      //             razorHelper.init(true, amount: a.toString());
      //           },
      //           child: Container(
      //             height: getHeight1(80),
      //             width: getWidth1(400),
      //             decoration: BoxDecoration(
      //                 borderRadius: BorderRadius.circular(23.0),
      //                 gradient: LinearGradient(
      //                   colors: [Color(0xffF1D459), Color(0xffB27E29)],
      //                   begin: Alignment.topCenter,
      //                   end: Alignment.bottomCenter,
      //                 )),
      //             child: Center(
      //               child: saveStatus
      //                   ? Text(
      //                 "PAYMENT Razor Pay",
      //                 textAlign: TextAlign.center,
      //                 style: TextStyle(
      //                     color: colors.white1,
      //                     fontSize: 15,
      //                     fontWeight: FontWeight.bold),
      //               )
      //                   : CircularProgressIndicator(
      //                 color: MyColorName.colorTextFour,
      //               ),
      //             ),
      //           ),
      //         ),
      //       ),
      //       SizedBox(
      //         width: 16,
      //       ),
      //       Expanded(
      //         flex: 1,
      //         child: isDetailsSHiw ? InkWell(
      //           onTap: () {
      //             orderWithWaleet();
      //           },
      //           child: Container(
      //             height: getHeight1(80),
      //             width: getWidth1(400),
      //             decoration: BoxDecoration(
      //                 borderRadius: BorderRadius.circular(23.0),
      //                 gradient: LinearGradient(
      //                   colors: [Color(0xffF1D459), Color(0xffB27E29)],
      //                   begin: Alignment.topCenter,
      //                   end: Alignment.bottomCenter,
      //                 )),
      //             child: Center(
      //               child: saveStatus
      //                   ? Text(
      //                 "PAYMENT Wallet Pay",
      //                 textAlign: TextAlign.center,
      //                 style: TextStyle(
      //                     color: colors.white1,
      //                     fontSize: 15,
      //                     fontWeight: FontWeight.bold),
      //               )
      //                   : CircularProgressIndicator(
      //                 color: MyColorName.colorTextFour,
      //               ),
      //             ),
      //           ),
      //         ) : InkWell(
      //           onTap: () {
      //             setState(() {
      //               isWaleetUser = true;
      //             });
      //           },
      //           child: Container(
      //             height: getHeight1(80),
      //             width: getWidth1(400),
      //             decoration: BoxDecoration(
      //                 borderRadius: BorderRadius.circular(23.0),
      //                 gradient: LinearGradient(
      //                   colors: [Color(0xffF1D459), Color(0xffB27E29)],
      //                   begin: Alignment.topCenter,
      //                   end: Alignment.bottomCenter,
      //                 )),
      //             child: Center(
      //               child: saveStatusGold
      //                   ? Text(
      //                 "PAYMENT Wallet",
      //                 textAlign: TextAlign.center,
      //                 style: TextStyle(
      //                     color: colors.white1,
      //                     fontSize: 15,
      //                     fontWeight: FontWeight.bold),
      //               )
      //                   : CircularProgressIndicator(
      //                 color: MyColorName.colorTextFour,
      //               ),
      //             ),
      //           ),
      //         ),
      //       )
      //     ],
      //   ),
      // ),
    );
  }

  validarionDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          double screenHeight = MediaQuery.of(context).size.height;
          double paddingValue = screenHeight * 0.2;

          return Padding(
            padding: EdgeInsets.only(top: paddingValue, bottom: paddingValue),
            child: Dialog(
              // title: Text(""),
              child: Container(
                padding:
                    EdgeInsets.only(top: 8, bottom: 15, left: 10, right: 10),
                decoration: BoxDecoration(
                    // color: colors.secondary2
                    ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: Icon(
                                Icons.close,
                                size: 32,
                                color: colors.secondary2,
                              ))
                        ],
                      ),
                    ),
                    Text(
                      "Your Wallet balance is lower than your chosen products weight!",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.black),
                      textAlign: TextAlign.center,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 25.0, bottom: 10),
                      child: Text(
                        'Available in Wallet',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: colors.secondary2),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              '916-Gold: ',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.black),
                            ),
                            Text(
                              '${availeGoldgram.toStringAsFixed(2)} gms',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: colors.secondary2),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              '999-Gold: ',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.black),
                            ),
                            Text(
                              '${availebaleSilveGram.toStringAsFixed(2)} gms',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: colors.secondary2),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Divider(
                      color: colors.secondary2,
                      thickness: 2,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Total gold in cart',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: colors.secondary2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '916-Gold in Cart: ',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).colorScheme.black),
                              ),
                              Text(
                                '${total916Weight.toStringAsFixed(2)} gms',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: colors.secondary2),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '999-Gold in Cart: ',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).colorScheme.black),
                              ),
                              Text(
                                '${total999Weight.toStringAsFixed(2)} gms',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: colors.secondary2),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Spacer(),
                    ElevatedButton(
                      child: Text('OK'),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: colors.secondary2),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  addOrder() async {
    App.init();
    try {
      setState(() {
        saveStatus = false;
      });

      double amount = 0;
      print(amount);
      Map params = {
        "place_order": "1",
        "user_id": App.localStorage.getString("userId").toString(),
        "mobile": App.localStorage.getString("phone").toString(),
        "order_note": controller.text.toString() != ""
            ? controller.text.toString()
            : "No Note",
        "product_variant_id":
            productId.toString().replaceAll("[", "").replaceAll("]", ""),
        "quantity": quantity.toString().replaceAll("[", "").replaceAll("]", ""),
        "total": subTotal.toString(),
        "delivery_charge": deliveryCharge.toString(),
        "latitude": latitude.toString(),
        "longitude": longitude.toString(),
        "tax_amount": '',
        //tax.toString(),
        "tax_percentage": taxPer.toString(),
        "wallet_balance": "0",
        "is_wallet_used": "0",
        "booking_order1": "0",
        "goldwallet_used": "0",
        "silver_wallet_used": "0",
        "wallet_balance_used": "0",
        "address_id": addressId.toString(),
        "final_total": totalAmount.toString(),
        "pro_discount": proDiscount.toString(),
        "payment_method": "Razorpay",
        "delivery_time": selectTime.toString() == ""
            ? "Express Delivery"
            : jsonEncode(selectTime).toString(),
        "accesskey": "90336".toString(),
        "status": "received",
      };
      if (model != null) {
        params['promo_code'] = model!.promo_code.toString();
        params['promo_discount'] =
            voucher.toString() != null ? voucher.toString() : "";
      }
      log("order place without wallet @@@ successful ${params.toString()}");
      print(baseUrl + "place_order");
      Map response =
          await apiBase.postAPICall(Uri.parse(baseUrl + "place_order"), params);

      setState(() {
        saveStatus = true;
      });
      if (!response['error']) {
        navigateScreen(context, OrderConfirmed());
      } else {
        print('${response['message']}_____________sdjkhfkjsf');
        setSnackbar(response['message'], context);
      }
    } on TimeoutException catch (_) {
      setSnackbar("Something Went Wrong", context);
      setState(() {
        saveStatus = true;
      });
    }
  }

  promoCode() {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: boxDecoration(
        radius: 15,
        bgColor: colors.secondary2.withOpacity(0.5),
      ),
      padding: EdgeInsets.symmetric(
          horizontal: getWidth1(16), vertical: getHeight1(21)),
      child: Column(
        children: [
          Container(
              width: getWidth1(622),
              child: text("Applied Promo Code",
                  fontSize: 10.sp, fontFamily: fontRegular)),
          boxHeight(12),
          Container(
            width: getWidth1(500),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    text(model!.promo_code,
                        // textColor: MyColorName.primaryDark,
                        fontSize: 12.sp,
                        fontFamily: fontMedium),
                    text(model!.message,
                        // textColor: MyColorName.primaryDark,
                        fontSize: 8.sp,
                        fontFamily: fontRegular),
                  ],
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      model = null;
                      voucher = null;
                      getTotal();
                    });
                  },
                  child: Container(
                    width: getWidth1(48),
                    height: getWidth1(48),
                    decoration:
                        boxDecoration(radius: 100, bgColor: colors.secondary2),
                    child: Center(
                        child: Icon(
                      Icons.close,
                      size: 20,
                      color: MyColorName.colorTextFour,
                    )),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  priceView() {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: boxDecoration(
        radius: 15,
        bgColor: colors.secondary2.withOpacity(0.5),
      ),
      padding: EdgeInsets.symmetric(
          horizontal: getWidth1(29), vertical: getHeight1(32)),
      child: Column(
        children: [
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     text(
          //       "Total MRP",
          //       fontSize: 10.sp,
          //       fontFamily: fontSemibold,
          //     ),
          //     text(
          //       "₹$totalAmount",
          //       fontSize: 10.sp,
          //       fontFamily: fontBold,
          //     ),
          //   ],
          // ),
          // boxHeight(12),
          total916Weight == 0
              ? SizedBox()
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    text(
                      "Total Gold 916",
                      //(${widget.itemCount} Items)",
                      fontSize: 10.sp,
                      fontFamily: fontRegular,
                    ),
                    text(
                      "$total916Weight grams",
                      fontSize: 10.sp,
                      fontFamily: fontBold,
                    ),
                  ],
                ),
          total999Weight == 0
              ? SizedBox()
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    text(
                      "Total Gold 999",
                      //(${widget.itemCount} Items)",
                      fontSize: 10.sp,
                      fontFamily: fontRegular,
                    ),
                    text(
                      "$total999Weight grams",
                      fontSize: 10.sp,
                      fontFamily: fontBold,
                    ),
                  ],
                ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              text(
                "Sub Total",
                //(${widget.itemCount} Items)",
                fontSize: 10.sp,
                fontFamily: fontRegular,
              ),
              text(
                "₹${amountWithoutTax.toStringAsFixed(2)}",
                fontSize: 10.sp,
                fontFamily: fontBold,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              text(
                "GST(3%)",
                //(${widget.itemCount} Items)",
                fontSize: 10.sp,
                fontFamily: fontRegular,
              ),
              text(
                "+₹${tax.toStringAsFixed(2)}",
                fontSize: 10.sp,
                fontFamily: fontBold,
              ),
            ],
          ),
          /*Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              text(
                "Delivery Charges" ,
                //(${widget.itemCount} Items)",
                fontSize: 10.sp,
                fontFamily: fontRegular,
              ),
              text(
                "+₹${deliveryCharge.toStringAsFixed(2)}",
                fontSize: 10.sp,
                fontFamily: fontBold,
              ),
            ],
          ),*/
          /*Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              text(
                "Total" ,
                  //(${widget.itemCount} Items)",
                fontSize: 10.sp,
                fontFamily: fontRegular,
              ),
              text(
                "₹${subTotal.toStringAsFixed(2)}",
                fontSize: 10.sp,
                fontFamily: fontBold,
              ),
            ],
          ),*/
          voucher != null ? boxHeight(12) : SizedBox(),
          voucher != null
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    text(
                      "Voucher Discount",
                      fontSize: 10.sp,
                      fontFamily: fontRegular,
                    ),
                    text(
                      "-₹$voucher",
                      fontSize: 10.sp,
                      fontFamily: fontBold,
                    ),
                  ],
                )
              : SizedBox(),
          // boxHeight(12),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     text(
          //       "Total grams",
          //       fontSize: 10.sp,
          //       fontFamily: fontRegular,
          //     ),
          //     text(
          //       "${widget.gramValue} gms",
          //       fontSize: 10.sp,
          //       fontFamily: fontBold,
          //     ),
          //   ],
          // ),
          // boxHeight(widget.buyNow == true && size != null ? 12 : 0),
          // widget.buyNow == true && size != null
          //     ? Row(
          //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //         children: [
          //           text(
          //             "Size",
          //             fontSize: 10.sp,
          //             fontFamily: fontRegular,
          //           ),
          //           text(
          //             "$size",
          //             fontSize: 10.sp,
          //             fontFamily: fontBold,
          //           ),
          //         ],
          //       )
          //     : SizedBox(
          //         height: 0,
          //       ),
          // boxHeight(12),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     text(
          //       "Delivery Charges",
          //       fontSize: 10.sp,
          //       fontFamily: fontRegular,
          //     ),
          //     text(
          //       "₹$deliveryCharge",
          //       fontSize: 10.sp,
          //       fontFamily: fontBold,
          //     ),
          //   ],
          // ),
          boxHeight(proDiscount > 0 ? 12 : 0),
          proDiscount > 0
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    text(
                      "Pro Discount",
                      fontSize: 10.sp,
                      fontFamily: fontRegular,
                    ),
                    text(
                      "-₹$proDiscount",
                      fontSize: 10.sp,
                      fontFamily: fontBold,
                    ),
                  ],
                )
              : SizedBox(),
          // boxHeight(12),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     text(
          //       "Tax",
          //       fontSize: 10.sp,
          //       fontFamily: fontRegular,
          //     ),
          //     text(
          //       "₹${tax}",
          //       fontSize: 10.sp,
          //       fontFamily: fontBold,
          //     ),
          //   ],
          // ),
          boxHeight(12),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     text(
          //       "Tax",
          //       fontSize: 10.sp,
          //       fontFamily: fontRegular,
          //     ),
          //     text(
          //       "₹${tax}",
          //       fontSize: 10.sp,
          //       fontFamily: fontBold,
          //     ),
          //   ],
          // ),
          isWallet || isGoldWallet || isSilverWallet
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    text(
                      "Wallet Amount Used",
                      fontSize: 10.sp,
                      fontFamily: fontSemibold,
                    ),
                    text(
                      "-₹${double.parse(choiceAmountController.text.isEmpty ? '0.0' : choiceAmountController.text).toStringAsFixed(2)}",
                      fontSize: 10.sp,
                      fontFamily: fontBold,
                    ),
                  ],
                )
              : SizedBox(
                  height: 0,
                ),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              text(
                "Total Payable Amount",
                fontSize: 10.sp,
                fontFamily: fontSemibold,
              ),
              text(
                choiceAmountController.text.isNotEmpty
                    ? "₹ ${restAmount.toStringAsFixed(2)}"
                    : "₹ ${totalAmount.toStringAsFixed(2)}",
                fontSize: 10.sp,
                fontFamily: fontBold,
              ),
            ],
          ),
        ],
      ),
    );
  }

  paymentMode() {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: boxDecoration(
        radius: 15,
        bgColor: colors.secondary2.withOpacity(0.5),
      ),
      padding: EdgeInsets.symmetric(
          horizontal: getWidth1(29), vertical: getHeight1(20)),
      child: Column(
        children: [
          Container(
            height: 50,
            child: CheckboxListTile(
              title: Text("Wallet : ₹ ${balance.toStringAsFixed(2)}"),
              value: isWallet,
              activeColor: colors.secondary2,
              checkColor: colors.blackTemp,
              onChanged: (value) {
                setState(() {
                  isWallet = value!;
                  isGoldWallet = false;
                  isSilverWallet = false;
                  // _roomController.text = '${item.id}';
                  // print('${_roomController.text}');
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ),
          // widget.isGold == true
          //     ? Container(
          //         height: 50,
          //         child: CheckboxListTile(
          //           title: Text(
          //               "Gold-916 Wallet : ₹ ${goldenWallet.toStringAsFixed(2)}"),
          //           value: isGoldWallet,
          //           activeColor: colors.secondary2,
          //           checkColor: colors.blackTemp,
          //           onChanged: (value) {
          //             setState(() {
          //               isGoldWallet = value!;
          //               isWallet = false;
          //               isSilverWallet = false;
          //               // _roomController.text = '${item.id}';
          //               // print('${_roomController.text}');
          //             });
          //           },
          //           controlAffinity: ListTileControlAffinity.leading,
          //         ),
          //       )
          //     : SizedBox(),
          // widget.isGold == false
          //     ? Container(
          //         height: 50,
          //         child: CheckboxListTile(
          //           title: Text(
          //               "Gold-999 Wallet : ₹ ${silverWallet.toStringAsFixed(2)}"),
          //           value: isSilverWallet,
          //           activeColor: colors.secondary2,
          //           checkColor: colors.blackTemp,
          //           onChanged: (value) {
          //             setState(() {
          //               isSilverWallet = value!;
          //               isWallet = false;
          //               isGoldWallet = false;
          //               // _roomController.text = '${item.id}';
          //               // print('${_roomController.text}');
          //             });
          //           },
          //           controlAffinity: ListTileControlAffinity.leading,
          //         ),
          //       )
          //     : SizedBox(),
          isWallet || isGoldWallet || isSilverWallet
              ? Container(
                  margin: EdgeInsets.all(15),
                  child: TextFormField(
                    controller: choiceAmountController,
                    onFieldSubmitted: (value) {
                      // if (curIndex == null) {
                      //   setSnackbar("Please Select or Add Address", context);
                      //   return;
                      // }
                      restAmount = totalAmount -
                          double.parse(choiceAmountController.text);
                      // addOrderGold(amountPasValue);
                    },
                    autofocus: true,
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      focusColor: Colors.white,
                      // prefixIcon: Icon(
                      //   Icons.person_outline_rounded,
                      //   color: Colors.grey,
                      // ),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.blue, width: 1.0),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      fillColor: Colors.grey,
                      hintText: "₹ Enter amount used from Wallet",
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      labelText: '₹ Enter amount used from Wallet',
                      labelStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                )
              : SizedBox.shrink(),
          // Container(
          //   height: 50,
          //   child: CheckboxListTile(
          //     title: Text("RazorPay"),
          //     value: isRazor,
          //     activeColor: MyColorName.primaryDark,
          //     checkColor: MyColorName.colorTextPrimary,
          //     onChanged: (value) {
          //       setState(() {
          //         isRazor = value!;
          //         // _roomController.text = '${item.id}';
          //         // print('${_roomController.text}');
          //       });
          //     },
          //     controlAffinity: ListTileControlAffinity.leading,
          //   ),
          // )
        ],
      ),
    );
  }

  voucherView() {
    return Container(
      height: getHeight1(144),
      width: MediaQuery.of(context).size.width,
      decoration: boxDecoration(
        radius: 15,
        bgColor: colors.secondary2.withOpacity(0.5),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: getWidth1(16),
      ),
      child: Row(
        children: [
          Image.asset(
            "assets/buydigitalgold/coupon.png",
            width: getWidth1(79),
            height: getHeight1(54),
            fit: BoxFit.fill,
          ),
          boxWidth(20),
          Container(
              child: text("Apply Promocode",
                  fontSize: 12.sp, fontFamily: fontMedium)),
          boxWidth(20),
          InkWell(
            onTap: () async {
              var result = await Navigator.push(context,
                  MaterialPageRoute(builder: (context) => VoucherListView()));
              print(result);
              if (result != null) {
                setState(() {
                  model = null;
                  voucher = null;
                });
                addVoucher(tempTotal, result.promo_code, result);
              }
            },
            child: Container(
              width: getWidth1(160),
              height: getHeight1(55),
              decoration: boxDecoration(radius: 48, bgColor: colors.secondary2),
              child: Center(
                child: text("See All",
                    fontFamily: fontMedium,
                    fontSize: 10.sp,
                    textColor: colors.blackTemp),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool walletStatus = false;

  // ApiBaseHelper apiBase = new ApiBaseHelper();
  // bool isNetwork = false;
  // bool loading = true;
  bool loadingCart = false;
  int? currentIndex;
  List<CartData> cartList = [];
  List<String> productId = [];
  List<double> weight916 = [];
  List<double> weight999 = [];
  double total916Weight = 0;
  double total999Weight = 0;
  List<String> quantity = [];
  List<int> quantity916 = [];
  List<int> quantity999 = [];

  //bool saveStatus = true,
  bool saveStatusSilve = true, saveStatusGold = true;
  UserDetailsModel userDetailsModel = UserDetailsModel();
  double silverWallet = 0.00,
      goldenWallet = 0.00,
      totalBalance = 0.00,
      silverGram = 52.00,
      balance = 0.00,
      goldGram = 5246.96;
  double availeGoldgram = 0.00, availebaleSilveGram = 0.00;
  TextEditingController amountWithDerrwa = TextEditingController();

  void getWallet() async {
    userDetailsModel =
        await userDetails(App.localStorage.getString("userId").toString());
    balance = double.parse(userDetailsModel.data![0].balance.toString());
    if (userDetailsModel != null &&
        userDetailsModel.data![0].silverWallet != null &&
        userDetailsModel.data![0].silverWallet != "") {
      setState(() {
        print(userDetailsModel.data![0].silverWallet.toString());
        availebaleSilveGram =
            double.parse(userDetailsModel.data![0].silverWallet.toString());
        silverWallet =
            double.parse(userDetailsModel.data![0].silverWallet.toString()) *
                silverGram;
      });
    }
    if (userDetailsModel != null &&
        userDetailsModel.data![0].goldWallet != null &&
        userDetailsModel.data![0].goldWallet != "") {
      setState(() {
        print(userDetailsModel.data![0].goldWallet.toString());
        availeGoldgram =
            double.parse(userDetailsModel.data![0].goldWallet.toString());
        goldenWallet =
            double.parse(userDetailsModel.data![0].goldWallet.toString()) *
                goldGram;
      });
    }
    if (userDetailsModel != null &&
        userDetailsModel.data![0].balance != null &&
        userDetailsModel.data![0].balance != "") {
      setState(() {
        print(userDetailsModel.data![0].balance.toString());
        totalBalance =
            double.parse(userDetailsModel.data![0].balance.toString());
      });
    }
  }

  getCart() async {
    try {
      setState(() {
        loadingCart = true;
        cartList.clear();
      });
      Map params = {
        "get_user_cart": "1",
        "user_id": App.localStorage.getString("userId").toString(),
      };
      Map response = await apiBase.postAPICall(
          Uri.parse(baseUrl + "get_user_cart"), params);

      if (!response['error']) {
        for (var v in response['cart_data']) {
          setState(() {
            cartList.add(CartData.fromJson(v));
            // totalCount = cartList.length;
            // grams = cartList[0].
            // productModel?.product![0].weight;
          });
        }
        for (var v in response['cart_data']) {
          setState(() {
            productId.add(v['product_variant_id']);
            quantity.add(v['qty']);
            // tax = response['tax_amount'];
            // tax = response['tax_percentage'];
          });
        }
        weight916 = [];
        weight999 = [];
        quantity999 = [];
        quantity916 = [];
        total916Weight = 0;
        total999Weight = 0;
        for (var i = 0; i < response['cart_data'].length; i++) {
          print('1');
          if (response['cart_data'][i]['product_details'][0]['category_id'] ==
              '54') {
            var weight = response['cart_data'][i]['product_details'][0]
                    ['weight']
                .split('');

            weight916.add(double.parse(weight[0]));
            quantity916.add(int.parse(response['cart_data'][i]['qty']));
            /*for (double num in weight916) {

              total916Weight += num;
            }*/
            print('222222 $total916Weight');
          }
          if (response['cart_data'][i]['product_details'][0]['category_id'] ==
              '55') {
            var weight = response['cart_data'][i]['product_details'][0]
                    ['weight']
                .split(' ');
            weight999.add(double.parse(weight[0]));
            quantity999.add(int.parse(response['cart_data'][i]['qty']));
            /* for (double num in weight999) {
              total999Weight += num;
            }*/
            print('3333 $total999Weight');
          }
          print("this is actual weight $weight916 and $weight999");
          // setState(() {

          //   productId.add(v['product_variant_id']);
          //   quantity.add(v['qty']);
          //   // tax = response['tax_amount'];
          //   // tax = response['tax_percentage'];
          // });
        }
        for (int i = 0; i < weight916.length; i++ /*double num in weight916*/) {
          total916Weight += weight916[i] * quantity916[i];
        }

        for (int i = 0; i < weight999.length; i++ /*double num in weight999*/) {
          total999Weight += weight999[i] * quantity999[i];
        }

        // tax = double.parse(response['tax_amount'].toString());
        // taxPer = double.parse(response['tax_percentage']);
        size = response['cart_data'][0]['size'].toString();

        setState(() {
          loadingCart = false;
        });

        print("****${productId.toString()} && ${quantity.toString()}");
      } else {
        setSnackbar(response['message'], context);
        setState(() {
          loadingCart = false;
        });
      }
    } on TimeoutException catch (_) {
      setSnackbar("Something Went Wrong", context);
      setState(() {
        loading = false;
      });
    }
  }

  bool isWaleetUser = false;

  //String totalAmount = "";

  addOrderGold(double amountPassValue) async {
    print("wallet amount deducted%%%");
    App.init();
    try {
      setState(() {
        saveStatusGold = false;
      });
      var paymentMod;
      if (totalAmount == choiceAmountController.text) {
        paymentMod = "Wallet";
      } else {
        paymentMod = "Wallet & RazorPay";
      }
      print("ok");
      double amount = 0;
      print(amount);
      String? wallet;
      String? walletBalance;
      if (isWallet = true) {
        wallet = "1";
        walletBalance = "${balance.toStringAsFixed(2)}";
      }
      if (isGoldWallet = true) {
        //wallet = "2";
        wallet = "1";
        walletBalance = "${goldenWallet.toStringAsFixed(2)}";
      }
      if (isSilverWallet = true) {
        // wallet = "3";
        wallet = "1";
        walletBalance = "${silverWallet.toStringAsFixed(2)}";
      }
      print(
          "this is ^^^ ${productId.toString()} && ${quantity.toString()} and $wallet and also $walletBalance");
      Map params = {
        "place_order": "1",
        "user_id": App.localStorage.getString("userId").toString(),
        "mobile": App.localStorage.getString("phone").toString(),
        "order_note": "Not Available",
        //  widget.des.toString() != "" ? widget.des.toString() : "No Note",
        "product_variant_id":
            productId.toString().replaceAll("[", "").replaceAll("]", ""),
        "quantity": quantity.toString().replaceAll("[", "").replaceAll("]", ""),
        "total": totalAmount.toString(),
        "delivery_charge": "${deliveryCharge.toString()}",
        "latitude": "${latitude.toString()}",
        "longitude": "${longitude.toString()}",
        "tax_amount": "",
        //"${tax.toString()}",
        "tax_percentage": "3",
        // "${taxPer.toString()}",
        "wallet_balance": walletBalance,
        //widget.isGold ?  "${silverWallet.toStringAsFixed(2)}" : "${goldenWallet.toStringAsFixed(2)}",
        "is_wallet_used": wallet,
        "booking_order1": "0",
        "goldwallet_used": "",
        // widget.isGold == true ? "1" : "",
        //widget.isGold ? "" : "1",
        "silver_wallet_used": "",
        //widget.isGold == false ? "1" : "",
        //widget.isGold == false ? "1" : "",
        //widget.isGold ? "1" : "",
        "wallet_balance_used": choiceAmountController.text != ""
            ? "${choiceAmountController.text}"
            : "",
        "address_id": "${addressId.toString()}",
        "final_total": amountPassValue.toString(),
        //"${choiceAmountController.text.toString()}",
        "pro_discount": "${proDiscount.toString()}",
        "payment_method": "${paymentMod.toString()}",
        "delivery_time": selectTime.toString() == ""
            ? "Express Delivery"
            : jsonEncode(selectTime).toString(),
        "accesskey": "90336".toString(),
        "status": "received",
      };
      if (model != null) {
        params['promo_code'] = model!.promo_code.toString();
        params['promo_discount'] =
            proDiscount.toString() != null ? proDiscount.toString() : "";
      }
      print(" @@ order placed using wallet ${baseUrl}place_order");
      Map response =
          await apiBase.postAPICall(Uri.parse(baseUrl + "place_order"), params);
      print("respnse is ## ${response.entries}");

      setState(() {
        saveStatusGold = true;
      });
      if (!response['error']) {
        setState(() {
          isDetailsSHiw = true;
        });
      } else {
        setSnackbar(response['message'], context);
      }
    } on TimeoutException catch (_) {
      setSnackbar("Something Went Wrong", context);
      setState(() {
        saveStatusGold = true;
      });
    }
  }

/*
  Widget walletAmountDispatch() {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            "Topup wallet",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
        Container(
          margin: EdgeInsets.all(15),
          child: TextFormField(
            controller: choiceAmountController,
            style: TextStyle(
              fontSize: 24,
              color: Colors.blue,
              fontWeight: FontWeight.w600,
            ),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              focusColor: Colors.white,
              prefixIcon: Icon(
                Icons.person_outline_rounded,
                color: Colors.grey,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.blue, width: 1.0),
                borderRadius: BorderRadius.circular(10.0),
              ),
              fillColor: Colors.grey,
              hintText: "₹ Enter Amount",
              hintStyle: TextStyle(
                color: Colors.grey,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              labelText: '₹ Enter Amount',
              labelStyle: TextStyle(
                color: Colors.grey,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
        SizedBox(
          height: 20,
        ),
        GestureDetector(
          onTap: () async {
            var a = double.parse(choiceAmountController.text.toString()) * 100;
            RazorPayHelper razorHelper = new RazorPayHelper(
                a.toString(),
                context,
                (result) {},
                "curUserId",
                "resultGram.toString()",
                false,
                false);
            razorHelper.init(true, amount: a.toString(), addAmointTr: true);
          },
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xffF1D459), Color(0xffB27E29)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(30.0)),
              height: 45,
              width: MediaQuery.of(context).size.width / 2,
              child: Center(
                child: Text(
                  "PROCEED TO TOPUP",
                  style: TextStyle(color: colors.white1, fontSize: 15),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
*/

  bool isDetailsSHiw = false;

  orderWithWaleet() {
    double amountPass = double.parse(choiceAmountController.text);
    double taotlaAmount = double.parse(totalAmount.toString());
    double amountPasValue = (taotlaAmount - amountPass);
    print("wallet !!");
    var a = amountPasValue * 100;
    print(a);
    if (amountPasValue == 0) {
      addOrderGold(taotlaAmount);
    } else {
      print('_______');

      RazorPayHelper razorHelper =
          new RazorPayHelper(totalAmount.toString(), context, (result) {
        /*Future.delayed(Duration(seconds: 3), () {
          addOrderGold(amountPasValue);
        });*/
        if (result == "success") {
          addOrderGold(amountPasValue);
          setState(() {
            saveStatus = true;
          });
        }
        // Future.delayed(Duration(
        //     seconds: 3
        // ),(){
        //   addOrderGold(amountPasValue);
        // });
      },
              App.localStorage.getString("userId").toString(),
              "",
              // widget.gramValue.toString(),
              false,
              true,
              isWalletUset: true);
      razorHelper.initiated(true, amount: a.toString());
      Future.delayed(Duration(seconds: 3), () {
        addOrderGold(amountPasValue);
      });
    }
  }

// priceView() {
//   double amountPass = double.parse(choiceAmountController.text);
//   double taotlaAmount = double.parse(widget.total.toString());
//   double amountPasValue = ( taotlaAmount - amountPass);
//   return Container(
//     width: MediaQuery.of(context).size.width,
//     decoration: boxDecoration(
//       radius: 15,
//       bgColor: MyColorName.colorTextFour.withOpacity(0.3),
//     ),
//     padding: EdgeInsets.symmetric(
//         horizontal: getWidth1(29), vertical: getHeight1(32)),
//     child: Column(
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             text(
//               "Product Total Amount",
//               fontSize: 10.sp,
//               fontFamily: fontRegular,
//             ),
//             text(
//               "₹ ${widget.total.toString()}",
//               fontSize: 10.sp,
//               fontFamily: fontBold,
//             ),
//           ],
//         ),
//         boxHeight(22),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             text(
//               "Wallet Amount used ",
//               fontSize: 10.sp,
//               fontFamily: fontRegular,
//             ),
//             text(
//               "₹ ${choiceAmountController.text}",
//               fontSize: 10.sp,
//               fontFamily: fontBold,
//             ),
//           ],
//         ),
//         boxHeight(22),
//         Divider(),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             text(
//               "Remaining Total",
//               fontSize: 12.sp,
//               fontFamily: fontBold,
//             ),
//             text(
//               "₹$amountPasValue",
//               fontSize: 12.sp,
//               fontFamily: fontBold,
//             ),
//           ],
//         ),
//       ],
//     ),
//   );
// }
  ///
// orderWithWaleet(){
//   double amountPass = double.parse(choiceAmountController.text);
//   double taotlaAmount = double.parse(totalAmount.toString());
//     //  widget.total.toString());
//    amountPasValue = ( taotlaAmount - amountPass);
//
//   var a = amountPasValue * 100;
//   RazorPayHelper razorHelper = new RazorPayHelper(
//       amountPasValue.toString(),
//      // widget.total.toString(),
//
//       context, (result) {
//         print("%% init $result");
//         addOrderGold(amountPasValue);
//     if (result == "error") {
//       setState(() {
//         saveStatus = true;
//       });
//       addOrderGold(amountPasValue);
//     }
//   }, App.localStorage.getString("userId").toString(),
//       widget.gramValue.toString(), false, true,isWalletUset: true);
//   razorHelper.init(true, amount: a.toString());
// }
}
