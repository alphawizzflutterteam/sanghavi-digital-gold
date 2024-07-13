import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:atticadesign/Helper/Color.dart';
import 'package:atticadesign/Helper/kYC.dart';
import 'package:atticadesign/Utils/constant.dart';
import 'package:atticadesign/new_cart.dart';
import 'package:atticadesign/screen/paymentScreen.dart';
import 'package:atticadesign/screen/voucher_list.dart';
import 'package:atticadesign/splash.dart';
import 'package:atticadesign/transaction.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:sizer/sizer.dart';
import 'package:upi_india/upi_india.dart';
import 'package:upi_india/upi_response.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';
// import 'package:toggle_switch/toggle_switch.dart';
import 'Api/api.dart';
import 'Helper/Session.dart';
// import 'Helper/NewCart.dart';
import 'Helper/order _Confirmed.dart';
import 'Model/UserDetailsModel.dart';
import 'Model/pruchaseModel.dart';
import 'Model/voucher_model.dart';
import 'Provider/live_price_provider.dart';
import 'Utils/ApiBaseHelper.dart';
import 'Utils/Common.dart';
import 'Utils/Razorpay.dart';
import 'Utils/colors.dart';
import 'Utils/widget.dart';
import 'buydiditalsilver.dart';
import 'notifications.dart';

class BuyDigitalGold extends StatefulWidget {
  String? goldRate;
  String? gold1Rate;
  BuyDigitalGold({
    this.goldRate,
    this.gold1Rate,
    Key? key}) : super(key: key);

  @override
  State<BuyDigitalGold> createState() => _BuyDigitalGoldState();
}

class _BuyDigitalGoldState extends State<BuyDigitalGold> {
  List categories = ['₹10', '₹20', '₹50', '₹100'];
  List selectedCategories = [];
  var selected = '';
  TextEditingController choiceAmountController = TextEditingController();
  TextEditingController choiceAmountControllerGram = TextEditingController();
  TextEditingController walletAmountController = TextEditingController();

  double resultGram = 0.00 ;
  double taotalPrice = 0.00;
  bool isGold = true;
  double goldRate = 5262.96;
  double silverRate = 63;
  bool isBuyNow = true;
  Razorpay? _razorpay;
  double taxPer = 3;
  double taxAmount = 0;
  double totalAmount = 0 ;
  double totalWithoutWallet = 0 ;
  // String razorPayKey = "rzp_test_CpvP0qcfS4CSJD";
  // String razorPaySecret = "rzp_test_CzVEZjetT2HvfwMDkMfaO6Oq1JD1BpiWuQseSX";
  static const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
  String? _dropDownValue;
  List lista = [
    '999 Gold',
    '916 Gold',
  ];

  Future<UpiResponse>? _transaction;
  UpiIndia _upiIndia = UpiIndia();
  List<UpiApp>? apps;

  TextStyle header = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  TextStyle value = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 14,
  );

Timer? timer ;

  @override
  void initState() {
    _upiIndia.getAllUpiApps(mandatoryTransactionId: false).then((value) {
      setState(() {
        apps = value;
      });
    }).catchError((e) {
      apps = [];
    });
    super.initState();
    _razorpay = Razorpay();
    getWallet();
    goldRate = double.parse(widget.goldRate.toString());
    silverRate = double.parse(widget.gold1Rate.toString());
    getLiveRates();
  }

  getLiveRates(){
    goldRate = double.parse(Provider.of<LivePriceProvider>(context, listen: false).gold1);
    silverRate = double.parse(Provider.of<LivePriceProvider>(context, listen: false).gold2);
    setState(() {});
    timer = Timer.periodic(Duration(minutes: 2), (timer) {
      goldRate = double.parse(Provider.of<LivePriceProvider>(context, listen: false).gold1);
      silverRate = double.parse(Provider.of<LivePriceProvider>(context, listen: false).gold2);
      setState(() {});
    });

  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    timer?.cancel() ;
  }


  Future<UpiResponse> initiateTransaction(UpiApp app) async {
    return _upiIndia.startTransaction(
      app: app,
      receiverUpiId: "setu1104540890799539623@kaypay",
      receiverName: 'sesfs',
      transactionRefId: 'TestingUpiIndiaPlugin',
      transactionNote: 'Not actual. Just an example.',
      amount: 1.00,
    );
  }

  Widget displayUpiApps() {
    if (apps == null)
      return Center(child: CircularProgressIndicator());
    else if (apps!.length == 0)
      return Center(
        child: Text(
          "No apps found to handle transaction.",
          style: header,
        ),
      );
    else
      return Container(
        height: 120,
        child: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Wrap(
              children: apps!.map<Widget>((UpiApp app) {
                return GestureDetector(
                  onTap: () {
                    _transaction = initiateTransaction(app);
                    setState(() {});
                  },
                  child: Container(
                    height: 75,
                    width: 75,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image.memory(
                          app.icon,
                          height: 50,
                          width: 50,
                        ),
                        Text(app.name),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      );
  }


  late WebViewController webViewController;

  var paymentLink;

  Future<void>setupApi()async{
    // print("sssssssssssssss ${amt}");
    // int finalPayment = amt * 100;
    print("checking  final payment");
    var headers = {
      'Cookie': 'ci_session=8a0c2eb916e1d7d7efbd763b1950c0168a951214'
    };
    var request = http.MultipartRequest('POST', Uri.parse('${baseUrl}get_payment_links'));
    request.fields.addAll({
      'amount': '100',
    });
    print("checking params here1111 ${request.fields} and ${baseUrl}get_payment_links");
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var finalResponse = await response.stream.bytesToString();
      final jsonResponse = json.decode(finalResponse);
      print("final response here ${jsonResponse}");
      setState(() {
        paymentLink = jsonResponse['data']['paymentLink']['upiLink'];
      });
      print("ooooooooooo ${paymentLink}");

   //   String url = 'upi://pay?pa=nareshlocal@kaypay&pn=Setu%20Payment%20Links%20Test&am=200.00&tr=875621444531258946&tn=Payment%20for%20918147077472&cu=INR&mode=04';
      // var dd  = html.window.open(paymentLink.toString(), "new tab");
      // print("oookook ${dd}");

      // UpiPayment upiPayment = new UpiPayment('100', context, (value) {
      //   if(value.status==UpiTransactionStatus.success){
      //     Navigator.pop(context);
      //     print("payment status here ");
      //     //placeOrder('',upiResponse: value);
      //   }else{
      //     Fluttertoast.showToast(msg: "Payment Failed");
      //   }
      // });
      // upiPayment.initPayment();
      print("checking launch here ${canLaunchUrl(paymentLink)}");
      if(await canLaunch(paymentLink)){
        print("checking link here ${paymentLink}");
        await launch(paymentLink,forceWebView: false);
      }else {
        throw 'Could not launch $paymentLink';
      }
      print("checking upi link here ${paymentLink}");
    }
    else {
      print(response.reasonPhrase);
    }
  }

  UserDetailsModel userDetailsModel = UserDetailsModel();
  double silverWallet = 0.00,
      goldenWallet = 0.00,
      totalBalance = 0.00;

  double availeGoldgram = 0.00, availebaleSilveGram = 0.00;

  void getWallet() async {
    userDetailsModel =
    await userDetails(App.localStorage.getString("userId").toString());
    if (userDetailsModel != null &&
        userDetailsModel.data![0].silverWallet != null &&
        userDetailsModel.data![0].silverWallet != "") {
      setState(() {
        print(userDetailsModel.data![0].silverWallet.toString());
        availebaleSilveGram =
            double.parse(userDetailsModel.data![0].silverWallet.toString());
        silverWallet =
            double.parse(userDetailsModel.data![0].silverWallet.toString()) *
                silverRate;
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
                goldRate;
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

  String payMethod = 'razorPay';

var balance = 0.0;
  bool isWallet = false;
  bool isGoldWallet = false;
  bool isSilverWallet = false;
  double  restAmount= 0;

  ///for timer
  Function? bottomSheetState ;
  int timerValue =  59;


  // priceView() {
  //   return Container(
  //     width: getWidth1(624),
  //     decoration: boxDecoration(
  //       radius: 15,
  //       bgColor: colors.secondary2.withOpacity(0.3),
  //     ),
  //     padding: EdgeInsets.symmetric(
  //         horizontal: getWidth1(29), vertical: getHeight1(32)),
  //     child: Column(
  //       children: [
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             text(
  //               "Total MRP",
  //               fontSize: 10.sp,
  //               fontFamily: fontSemibold,
  //             ),
  //             text(
  //               "₹$totalAmount",
  //               fontSize: 10.sp,
  //               fontFamily: fontBold,
  //             ),
  //           ],
  //         ),
  //         boxHeight(12),
  //
  //         voucher != null ? boxHeight(12) : SizedBox(),
  //         voucher != null
  //             ? Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             text(
  //               "Voucher Discount",
  //               fontSize: 10.sp,
  //               fontFamily: fontRegular,
  //             ),
  //             text(
  //               "-₹$voucher",
  //               fontSize: 10.sp,
  //               fontFamily: fontBold,
  //             ),
  //           ],
  //         )
  //             : SizedBox(),
  //
  //
  //         boxHeight(proDiscount > 0 ? 12 : 0),
  //         proDiscount > 0
  //             ? Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             text(
  //               "Pro Discount",
  //               fontSize: 10.sp,
  //               fontFamily: fontRegular,
  //             ),
  //             text(
  //               "-₹$proDiscount",
  //               fontSize: 10.sp,
  //               fontFamily: fontBold,
  //             ),
  //           ],
  //         )
  //             : SizedBox(),
  //
  //         boxHeight(12),
  //         // Row(
  //         //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         //   children: [
  //         //     text(
  //         //       "Tax",
  //         //       fontSize: 10.sp,
  //         //       fontFamily: fontRegular,
  //         //     ),
  //         //     text(
  //         //       "₹${tax}",
  //         //       fontSize: 10.sp,
  //         //       fontFamily: fontBold,
  //         //     ),
  //         //   ],
  //         // ),
  //         isWallet || isGoldWallet || isSilverWallet ?
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             text(
  //               "Wallet Amount Used",
  //               fontSize: 10.sp,
  //               fontFamily: fontSemibold,
  //             ),
  //             text(
  //               "-₹${choiceAmountController.text}",
  //               fontSize: 10.sp,
  //               fontFamily: fontBold,
  //             ),
  //           ],
  //         )
  //             : SizedBox(height: 0,),
  //         Divider(),
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             text(
  //               "Total Amount",
  //               fontSize: 10.sp,
  //               fontFamily: fontSemibold,
  //             ),
  //
  //             text(
  //               choiceAmountController.text.isNotEmpty ?
  //               "₹ $restAmount"
  //                   : "₹ $totalAmount",
  //               fontSize: 10.sp,
  //               fontFamily: fontBold,
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

  paymentMode() {
    return Container(
      width: getWidth1(640),
      decoration: boxDecoration(
        radius: 15,
        bgColor: colors.secondary2.withOpacity(0.3),
      ),
      padding: EdgeInsets.symmetric(
          horizontal: getWidth1(29), vertical: getHeight1(20)),
      child: Column(
        children: [
          Container(
            height: 50,
            child: CheckboxListTile(
              title: Text("Wallet : ₹ ${totalBalance.toStringAsFixed(2)}"),
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
          // isGold == true?
          // Container(
          //   height: 50,
          //   child: CheckboxListTile(
          //     title: Text("Gold-916 Wallet : ₹ ${goldenWallet.toStringAsFixed(2)}"),
          //     value: isGoldWallet,
          //     activeColor: colors.secondary2,
          //     checkColor: colors.blackTemp,
          //     onChanged: (value) {
          //       setState(() {
          //         isGoldWallet = value!;
          //         isWallet = false;
          //         isSilverWallet = false;
          //         // _roomController.text = '${item.id}';
          //         // print('${_roomController.text}');
          //       });
          //     },
          //     controlAffinity: ListTileControlAffinity.leading,
          //   ),
          // )
          //     : SizedBox(),
          // isGold == false ?
          // Container(
          //   height: 50,
          //   child: CheckboxListTile(
          //     title: Text("Gold-999 Wallet : ₹ ${silverWallet.toStringAsFixed(2)}"),
          //     value: isSilverWallet,
          //     activeColor: colors.secondary2,
          //     checkColor: colors.blackTemp,
          //     onChanged: (value) {
          //       setState(() {
          //         isSilverWallet = value!;
          //         isWallet = false;
          //         isGoldWallet = false;
          //         // _roomController.text = '${item.id}';
          //         // print('${_roomController.text}');
          //       });
          //     },
          //     controlAffinity: ListTileControlAffinity.leading,
          //   ),
          // )
          //     : SizedBox(),
          isWallet ?
          Container(
            margin: EdgeInsets.all(15),
            child: TextFormField(
              controller: walletAmountController,
              onFieldSubmitted: (value){
                // if (curIndex == null) {
                //   setSnackbar("Please Select or Add Address", context);
                //   return;
                // }
                restAmount = totalAmount - double.parse(walletAmountController.text);
                // addOrderGold(amountPasValue);
                print("rest amount here and total amount here as well ${restAmount} and ${totalAmount}");
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
                  borderSide: const BorderSide(
                      color: Colors.blue, width: 1.0),
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

  @override
  Widget build(BuildContext context) {
   // getWallet();
    return Scaffold(
      // backgroundColor: colors.bgColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: colors.primaryNew,
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
           "Buy Digital Gold" ,
          style: TextStyle(
            color: colors.whiteTemp,
            fontSize: 18,
          ),
        ),
        actions: [
          Row(
            children: [
              InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => NewCart()),
                    );
                  },
                  child: Icon(Icons.shopping_cart_rounded,
                      color:colors.secondary2)),
              SizedBox(
                width: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(right: 15.0),
                child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => NotiPage()),
                      );
                    },
                    child: Icon(Icons.notifications_active,
                        color:colors.secondary2)),
              ),
            ],
          )
        ],
      ),
      body: SingleChildScrollView(
        // scrollDirection: Axis.vertical,
        child: Column(
          children: [
           /* Padding(
              padding: EdgeInsets.only(top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: 10.0, left: 15.0),
                      child: Container(
                        height: 50,
                        //  width: 150,
                        decoration: BoxDecoration(
                          color: isGold
                              ? Colors.green
                              : Colors.grey,
                          border: Border.all(
                              color: isGold
                                  ? Colors.green
                                  : Colors.black12),
                          borderRadius: BorderRadius.all(
                              Radius.circular(7.0) //
                          ),
                        ),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              isBuyNow = true;
                              isGold = !isGold;
                              choiceAmountControllerGram.clear();
                              choiceAmountController.clear();
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(left: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Image.asset(
                                  'assets/homepage/gold.png',
                                  height: 30,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  'Gold-916',
                                  style: TextStyle(
                                    color: isGold ? Colors.white :Color(0xff0C3B2E),
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10.0, right: 15),
                      child: Container(
                        height: 50,
                        // width: 150,
                        decoration: BoxDecoration(
                          color: !isGold
                              ? Colors.green
                              : Colors.grey,
                          border: Border.all(
                              color: !isGold
                                  ? Colors.green
                                  : Colors.black12),
                          borderRadius: BorderRadius.all(
                              Radius.circular(7.0) //
                          ),
                        ),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              isBuyNow = true;
                              isGold = !isGold;
                              choiceAmountControllerGram.clear();
                              choiceAmountController.clear();
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Image.asset(
                                  'assets/homepage/gold.png',
                                  // 'assets/homepage/silverbrick.png',
                                  height: 30,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  'Gold-999',
                                  style: TextStyle(
                                    color: !isGold ? Colors.white : Color(0xff0C3B2E),
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),*/
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(top: 10.0, left: 15.0),
                        child: Container(
                          height: 50,
                          width: 150,
                          decoration: BoxDecoration(
                            color: isGold
                                ? Colors.green
                                : Colors.grey,
                            border: Border.all(
                                color: isGold
                                    ? Colors.green
                                    : Colors.black12),
                            borderRadius: BorderRadius.all(
                                Radius.circular(7.0) //
                            ),
                          ),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                isBuyNow = true;
                                isGold = !isGold;
                                choiceAmountControllerGram.clear();
                                choiceAmountController.clear();
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(left: 15),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Image.asset(
                                    'assets/homepage/gold.png',
                                    height: 30,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    'Gold-916',
                                    style: TextStyle(
                                      color: isGold ? Colors.white :Color(0xff0C1723),
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10.0, right: 15),
                        child: Container(
                          height: 50,
                          width: 150,
                          decoration: BoxDecoration(
                            color: !isGold
                                ? Colors.green
                                : Colors.grey,
                            border: Border.all(
                                color: !isGold
                                    ? Colors.green
                                    : Colors.black12),
                            borderRadius: BorderRadius.all(
                                Radius.circular(7.0) //
                            ),
                          ),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                isBuyNow = true;
                                isGold = !isGold;
                                choiceAmountControllerGram.clear();
                                choiceAmountController.clear();
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Image.asset(
                                    'assets/homepage/gold.png',
                                    height: 30,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    'Gold-999',
                                    style: TextStyle(
                                      color: !isGold ? Colors.white : Color(0xff0C1723),
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            SizedBox(
              height: 15,
            ),
            Container(
              //height: 270,
              width: double.infinity,
              clipBehavior: Clip.antiAlias,
              margin: EdgeInsets.symmetric(horizontal: 16),
              padding: EdgeInsets.only(left: 8, right: 8),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                  color: colors.whiteTemp,
                  image: DecorationImage(
                    image: AssetImage(
                      //isGold ?
                        "assets/homepage/coinback1.png"
                    ),fit: BoxFit.cover
                    //: "assets/homepage/silver.png") ,
                  )),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            /*bottom: 10.0,*/ left: 20, top: 15),
                        child: Text(
                          'Current digital gold Rates',
                           //   '${isGold ? "Gold-916" : "Gold-999"} \nnow',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),

                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0, right: 0, bottom: 60,top: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        isGold ? Text(
                          'Gold-916 Rate\n₹ ${goldRate.toStringAsFixed(2)}/gram',
                          //   '${isGold ? "Gold-916" : "Gold-999"} \nnow',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ) : Text(
                          'Gold-999 Rate\n₹ ${silverRate.toStringAsFixed(2)}/gram',
                          //   '${isGold ? "Gold-916" : "Gold-999"} \nnow',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),

                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(left: 15.0, right: 15,bottom: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [

                       isGold ? Expanded(
                         flex: 1,
                         child: Text(

                                // isGold ?
                            "Total Gold-916 \n${availeGoldgram.toStringAsFixed(2)} gms "//(₹ ${goldenWallet.toStringAsFixed(2).toString()})
                             ,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color:colors.white1,
                              fontWeight: FontWeight.normal,
                              fontSize: 14,
                            ),
                          ),
                       ) : Expanded(
                         flex: 1,
                         child: Text(
                           "Total Gold-999 \n${availebaleSilveGram.toStringAsFixed(2)} gms ",//(₹ ${silverWallet.toStringAsFixed(2).toString()})
                           // 'Total ${isGold ? "Gold-916" : "Gold-999"} Wallet : '
                           //     '${isGold && goldenWallet > 1 ?
                           // "${availeGoldgram.toStringAsFixed(2)} gms \n(₹ ${goldenWallet.toStringAsFixed(2).toString()})"
                           //     :
                           // silverWallet > 1 ? "${availebaleSilveGram.toStringAsFixed(2)} gms \n(₹ ${silverWallet.toStringAsFixed(2).toString()})"
                           //     : "0.00 gms \n(₹ 0.00)"}',
                           textAlign: TextAlign.center,
                           style: TextStyle(
                             color:colors.white1,
                             fontWeight: FontWeight.normal,
                             fontSize: 14,
                           ),
                         ),
                       ),
                        Expanded(
                          flex: 1,
                          child: InkWell(
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context)=> Transaction(index: isGold ? 1 :2 ,))).then((value) {
                                getLiveRates();
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.all(10),
                              //height: 30,
                             // width: MediaQuery.of(context).size.width/2,
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Color(0xffF1D459).withOpacity(0.8), Color(0xffB27E29).withOpacity(0.8)],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                  borderRadius: BorderRadius.circular(15.0)
                              ),
                              child: Center(child: Text("View Transactions",textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.w500),)),
                            ),
                          ),
                        ),
                        /*Container(
                          height: 60,
                          child: VerticalDivider(
                            thickness: 1,
                            color: colors.white1,
                          ),
                        ),*/

                      ],
                    ),
                  ),

                ],
              ),
            ),

            /*Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: InkWell(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> Transaction()));
                },
                child: Container(
                  height: 40,
                  width: MediaQuery.of(context).size.width/2,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xffF1D459).withOpacity(0.8), Color(0xffB27E29).withOpacity(0.8)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(15.0)
                  ),
                  child: Center(child: Text("View Transactions",
                    style: TextStyle(fontWeight: FontWeight.w500),)),
                ),
              ),
            ),*/
            SizedBox(height: 25,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'How much you want to buy?',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.black,
                      // colors.black54.withOpacity(1),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),

                ],
              ),
            ),


            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6),
                    child: Container(
                      height: 50,
                      margin: EdgeInsets.all(12),
                      child: TextFormField(
                        controller: choiceAmountController,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            var reate = isGold ? goldRate : silverRate;
                            resultGram = double.parse(value) / reate;
                            choiceAmountControllerGram.text =
                                resultGram.toStringAsFixed(6).toString();
                            taxAmount = (double.parse(value)* (taxPer/100));
                            totalAmount = double.parse(value) + taxAmount;
                            print("checing amount controller ${totalAmount}");
                            voucher =0;
                            proDiscount=0;
                            // if(voucher != null){
                            //   totalAmount = totalAmount - double.parse(voucher!.toStringAsFixed(2));
                            // }
                          } else {
                            choiceAmountControllerGram.clear();
                          }
                        },
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          focusColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors.blue, width: 1.0),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          fillColor: Colors.grey,
                          hintText: "₹ Amount",
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
                  ),
                ),
                Icon(Icons.compare_arrows,
                    color: Theme.of(context).colorScheme.black, size: 30),
                Expanded(
                  flex: 1,
                  child: Container(
                    height: 50,
                    margin: EdgeInsets.all(8),
                    child: TextFormField(
                      controller: choiceAmountControllerGram,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                      ),

                      onChanged: (value) {
                        double a = isGold ? goldRate : silverRate;
                        taotalPrice = double.parse(value.isEmpty ? '0.0' :value) * a;

                        if (value.isNotEmpty) {

                          choiceAmountController.text =
                              taotalPrice.toStringAsFixed(2).toString();
                          resultGram = double.parse(choiceAmountControllerGram.text.toString());
                          taxAmount = (taotalPrice* (taxPer/100));
                          totalAmount = taotalPrice + taxAmount;
                          print("this is total 1234 $totalAmount");
                          voucher =0;
                          proDiscount = 0;
                        } else {
                          taotalPrice = 0.00;
                          choiceAmountController.clear() ;
                          print(choiceAmountController.text);
                        }
                      },
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        focusColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: Colors.blue, width: 1.0),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        fillColor: Colors.grey,
                        hintText: "Gram",
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                        labelText: 'Enter Gram',
                        labelStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Row(
            //   children: [
            //     Expanded(
            //       flex: 1,
            //       child: Container(
            //         margin: EdgeInsets.all(15),
            //         child: TextFormField(
            //           controller: choiceAmountController,
            //           style: TextStyle(
            //             fontSize: 24,
            //             color: Colors.blue,
            //             fontWeight: FontWeight.w600,
            //           ),
            //           onChanged: (value){
            //             double abcs =  isGold ? goldRate :silverRate;
            //             if(value.isNotEmpty){
            //               resultGram = int.parse(value) / abcs;
            //               isGold = true;
            //               choiceAmountControllerGram.text = resultGram.toStringAsFixed(2).toString();
            //             }else{
            //               choiceAmountControllerGram.clear();
            //               isGold = false;
            //             }
            //             setState(() {});
            //           },
            //       /*    onFieldSubmitted: (value) {
            //             double abcs =  isGold ? goldRate :silverRate;
            //             resultGram = int.parse(value) / abcs;
            //             if(value.isNotEmpty){
            //               isGold = true;
            //               choiceAmountControllerGram.text = resultGram.toStringAsFixed(2).toString();
            //             }else{
            //               isGold = false;
            //             }
            //             setState(() {});
            //           },*/
            //
            //           keyboardType: TextInputType.number,
            //           decoration: InputDecoration(
            //             focusColor: Colors.white,
            //             border: OutlineInputBorder(
            //               borderRadius: BorderRadius.circular(10.0),
            //             ),
            //
            //             focusedBorder: OutlineInputBorder(
            //               borderSide: const BorderSide(
            //                   color: Colors.blue, width: 1.0),
            //               borderRadius: BorderRadius.circular(10.0),
            //             ),
            //             fillColor: Colors.grey,
            //             hintText: "₹ Amount",
            //             hintStyle: TextStyle(
            //               color: Colors.grey,
            //               fontSize: 16,
            //               fontWeight: FontWeight.w400,
            //             ),
            //
            //             labelText: '₹ Enter Amount',
            //             labelStyle: TextStyle(
            //               color: Colors.grey,
            //               fontSize: 16,
            //               fontWeight: FontWeight.w400,
            //             ),
            //           ),
            //         ),
            //       ),
            //     ),
            //     SizedBox(
            //       child: Icon(Icons.compare_arrows, color: Colors.white, size: 35),
            //       width: 35,
            //     ),
            //     Expanded(
            //       flex: 1,
            //       child: Container(
            //         margin: EdgeInsets.all(15),
            //         child: TextFormField(
            //           controller: choiceAmountControllerGram,
            //           style: TextStyle(
            //             fontSize: 24,
            //             color: Colors.blue,
            //             fontWeight: FontWeight.w600,
            //           ),
            //           onChanged: (value){
            //             if(value.isNotEmpty){
            //               double abc= isGold ? goldRate : silverRate;
            //               taotalPrice = int.parse(value) * abc;
            //               choiceAmountController.text = taotalPrice.toStringAsFixed(2).toString();
            //               isGold = false;
            //             }else{
            //               taotalPrice =0.00;
            //               isGold = true;
            //               choiceAmountController.clear();
            //             }
            //             setState(() {});
            //           },
            //           keyboardType: TextInputType.number,
            //           decoration: InputDecoration(
            //             focusColor: Colors.white,
            //             border: OutlineInputBorder(
            //               borderRadius: BorderRadius.circular(10.0),
            //             ),
            //             focusedBorder: OutlineInputBorder(
            //               borderSide: const BorderSide(
            //                   color: Colors.blue, width: 1.0),
            //               borderRadius: BorderRadius.circular(10.0),
            //             ),
            //             fillColor: Colors.grey,
            //             hintText: "Gram",
            //             hintStyle: TextStyle(
            //               color: Colors.grey,
            //               fontSize: 16,
            //               fontWeight: FontWeight.w400,
            //             ),
            //
            //             labelText: 'Enter Gram',
            //             labelStyle: TextStyle(
            //               color: Colors.grey,
            //               fontSize: 16,
            //               fontWeight: FontWeight.w400,
            //             ),
            //           ),
            //         ),
            //       ),
            //     ),
            //   ],
            // ),

            // SizedBox(
            //   height: 10,
            // ),
            // // Padding(
            // //   padding: const EdgeInsets.only(left: 10.0, right: 10),
            // //   child: Padding(
            // //     padding: const EdgeInsets.only(right: 120.0),
            // //     child: Text(
            // //       'You can Buy up to 1000 per day',
            // //       style: TextStyle(
            // //         color: colors.blackTemp,
            // //         fontWeight: FontWeight.bold,
            // //         fontSize: 15,
            // //       ),
            // //     ),
            // //   ),
            // // ),
            // // SizedBox(
            // //   height: 10,
            // // ),
            // //
            // // voucherView(),
            // SizedBox(
            //   height: 10,
            // ),
            const SizedBox(height: 20,),
            voucherView(),
            voucher !=null && voucher !=0.0 ? Text('*Congratulations! you saved ₹ ${voucher} on final amount') : SizedBox(),

            Padding(
              padding: const EdgeInsets.only(top: 20.0, bottom: 20),
              child: InkWell(
                onTap: (){
                  walletAmountController.clear();
                  if(choiceAmountControllerGram.text.isNotEmpty) {
                    totalWithoutWallet = double.parse(choiceAmountController.text)+ taxAmount;
                    if(proDiscount > 0 && voucher != null){
                      totalWithoutWallet-= voucher! ;
                    }
                    timerValue = 59 ;
                    showModalBottomSheet(
                        isScrollControlled: true,
                        context: context,
                        builder: (context) {
                          return StatefulBuilder(
                              builder: (context, setState) {
                                bottomSheetState = setState ;
                                return Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(15),
                                          topRight: Radius.circular(15))
                                  ),
                                  height: MediaQuery
                                      .of(context)
                                      .size
                                      .height * 0.90,
                                  child: SingleChildScrollView(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Select Wallet',
                                                style: TextStyle(
                                                  color: Theme.of(context).colorScheme.black,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                ),
                                              ),
                                              Text(
                                                '00:${timerValue}',
                                                style: TextStyle(
                                                  color: Theme.of(context).colorScheme.black,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                ),
                                              ),

                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: getWidth1(640),
                                          decoration: boxDecoration(
                                            radius: 15,
                                            bgColor: colors.secondary2.withOpacity(0.3),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: getWidth1(29), vertical: getHeight1(20)),
                                          child: Column(
                                            children: [
                                              Container(
                                                height: 50,
                                                child: CheckboxListTile(
                                                  title: Text("Wallet : ₹ ${totalBalance.toStringAsFixed(2)}"),
                                                  value: isWallet,
                                                  activeColor: colors.secondary2,
                                                  checkColor: colors.blackTemp,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      isWallet = value!;
                                                      isGoldWallet = false;
                                                      isSilverWallet = false;
                                                      if(isWallet && totalBalance >=  totalAmount){
                                                        walletAmountController.text = totalAmount.toString() ;
                                                        restAmount = totalAmount - double.parse(walletAmountController.text);
                                                      }else {
                                                        walletAmountController.text = '';
                                                        restAmount = 0 ;
                                                      }
                                                      // _roomController.text = '${item.id}';
                                                      // print('${_roomController.text}');
                                                    });
                                                  },
                                                  controlAffinity: ListTileControlAffinity.leading,
                                                ),
                                              ),
                                              // isGold == true?
                                              // Container(
                                              //   height: 50,
                                              //   child: CheckboxListTile(
                                              //     title: Text("Gold-916 Wallet : ₹ ${goldenWallet.toStringAsFixed(2)}"),
                                              //     value: isGoldWallet,
                                              //     activeColor: colors.secondary2,
                                              //     checkColor: colors.blackTemp,
                                              //     onChanged: (value) {
                                              //       setState(() {
                                              //         isGoldWallet = value!;
                                              //         isWallet = false;
                                              //         isSilverWallet = false;
                                              //         // _roomController.text = '${item.id}';
                                              //         // print('${_roomController.text}');
                                              //       });
                                              //     },
                                              //     controlAffinity: ListTileControlAffinity.leading,
                                              //   ),
                                              // )
                                              //     : SizedBox(),
                                              // isGold == false ?
                                              // Container(
                                              //   height: 50,
                                              //   child: CheckboxListTile(
                                              //     title: Text("Gold-999 Wallet : ₹ ${silverWallet.toStringAsFixed(2)}"),
                                              //     value: isSilverWallet,
                                              //     activeColor: colors.secondary2,
                                              //     checkColor: colors.blackTemp,
                                              //     onChanged: (value) {
                                              //       setState(() {
                                              //         isSilverWallet = value!;
                                              //         isWallet = false;
                                              //         isGoldWallet = false;
                                              //         // _roomController.text = '${item.id}';
                                              //         // print('${_roomController.text}');
                                              //       });
                                              //     },
                                              //     controlAffinity: ListTileControlAffinity.leading,
                                              //   ),
                                              // )
                                              //     : SizedBox(),
                                              isWallet ?
                                              Container(
                                                margin: EdgeInsets.all(15),
                                                child: TextFormField(
                                                  controller: walletAmountController,

                                                  onChanged: (value){
                                                    restAmount = totalAmount - double.parse(walletAmountController.text.isEmpty ? '0.0' :walletAmountController.text);
                                                    if(restAmount < 0){
                                                      restAmount = 0 ;
                                                    }
                                                    setState((){

                                                    });
                                                  },
                                                  onFieldSubmitted: (value){
                                                    // if (curIndex == null) {
                                                    //   setSnackbar("Please Select or Add Address", context);
                                                    //   return;
                                                    // }
                                                    restAmount = totalAmount - double.parse(walletAmountController.text.isEmpty ? '0.0' :walletAmountController.text );
                                                    // addOrderGold(amountPasValue);
                                                    print("rest amount here and total amount here as well ${restAmount} and ${totalAmount}");
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
                                                      borderSide: const BorderSide(
                                                          color: Colors.blue, width: 1.0),
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
                                        ),
                                        // paymentMode(),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 10),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment
                                                .center,
                                            children: [
                                              Text(
                                                'Order Summary',
                                                style: TextStyle(
                                                 color: Theme.of(context).colorScheme.black,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                ),
                                              ),

                                            ],
                                          ),
                                        ),
                                        choiceAmountController.text.isNotEmpty ?
                                        buySummary()
                                            : SizedBox(),
                                        choiceAmountController.text.isEmpty
                                            ? SizedBox
                                            .shrink()
                                            : isWallet && restAmount <= 0 ? SizedBox() : Container(
                                          margin: EdgeInsets.only(top: 10),
                                          child: Column(
                                            children: [
                                              SizedBox(height: 20,),
                                              Text("Select payment method",
                                                style: TextStyle(
                                                    color: Theme.of(context).colorScheme.black,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 15),),
                                              RadioListTile(
                                                title: Text("RazorPay"),
                                                value: "razorPay",
                                                groupValue: payMethod,
                                                onChanged: (value) {
                                                  setState(() {
                                                    payMethod = value.toString();
                                                  });
                                                  print(
                                                      "paymethod here ${payMethod}");
                                                },
                                              ),

                                              RadioListTile(
                                                title: Text("Setu"),
                                                value: "setu",
                                                groupValue: payMethod,
                                                onChanged: (value) {
                                                  setState(() {
                                                    payMethod = value.toString();
                                                  });

                                                  print(
                                                      "paymethod here ${payMethod}");
                                                },
                                              ),

                                              // Container(
                                              //   child: Row(
                                              //     children: [
                                              //       Container(
                                              //         child: Cont,
                                              //       ),
                                              //
                                              //     ],
                                              //   ),
                                              // )
                                            ],
                                          ),
                                        ),


                                        payMethod == "razorPay" ? GestureDetector(
                                          onTap: () {
                                            if (totalAmount > 100000) {
                                              showDialog(
                                                  context: context,
                                                  // barrierDismissible: false,
                                                  builder: (
                                                      BuildContext context) {
                                                    return AlertDialog(
                                                      backgroundColor: colors
                                                          .secondary2,
                                                      title: Text("KYC",
                                                        style: TextStyle(
                                                            fontWeight: FontWeight
                                                                .bold
                                                        ),),
                                                      content: Text(
                                                        "You need to update KYC to buy digital gold worth more than 1 Lacs",
                                                        style: TextStyle(
                                                            fontSize: 14
                                                        ),),

                                                      actions: <Widget>[
                                                        InkWell(
                                                          onTap: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child: Container(
                                                            height: 40,
                                                            width: 100,
                                                            decoration: BoxDecoration(
                                                              borderRadius: BorderRadius
                                                                  .circular(20.0),
                                                              gradient: LinearGradient(
                                                                  colors: [
                                                                    colors
                                                                        .black54,
                                                                    colors
                                                                        .blackTemp,
                                                                  ],
                                                                  begin: Alignment
                                                                      .topCenter,
                                                                  end: Alignment
                                                                      .bottomCenter),
                                                            ),
                                                            child: Center(
                                                                child: Text(
                                                                  "No",
                                                                  style: TextStyle(
                                                                      color: colors
                                                                          .secondary2),
                                                                )),
                                                          ),
                                                        ),
                                                        InkWell(
                                                          onTap: () async {
                                                            var result = await Navigator
                                                                .push(context,
                                                                MaterialPageRoute(
                                                                    builder: (
                                                                        context) =>
                                                                        KYC()));
                                                            // Navigator.pop(context);
                                                            if (result == true) {
                                                              Navigator.pop(
                                                                  context);
                                                              doPayment();
                                                            }
                                                          },
                                                          child: Container(
                                                            height: 40,
                                                            width: 100,
                                                            decoration: BoxDecoration(
                                                              borderRadius: BorderRadius
                                                                  .circular(20.0),
                                                              gradient: LinearGradient(
                                                                  colors: [
                                                                    colors
                                                                        .black54,
                                                                    colors
                                                                        .blackTemp,
                                                                  ],
                                                                  begin: Alignment
                                                                      .topCenter,
                                                                  end: Alignment
                                                                      .bottomCenter),
                                                            ),
                                                            child: Center(
                                                                child: Text(
                                                                  "Yes",
                                                                  style: TextStyle(
                                                                      color: colors
                                                                          .secondary2),
                                                                )),
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  });
                                            } else {
                                              if (choiceAmountController.text
                                                  .isNotEmpty) {
                                                if (choiceAmountController.text
                                                    .isNotEmpty
                                                    || resultGram
                                                        .toString()
                                                        .isNotEmpty
                                                    || choiceAmountControllerGram
                                                        .text
                                                        .isNotEmpty) {

                                                  if(isWallet && restAmount <= 0){
                                                    purchaseGoldWhenTotalZero();
                                                  }else {
                                                    doPayment();
                                                  }

                                                }
                                              } else {
                                                Fluttertoast.showToast(
                                                    msg: "Please Enter amount or grams!!");
                                              }
                                            }
                                          },
                                          child: Container(
                                            margin: EdgeInsets.only(top: 10),
                                            height: 40,
                                            width: 250,
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(30)),
                                                gradient: LinearGradient(colors: [
                                                  isBuyNow
                                                      ? colors.secondary2
                                                      : Colors
                                                      .grey,
                                                  isBuyNow
                                                      ? Color(0xffB27E29)
                                                      : Colors
                                                      .black12,
                                                ])),
                                            child: Center(
                                              child: Text(
                                                'BUY NOW',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold
                                                ),
                                              ),
                                            ),
                                          ),
                                        ) :
                                        GestureDetector(
                                          onTap: () async {
                                            print("setu api here");
                                            if (totalAmount > 100000) {
                                              showDialog(
                                                  context: context,
                                                  // barrierDismissible: false,
                                                  builder: (BuildContext context) {
                                                    return AlertDialog(
                                                      backgroundColor: colors
                                                          .secondary2,
                                                      title: Text("KYC",
                                                        style: TextStyle(
                                                            fontWeight: FontWeight
                                                                .bold
                                                        ),),
                                                      content: Text(
                                                        "You need to update KYC to buy digital gold worth more than 1 Lacs",
                                                        style: TextStyle(
                                                            fontSize: 14
                                                        ),),

                                                      actions: <Widget>[
                                                        InkWell(
                                                          onTap: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child: Container(
                                                            height: 40,
                                                            width: 100,
                                                            decoration: BoxDecoration(
                                                              borderRadius: BorderRadius
                                                                  .circular(20.0),
                                                              gradient: LinearGradient(
                                                                  colors: [
                                                                    colors
                                                                        .black54,
                                                                    colors
                                                                        .blackTemp,
                                                                  ],
                                                                  begin: Alignment
                                                                      .topCenter,
                                                                  end: Alignment
                                                                      .bottomCenter),
                                                            ),
                                                            child: Center(
                                                                child: Text(
                                                                  "No",
                                                                  style: TextStyle(
                                                                      color: colors
                                                                          .secondary2),
                                                                )),
                                                          ),
                                                        ),
                                                        InkWell(
                                                          onTap: () async {
                                                            var result = await Navigator
                                                                .push(context,
                                                                MaterialPageRoute(
                                                                    builder: (
                                                                        context) =>
                                                                        KYC()));
                                                            // Navigator.pop(context);
                                                            if (result == true) {
                                                              Navigator.pop(
                                                                  context);
                                                              //  doPayment();
                                                            }
                                                          },
                                                          child: Container(
                                                            height: 40,
                                                            width: 100,
                                                            decoration: BoxDecoration(
                                                              borderRadius: BorderRadius
                                                                  .circular(20.0),
                                                              gradient: LinearGradient(
                                                                  colors: [
                                                                    colors
                                                                        .black54,
                                                                    colors
                                                                        .blackTemp,
                                                                  ],
                                                                  begin: Alignment
                                                                      .topCenter,
                                                                  end: Alignment
                                                                      .bottomCenter),
                                                            ),
                                                            child: Center(
                                                                child: Text(
                                                                  "Yes",
                                                                  style: TextStyle(
                                                                      color: colors
                                                                          .secondary2),
                                                                )),
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  });

                                            } else {
                                              setupApi();
                                              // if (choiceAmountController.text.isNotEmpty) {
                                              //   if (choiceAmountController.text.isNotEmpty
                                              //       || resultGram.toString().isNotEmpty
                                              //       || choiceAmountControllerGram.text.isNotEmpty) {
                                              //     //doPayment();
                                              //  //   setupApi(walletAmountController.text.isNotEmpty ? int.parse(restAmount.toString()) : int.parse(totalAmount.toString()));
                                              //        setupApi();
                                              //   }
                                              // }else{
                                              //   Fluttertoast.showToast(msg: "Please Enter amount or grams!!");
                                              // }
                                            }
                                          },
                                          child: payMethod != 'razorPay'
                                              ? displayUpiApps()
                                              : Container(
                                            margin: EdgeInsets.only(top: 10),
                                            height: 50,
                                            width: 250,
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(30)),
                                                gradient: LinearGradient(colors: [
                                                  isBuyNow
                                                      ? colors.secondary2
                                                      : Colors
                                                      .grey,
                                                  isBuyNow
                                                      ? Color(0xffB27E29)
                                                      : Colors
                                                      .black12,
                                                ])),
                                            child: Center(
                                              child: Text(
                                                'BUY NOW',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),


                                        SizedBox(
                                          height: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }
                          );
                        });
                    startTimer ();
                  }else{
                    Fluttertoast.showToast(msg: "Please select grams first");
                  }
                },
                child: Container(
                  height: 40,
                  width: MediaQuery.of(context).size.width/2,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xffF1D459).withOpacity(0.8), Color(0xffB27E29).withOpacity(0.8)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(15.0)
                  ),
                  child: Center(child: Text("Quick Buy",
                    style: TextStyle(fontWeight: FontWeight.w500),)),
                ),
              ),
            ),

/// select payment option



          ],
        ),
      ),
    );
  }


  startTimer () {
    Timer _timer =  Timer.periodic(Duration(seconds: 1), (timer) {
      if(timerValue < 1){
        timer.cancel();
        timerValue = 0 ;
        Navigator.pop(context);
        choiceAmountController.clear();
        choiceAmountControllerGram.clear();
        setState(() {});
        getLiveRates();
      }else {
        timerValue-- ;
        bottomSheetState!((){});
      }
    });
  }

  voucherView() {
    return Container(
      height: getHeight1(144),
      width: getWidth1(622),
      decoration: boxDecoration(
          radius: 15,
          bgColor: colors.secondary2.withOpacity(0.5)
        //MyColorName.colorTextFour.withOpacity(0.3),
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

              child: text("Apply Promo-code",
                  fontSize: 12.sp, fontFamily: fontMedium)),
          boxWidth(20),
          InkWell(
            onTap: () async {
              if(choiceAmountController.text.isNotEmpty) {
                var result = await Navigator.push(context,
                    MaterialPageRoute(builder: (context) => VoucherListView()));
                print(result);
                if (result != null) {
                  setState(() {
                    model = null;
                    voucher = null;
                  });

                  addVoucher(
                      choiceAmountController.text, result.promo_code, result);
                }
              }else {
                Fluttertoast.showToast(msg: 'please enter any amount first');
              }
            },
            child: Container(
              width: getWidth1(160),
              height: getHeight1(55),
              decoration:
              boxDecoration(radius: 48, bgColor: MyColorName.primaryDark),
              child: Center(
                child: text("See All",
                    fontFamily: fontMedium,
                    fontSize: 10.sp,
                    textColor: MyColorName.colorTextPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  buySummary() {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20, bottom: 15),
      child: Container(
        width: getWidth(640),
        decoration: boxDecoration(
          radius: 15,
          bgColor: colors.secondary2.withOpacity(0.5),
        ),
        padding: EdgeInsets.symmetric(
            horizontal: getWidth(29), vertical: getHeight(32)),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                text(
                  "Sub Total ",
                  fontSize: 10.sp,
                  fontFamily: fontRegular,
                ),
                text(
                    // walletAmountController.text.isNotEmpty
                        // ? "₹ $totalAmount" : "₹ $totalAmount",
                  "₹ ${choiceAmountController.text.toString()}",
                  //"₹$subTotal",
                  fontSize: 10.sp,
                  fontFamily: fontBold,
                ),
              ],
            ),
            boxHeight(proDiscount > 0 ? 10 : 0),
            proDiscount > 0 && voucher != null
                ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                text(
                  "Promo Discount",
                  fontSize: 10.sp,
                  fontFamily: fontRegular,
                ),
                text(
                  "-₹$voucher",
                  //proDiscount",
                  fontSize: 10.sp,
                  fontFamily: fontBold,
                ),
              ],
            )
                : SizedBox(),
            boxHeight(10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                text(
                  "Exclusive Tax (${taxPer.toString()}%)",
                  fontSize: 10.sp,
                  fontFamily: fontRegular,
                ),
                text( taxAmount.toString() != null ?
                "₹ ${taxAmount.toStringAsFixed(2)}":
                "₹ 0.00",
                  // "₹$tax",
                  fontSize: 10.sp,
                  fontFamily: fontBold,
                ),
              ],
            ),
            boxHeight(10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                text(
                  "Total",
                  fontSize: 10.sp,
                  fontFamily: fontRegular,
                ),
                text(
                    "₹ ${totalWithoutWallet.toStringAsFixed(2)}",
                  fontSize: 10.sp,
                  fontFamily: fontBold,
                ),
              ],
            ),
            SizedBox(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                text(
                  "Wallet Amount Used",
                  fontSize: 10.sp,
                  fontFamily: fontRegular,
                ),
                text(
                 walletAmountController.text.isEmpty ? "-₹ 0 " :  "-₹ ${double.parse(walletAmountController.text).toStringAsFixed(2)}",
                  fontSize: 10.sp,
                  fontFamily: fontBold,
                ),
              ],
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                text(
                  "Total Payable",
                  fontSize: 10.sp,
                  fontFamily: fontSemibold,
                ),
                text(
               walletAmountController.text.isNotEmpty ?
                       "₹ ${restAmount.toStringAsFixed(2)}" : "₹ ${totalAmount.toStringAsFixed(2)}",
                  fontSize: 10.sp,
                  fontFamily: fontBold,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  doPayment(){
    double as =  walletAmountController.text.isNotEmpty ? double.parse(restAmount.toStringAsFixed(2)) : double.parse("${totalAmount.toStringAsFixed(2)}") ;
    double a = as * 100;

    print("this is @@ ${App.localStorage.getString("userId").toString()}, ${totalAmount.toString()} & ${resultGram.toString()}");
    RazorPayHelper razorHelper =
     RazorPayHelper(a.toString(), context, (result) {
      if (result == "error") {
        setState(() {});
        choiceAmountController.clear();
        choiceAmountControllerGram.clear();
      }
    }, App.localStorage.getString("userId").toString(), resultGram.toString(), isGold, false,walletAmount: walletAmountController.text);
    razorHelper.init(false);
  }




 Future<void> purchaseGoldWhenTotalZero () async {
    PruchaseModel? a =  await purchaseGold(App.localStorage.getString("userId").toString(), restAmount.toString(),
        resultGram.toString(), isGold, context,walletAmountController.text);
    if(a != null && a.message != null ){
      Fluttertoast.showToast(
          backgroundColor: colors.secondary2,
          fontSize: 18, textColor: colors.blackTemp,
          msg: "Order confirm");
      navigateScreen(context, OrderConfirmed());
    }
  }

  ApiBaseHelper apiBase = new ApiBaseHelper();

  addVoucher(total, promoCode, model1) async {
    try {
      Map params = {
        "validate_promo_code": "1",
        "user_id": App.localStorage.getString("userId").toString(),
        "final_total": choiceAmountController.text.toString(),
        "promo_code": promoCode.toString(),
      };
      print("gdfhfdh" + params.toString());
      Map response = await apiBase.postAPICall(
          Uri.parse(baseUrl + "validate_promo_code"), params);

      print(response.toString());

      if (!response['error']) {
        setSnackbar(response['message'], context);
        setState(() {
          model = model1;
          voucher =
              double.parse(response['data'][0]['final_discount'].toString());
          proDiscount =
              double.parse(response['data'][0]['final_total'].toString());
          totalAmount = double.parse(choiceAmountController.text.toString()) - voucher!;
          taxAmount = totalAmount * (taxPer/100);
          totalAmount =  totalAmount + taxAmount;
          // totalAmount = totalAmount - double.parse(voucher!.toStringAsFixed(2));
        });
      } else {
        setSnackbar(response['message'], context);
      }
    } on TimeoutException catch (_) {
      setSnackbar("Something Went Wrong", context);
      setState(() {});
    }
  }

  double? voucher;
  double proDiscount = 0;
  VoucherModel? model;
}
