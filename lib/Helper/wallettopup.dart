import 'dart:convert';

import 'package:atticadesign/transaction.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:upi_india/upi_india.dart';
import 'package:upi_india/upi_response.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import '../Api/api.dart';
import '../Model/withdraw_history.dart';
import '../Utils/Common.dart';
import '../Utils/Razorpay.dart';
import '../Utils/constant.dart';
import 'Color.dart';
import 'Session.dart';

class WalletTopups extends StatefulWidget {
  const WalletTopups({Key? key}) : super(key: key);

  @override
  State<WalletTopups> createState() => _WalletTopupsState();
}

class _WalletTopupsState extends State<WalletTopups> {

  List categories = [
    " ₹ 1000 ",
    " ₹ 2000 ",
    " ₹ 5000 ",
  ];
  List selectedCategories = [];
  TextEditingController choiceAmountController = TextEditingController();
  String payMethod = 'razorPay';

  Future<UpiResponse>? _transaction;
  UpiIndia _upiIndia = UpiIndia();
  List<UpiApp>? apps;

  doPayment(){
    var a = double.parse(choiceAmountController.text.toString()) * 100;
    RazorPayHelper razorHelper= new RazorPayHelper(
        choiceAmountController.text.toString() ,
        context, (result){}, "curUserId", "", false, false);
    razorHelper.init(true, amount: a.toString(), addAmointTr: true);
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
  TextStyle header = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  TextStyle value = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 14,
  );

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Color(0xFF0F261E),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: colors.primaryNew,
        //Color(0xFF15654F),
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back,
            color: colors.secondary2,
          ),
        ),
        title: Text("Wallet Topup"),
        actions: [
          Image.asset(
            "assets/images/shop.png",
            height: 15,
            width: 20,
          ),
          SizedBox(
            width: 10,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Image.asset(
              "assets/images/well.png",
              height: 15,
              width: 20,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                "Topup wallet",
                style: TextStyle(color: Theme.of(context).colorScheme.black, fontSize: 20),
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
                    borderSide:
                        const BorderSide(color: Colors.blue, width: 1.0),
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
            Container(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Wrap(
                    alignment: WrapAlignment.start,
                    direction: Axis.horizontal,
                    children: [
                      ChoiceChip(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.horizontal(
                                left: Radius.circular(25),
                                right: Radius.circular(25))),
                       // side: BorderSide(width: 1, color: Color(0xff0C3B2E)),
                        backgroundColor: colors.secondary2.withOpacity(0.5),
                        //Color(0xff15654F),
                        label: Text('1000',
                            textAlign: TextAlign.center,
                            style:
                                TextStyle(color: colors.blackTemp, fontSize: 20)),
                        labelPadding: EdgeInsets.symmetric(horizontal: 12),
                        selected: choiceAmountController.text == '1000',
                        onSelected: (bool selected) {
                          setState(() {
                            choiceAmountController.text =
                                (selected ? '1000' : '');
                            print("10::---$choiceAmountController");
                          });
                        },
                        selectedColor: colors.secondary2,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      ChoiceChip(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.horizontal(
                                left: Radius.circular(25),
                                right: Radius.circular(25))),
                      //  side: BorderSide(width: 1, color: Color(0xff0C3B2E)),
                        backgroundColor: colors.secondary2.withOpacity(0.5),
                        label: Text('2000',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: colors.blackTemp,
                                fontSize: 20)),
                        labelPadding: EdgeInsets.symmetric(horizontal: 12),
                        // selected: choice== 'right',
                        selected: choiceAmountController.text == '2000',
                        onSelected: (bool selected) {
                          setState(() {
                            print("20::");
                            choiceAmountController.text =
                                (selected ? '2000' : '');
                          });
                        },
                        selectedColor: colors.secondary2,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      ChoiceChip(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.horizontal(
                                left: Radius.circular(25),
                                right: Radius.circular(25))),
                      //  side: BorderSide(width: 1, color: Color(0xff0C3B2E)),
                        backgroundColor: colors.secondary2.withOpacity(0.5),
                        //Color(0xff15654F),
                        label: Text('5000',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: colors.blackTemp,
                                fontSize: 20)),
                        labelPadding: EdgeInsets.symmetric(horizontal: 12),
                        selected: choiceAmountController.text == '5000',
                        onSelected: (bool selected) {
                          setState(() {
                            print("50::");
                            choiceAmountController.text =
                                (selected ? '5000' : '');
                          });
                        },
                        selectedColor: colors.secondary2,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.01,
                      ),
                      ChoiceChip(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.horizontal(
                                left: Radius.circular(25),
                                right: Radius.circular(25))),
                       // side: BorderSide(width: 1, color: colors.blackTemp),
                        backgroundColor: colors.secondary2.withOpacity(0.5),
                        //Color(0xff15654F),
                        label: Text('10000',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: colors.blackTemp,
                                fontSize: 20)),
                        labelPadding: EdgeInsets.symmetric(horizontal: 12),
                        selected: choiceAmountController.text == '10000',
                        onSelected: (bool selected) {
                          setState(() {
                            print("100::");
                            choiceAmountController.text =
                                (selected ? '10000' : '');
                          });
                        },
                        selectedColor: colors.secondary2,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                    ]),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
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


            payMethod == "razorPay" ?
            Center(
              child: GestureDetector(
                onTap: () {

                  // if (totalAmount > 100000) {
                  //   showDialog(
                  //       context: context,
                  //       // barrierDismissible: false,
                  //       builder: (
                  //           BuildContext context) {
                  //         return AlertDialog(
                  //           backgroundColor: colors
                  //               .secondary2,
                  //           title: Text("KYC",
                  //             style: TextStyle(
                  //                 fontWeight: FontWeight
                  //                     .bold
                  //             ),),
                  //           content: Text(
                  //             "You need to update KYC to buy digital gold worth more than 1 Lacs",
                  //             style: TextStyle(
                  //                 fontSize: 14
                  //             ),),
                  //
                  //           actions: <Widget>[
                  //             InkWell(
                  //               onTap: () {
                  //                 Navigator.pop(
                  //                     context);
                  //               },
                  //               child: Container(
                  //                 height: 40,
                  //                 width: 100,
                  //                 decoration: BoxDecoration(
                  //                   borderRadius: BorderRadius
                  //                       .circular(20.0),
                  //                   gradient: LinearGradient(
                  //                       colors: [
                  //                         colors
                  //                             .black54,
                  //                         colors
                  //                             .blackTemp,
                  //                       ],
                  //                       begin: Alignment
                  //                           .topCenter,
                  //                       end: Alignment
                  //                           .bottomCenter),
                  //                 ),
                  //                 child: Center(
                  //                     child: Text(
                  //                       "No",
                  //                       style: TextStyle(
                  //                           color: colors
                  //                               .secondary2),
                  //                     )),
                  //               ),
                  //             ),
                  //             InkWell(
                  //               onTap: () async {
                  //                 var result = await Navigator
                  //                     .push(context,
                  //                     MaterialPageRoute(
                  //                         builder: (
                  //                             context) =>
                  //                             KYC()));
                  //                 // Navigator.pop(context);
                  //                 if (result == true) {
                  //                   Navigator.pop(
                  //                       context);
                  //                   doPayment();
                  //                 }
                  //               },
                  //               child: Container(
                  //                 height: 40,
                  //                 width: 100,
                  //                 decoration: BoxDecoration(
                  //                   borderRadius: BorderRadius
                  //                       .circular(20.0),
                  //                   gradient: LinearGradient(
                  //                       colors: [
                  //                         colors
                  //                             .black54,
                  //                         colors
                  //                             .blackTemp,
                  //                       ],
                  //                       begin: Alignment
                  //                           .topCenter,
                  //                       end: Alignment
                  //                           .bottomCenter),
                  //                 ),
                  //                 child: Center(
                  //                     child: Text(
                  //                       "Yes",
                  //                       style: TextStyle(
                  //                           color: colors
                  //                               .secondary2),
                  //                     )),
                  //               ),
                  //             ),
                  //           ],
                  //         );
                  //       });
                  // } else {
                  //   if (choiceAmountController.text
                  //       .isNotEmpty) {
                  //     if (choiceAmountController.text
                  //         .isNotEmpty
                  //         || resultGram
                  //             .toString()
                  //             .isNotEmpty
                  //         || choiceAmountControllerGram
                  //             .text
                  //             .isNotEmpty) {
                  if(choiceAmountController.text.isNotEmpty) {
                    doPayment();
                  }else{
                    Fluttertoast.showToast(
                        msg: "Please Enter amount!");
                  }
                      // }
                    // } else {
                    //   Fluttertoast.showToast(
                    //       msg: "Please Enter amount or grams!!");
                    // }
                  // }
                },
                child: Container(
                  margin: EdgeInsets.only(top: 10),
                  height: 40,
                  width: 250,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                          Radius.circular(30)),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                        // isBuyNow
                        //     ?
                        colors.secondary2,
                            Color(0xffB27E29),
                        //     : Colors
                        //     .grey,
                        // isBuyNow
                        //     ? Color(0xffB27E29)
                        //     :
                        //     Colors
                        //          .black38,
                      ])),
                  child: Center(
                    child: Text(
                      'PROCEED TO TOPUP',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ),
              ),
            ) :
            GestureDetector(
              onTap: () async {
                print("setu api here");
                // if (totalAmount > 100000) {
                //   showDialog(
                //       context: context,
                //       // barrierDismissible: false,
                //       builder: (
                //           BuildContext context) {
                //         return AlertDialog(
                //           backgroundColor: colors
                //               .secondary2,
                //           title: Text("KYC",
                //             style: TextStyle(
                //                 fontWeight: FontWeight
                //                     .bold
                //             ),),
                //           content: Text(
                //             "You need to update KYC to buy digital gold worth more than 1 Lacs",
                //             style: TextStyle(
                //                 fontSize: 14
                //             ),),
                //
                //           actions: <Widget>[
                //             InkWell(
                //               onTap: () {
                //                 Navigator.pop(
                //                     context);
                //               },
                //               child: Container(
                //                 height: 40,
                //                 width: 100,
                //                 decoration: BoxDecoration(
                //                   borderRadius: BorderRadius
                //                       .circular(20.0),
                //                   gradient: LinearGradient(
                //                       colors: [
                //                         colors
                //                             .black54,
                //                         colors
                //                             .blackTemp,
                //                       ],
                //                       begin: Alignment
                //                           .topCenter,
                //                       end: Alignment
                //                           .bottomCenter),
                //                 ),
                //                 child: Center(
                //                     child: Text(
                //                       "No",
                //                       style: TextStyle(
                //                           color: colors
                //                               .secondary2),
                //                     )),
                //               ),
                //             ),
                //             InkWell(
                //               onTap: () async {
                //                 var result = await Navigator
                //                     .push(context,
                //                     MaterialPageRoute(
                //                         builder: (
                //                             context) =>
                //                             KYC()));
                //                 // Navigator.pop(context);
                //                 if (result == true) {
                //                   Navigator.pop(
                //                       context);
                //                   //  doPayment();
                //                 }
                //               },
                //               child: Container(
                //                 height: 40,
                //                 width: 100,
                //                 decoration: BoxDecoration(
                //                   borderRadius: BorderRadius
                //                       .circular(20.0),
                //                   gradient: LinearGradient(
                //                       colors: [
                //                         colors
                //                             .black54,
                //                         colors
                //                             .blackTemp,
                //                       ],
                //                       begin: Alignment
                //                           .topCenter,
                //                       end: Alignment
                //                           .bottomCenter),
                //                 ),
                //                 child: Center(
                //                     child: Text(
                //                       "Yes",
                //                       style: TextStyle(
                //                           color: colors
                //                               .secondary2),
                //                     )),
                //               ),
                //             ),
                //           ],
                //         );
                //       });
                // } else {
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
                // }
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
                    gradient: LinearGradient(
                        colors: [
                      // isBuyNow
                      //     ?
                      colors.secondary2,
                      Color(0xffB27E29),
                    ])),
                child: Center(
                  child: Text(
                    'PROCEED TO TOPUP',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ),
            ),
            // GestureDetector(
            //   onTap: () async {
            //
            //   /*  var a = await addAmount(choiceAmountController.text);
            //     if (a != null) {
            //       showDialog(
            //         context: context,
            //         builder: (ctxt) => new AlertDialog(
            //           title: Text("${a.message}"),
            //           actions: [
            //             GestureDetector(
            //               child: Center(child: Text("Okay")),
            //               onTap: () {
            //                 Navigator.pop(context);
            //                 Navigator.pop(context);
            //               },
            //             )
            //           ],
            //         ),
            //       );
            //     }*/
            //   },
            //   child: Center(
            //     child: Container(
            //       decoration: BoxDecoration(
            //           gradient: LinearGradient(
            //             colors: [Color(0xffF1D459), Color(0xffB27E29)],
            //             begin: Alignment.topCenter,
            //             end: Alignment.bottomCenter,
            //           ),
            //           borderRadius: BorderRadius.circular(30.0)),
            //       height: 45,
            //       width: MediaQuery.of(context).size.width / 2,
            //       child: Center(
            //         child: Text(
            //           "PROCEED TO TOPUP",
            //           style: TextStyle(color: colors.white1, fontSize: 15),
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
            SizedBox(
              height: 20,
            ),


          ],
        ),
      ),
    );
  }

}
