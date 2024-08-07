import 'package:atticadesign/Model/adminCommissionModel.dart';
import 'package:atticadesign/new_cart.dart';
import 'package:atticadesign/transaction.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'Api/api.dart';
import 'Helper/Color.dart';

// import 'Helper/NewCart.dart';
import 'Helper/sellSilverModel.dart';
import 'Model/UserDetailsModel.dart';
import 'Utils/Common.dart';

class SellDigitalGold extends StatefulWidget {
  String goldRate;
  String gold1Rate;

  SellDigitalGold({required this.goldRate, required this.gold1Rate, Key? key})
      : super(key: key);

  @override
  State<SellDigitalGold> createState() => _SellDigitalGoldState();
}

class _SellDigitalGoldState extends State<SellDigitalGold> {
  final choiceAmountController = TextEditingController();
  final choiceAmountControllerGram = TextEditingController();
  TextEditingController mpinController = TextEditingController();

  bool isBuyNow = true;

  double resultGram = 0.0;
  double taotalPrice = 0.00;
  double goldenWallet = 0.00, totalBalance = 0.00;
  double adminCommission = 0.00 ;

  // silverGram = 62.00,
  // goldGram = 5246.96;
  double availeGoldgram = 0.00, availebaleSilveGram = 0.00;
  double goldRate = 0.00, silverRate = 0.00;
  TextStyle kTextStyle = TextStyle(fontSize: 14.0, color: Color(0xfffafcfb));
  double min = 0, max = 100;
  RangeValues rangeValues = RangeValues(0, 100);
  String pin = '';
  AdminCommissionResponse ? adminCommissionRespons ;

  @override
  void initState() {
    super.initState();
    ///for getting admin commission on sell gold
    init();
    ///______________________________________
    goldRate = double.parse(widget.goldRate.toString());
    silverRate = double.parse(widget.gold1Rate.toString());
    getWallet();
    if (App.localStorage.containsKey("pin")) {
      pin = App.localStorage.getString("pin")!;
    }
  }

  ///for getting admin commission on sell gold
  init() async{
    adminCommissionRespons = await getAdminCommission();
  }

  UserDetailsModel userDetailsModel = UserDetailsModel();
  double goldWallet = 0.00, silverWallet = 0.00;
  bool isGold = true;

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
        goldWallet =
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

    ///For Prefill the gram and amount fields.
   // preFieldTextField();
  }

  // void getWallet() async {
  //   userDetailsModel =
  //       await userDetails(App.localStorage.getString("userId").toString());
  //   if (userDetailsModel != null &&
  //       userDetailsModel.data![0].goldWallet != null) {
  //     setState(() {
  //       double balance =
  //           double.parse(userDetailsModel.data![0].goldWallet.toString());
  //       goldWallet = balance / goldRate;
  //     });
  //   }if( userDetailsModel != null &&userDetailsModel.data![0].silverWallet != null) {
  //     setState(() {
  //       double balance =
  //       double.parse(userDetailsModel.data![0].silverWallet.toString());
  //       silverWallet = balance / silverRate;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: colors.white1,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: colors.primaryNew,
        //Color(0xFF15654F),
        leading: InkWell(
          onTap: () {
            Navigator.pop(context, true);
          },
          child: Icon(
            Icons.arrow_back,
            color: colors.secondary2,
          ),
        ),
        title: Text(
          "Sell Digital ${isGold ? "Gold-916" : "Gold-999"} ",
          style: TextStyle(color: colors.whiteTemp),
        ),
        actions: [
          InkWell(
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => NewCart()));
            },
            child: Image.asset(
              "assets/images/shop.png",
              height: 20,
              width: 20,
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Image.asset(
              "assets/images/well.png",
              height: 20,
              width: 20,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 1.1,
          ),
          child: Container(
            // height: MediaQuery.of(context).size.height,
            //width: MediaQuery.of(context).size.width,
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
                              color: isGold ? colors.primaryNew : Colors.grey,
                              border: Border.all(
                                  color: isGold
                                      ? colors.primaryNew
                                      : Colors.black12),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(7.0) //
                                      ),
                            ),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  isBuyNow = true;
                                  isGold = !isGold;

                                  ///To Prefill the amount and gram textfield
                                  //preFieldTextField();

                                  // choiceAmountControllerGram.clear();
                                  // choiceAmountController.clear();
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
                                        color: isGold
                                            ? Colors.white
                                            : Color(0xff0C1723),
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
                              color: !isGold ? colors.primaryNew : Colors.grey,
                              border: Border.all(
                                  color: !isGold
                                      ? colors.primaryNew
                                      : Colors.black12),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(7.0) //
                                      ),
                            ),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  isBuyNow = true;
                                  isGold = !isGold;

                                  ///To Prefill the amount and gram textfield
                                  // double a = isGold ? goldRate : silverRate;
                                  //
                                  // choiceAmountControllerGram.text =
                                  //     availebaleSilveGram.toStringAsFixed(4);
                                  // taotalPrice = double.parse(
                                  //         choiceAmountControllerGram
                                  //                 .text.isEmpty
                                  //             ? '0.0'
                                  //             : choiceAmountControllerGram
                                  //                 .text) *
                                  //     a;
                                  // resultGram = double.parse(
                                  //     choiceAmountControllerGram.text.isEmpty
                                  //         ? '0.0'
                                  //         : choiceAmountControllerGram.text);
                                  // choiceAmountController.text =
                                  //     taotalPrice.toStringAsFixed(2);
                                  //choiceAmountControllerGram.clear();
                                  //choiceAmountController.clear();
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
                                        color: !isGold
                                            ? Colors.white
                                            : Color(0xff0C1723),
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
                Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 20),
                  child: Container(
                    padding: const EdgeInsets.only(top: 5.0, bottom: 5),
                    decoration: BoxDecoration(
                      color: colors.secondary2.withOpacity(0.5),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 30.0, bottom: 10),
                              child: Text(
                                'Sellable Gold Gram:     ',
                                style: TextStyle(
                                  color: colors.blackTemp,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            Text(
                              '${isGold ? availeGoldgram.toStringAsFixed(2).toString() : availebaleSilveGram.toStringAsFixed(2).toString()} gms',
                              style: TextStyle(
                                color: colors.blackTemp,
                                //Color(0xffF1D459),
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 30.0),
                              child: Text(
                                'Sellable Gold Amount: ',
                                style: TextStyle(
                                  color: colors.blackTemp,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            Text(
                              '  ₹${isGold ? goldWallet.toStringAsFixed(0).toString() : silverWallet.toStringAsFixed(0).toString()}',
                              style: TextStyle(
                                color: colors.blackTemp,
                                //Color(0xffF1D459),
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
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
                      color: colors.primaryNew,
                      image: DecorationImage(
                        image: AssetImage(
                            //isGold ?
                            "assets/onboarding/sellDidital.png"),
                        //: "assets/homepage/silver.png") ,
                      )),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                /*bottom: 10.0,*/
                                left: 20,
                                top: 15),
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
                        padding: const EdgeInsets.only(
                            left: 20.0, right: 0, bottom: 60, top: 40),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            isGold
                                ? Text(
                                    'Gold-916 Rate\n₹ ${goldRate.toStringAsFixed(2)} / gram',
                                    //   '${isGold ? "Gold-916" : "Gold-999"} \nnow',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  )
                                : Text(
                                    'Gold-999 Rate\n₹ ${silverRate.toStringAsFixed(2)} / gram',
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
                        padding: const EdgeInsets.only(
                            left: 15.0, right: 15, bottom: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            isGold
                                ? Expanded(
                                    flex: 1,
                                    child: Text(
                                      // isGold ?
                                      "Gold-916 Grams \n${availeGoldgram.toStringAsFixed(2)} gms ",//\n(₹ ${goldWallet.toStringAsFixed(2).toString()})
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: colors.white1,
                                        fontWeight: FontWeight.normal,
                                        fontSize: 14,
                                      ),
                                    ),
                                  )
                                : Expanded(
                                     flex: 1,
                                    child: Text(
                                      "Gold-999 Grams \n${availebaleSilveGram.toStringAsFixed(2)} gms",//\n(₹ ${silverWallet.toStringAsFixed(2).toString()})
                                      // 'Total ${isGold ? "Gold-916" : "Gold-999"} Wallet : '
                                      //     '${isGold && goldenWallet > 1 ?
                                      // "${availeGoldgram.toStringAsFixed(2)} gms \n(₹ ${goldenWallet.toStringAsFixed(2).toString()})"
                                      //     :
                                      // silverWallet > 1 ? "${availebaleSilveGram.toStringAsFixed(2)} gms \n(₹ ${silverWallet.toStringAsFixed(2).toString()})"
                                      //     : "0.00 gms \n(₹ 0.00)"}',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: colors.white1,
                                        fontWeight: FontWeight.normal,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                            Expanded(
                              flex: 1,
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Transaction(index:isGold ? 1 :2,)));
                                },
                                child: Container(
                                  //width: MediaQuery.of(context).size.width/2,
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          colors.gold1.withOpacity(0.8),
                                          colors.gold2.withOpacity(0.8)
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                      borderRadius: BorderRadius.circular(15.0)),
                                  child: Center(
                                      child: Text(
                                    "View Transactions",
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500),
                                  )),
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
                SizedBox(
                  height: 25,
                ),

                //       Container(
                //         height: 230,
                //         width: 340,
                //         decoration: BoxDecoration(
                //             borderRadius: BorderRadius.all(Radius.circular(30)),
                //             color: colors.primaryNew,
                //             image: DecorationImage(
                //               image: AssetImage("assets/onboarding/sellDidital.png"),
                //             )),
                //         child: Column(
                //           children: [
                //             Row(
                //               mainAxisAlignment: MainAxisAlignment.start,
                //               children: [
                //                 Padding(
                //                   padding: const EdgeInsets.only(
                //                       bottom: 100.0, left: 20, top: 20),
                //                   child: Text(
                //                     'Start selling \ndigital ${isGold ? "gold-916" : "gold-999"}\nnow',
                //                     style: TextStyle(
                //                       color: Colors.white,
                //                       fontWeight: FontWeight.bold,
                //                       fontSize: 20,
                //                     ),
                //                   ),
                //                 ),
                //               ],
                //             ),
                // //             Row(
                // //               children: [
                // //                 Padding(
                // //                   padding: const EdgeInsets.only(left: 10.0),
                // //                   child: Text(
                // //                     '₹',
                // //                     style: TextStyle(
                // //                       color:colors.secondary2,
                // //                       fontWeight: FontWeight.bold,
                // //                       fontSize: 10,
                // //                     ),
                // //                   ),
                // //                 ),
                // // //                 Row(
                // // //                   mainAxisAlignment: MainAxisAlignment.center,
                // // //                   children: [Text(
                // // //                     '${isGold ? goldRate : silverRate} /gm',
                // // //                     style: TextStyle(
                // // //                       color:colors.secondary2,
                // // //                       fontWeight: FontWeight.bold,
                // // //                       fontSize: 10,
                // // //                     ),
                // // //                   ),
                // // // ]
                // // //                 )
                // //               ],
                // //             ),
                //             Row(
                //               mainAxisAlignment: MainAxisAlignment.center,
                //               children: [
                //                 Padding(
                //                   padding: const EdgeInsets.only(left: 10.0),
                //                   child: Text(
                //                     'Current selling price',
                //                     style: TextStyle(
                //                       color: colors.white1,
                //                       fontWeight: FontWeight.bold,
                //                       fontSize: 14,
                //                     ),
                //                   ),
                //                 ),
                //                 Text(
                //                   ': ₹ ${isGold ? goldRate : silverRate} /gm',
                //                   style: TextStyle(
                //                     color:colors.white1,
                //                     fontWeight: FontWeight.bold,
                //                     fontSize: 14,
                //                   ),
                //                 ),
                //                 // Padding(
                //                 //   padding: const EdgeInsets.only(left: 50),
                //                 //   child: Text(
                //                 //     'Price Valid For',
                //                 //     style: TextStyle(
                //                 //       color: Color(0xffffffff),
                //                 //       fontWeight: FontWeight.bold,
                //                 //       fontSize: 10,
                //                 //     ),
                //                 //   ),
                //                 // ),
                //                 // Padding(
                //                 //   padding: const EdgeInsets.only(left: 5.0),
                //                 //   child: Text(
                //                 //     '02:44',
                //                 //     style: TextStyle(
                //                 //       color:colors.secondary2,
                //                 //       fontWeight: FontWeight.bold,
                //                 //       fontSize: 10,
                //                 //     ),
                //                 //   ),
                //                 // )
                //               ],
                //             )
                //           ],
                //         ),
                //       ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'How much you want to Sell...?',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.black,
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
                            vertical: 6, horizontal: 6),
                        child: Container(
                          height: 50,
                          margin: EdgeInsets.all(10),
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
                                resultGram = int.parse(value) / reate;
                                choiceAmountControllerGram.text =
                                    resultGram.toStringAsFixed(6).toString();
                              } else {
                                choiceAmountControllerGram.clear();
                              }
                              setState(() {});
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
                    SizedBox(
                      child: Icon(Icons.compare_arrows,
                          color: Theme.of(context).colorScheme.black, size: 30),
                      width: 35,
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        height: 50,
                        margin: EdgeInsets.all(10),
                        child: TextFormField(
                          controller: choiceAmountControllerGram,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                          onChanged: (value) {
                            double a = isGold ? goldRate : silverRate;
                            taotalPrice =
                                double.parse(value.isEmpty ? '0.0' : value) * a;
                            adminCommission = 0.0 ;
                            resultGram =
                                double.parse(value.isEmpty ? '0.0' : value);
                            if (value.isNotEmpty) {
                              choiceAmountController.text =
                                  taotalPrice.toStringAsFixed(2);

                              ///for get admin commisiion
                              if(adminCommissionRespons?.data?.commissionType?.toLowerCase() == 'percent') {
                                double tempPercent =  taotalPrice *double.parse(adminCommissionRespons?.data?.commissionValue ??' 0.0')/100;
                                taotalPrice -= tempPercent ;
                                adminCommission = tempPercent ;
                              }else {
                                double tempPercent = double.parse(adminCommissionRespons?.data?.commissionValue ??' 0.0');
                                taotalPrice -= tempPercent ;
                                adminCommission = tempPercent ;
                              }
                              ///_________________________________________________________
                            } else {
                              taotalPrice = 0.00;
                              adminCommission = 0.0 ;
                              choiceAmountController.clear();
                            }
                            setState(() {});
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
                SizedBox(
                  height: 15,
                ),
                GestureDetector(
                  onTap: () async {
                    //if (isBuyNow) {
                    //   setState(() {
                    //     isBuyNow = false;
                    //   }

                    ///choiceAmountController
                    // choiceAmountControllerGram
                    if ((isGold &&
                            double.parse(choiceAmountControllerGram.text) >
                                availeGoldgram) ||
                        (!isGold &&
                            double.parse(choiceAmountControllerGram.text) >
                                availebaleSilveGram)) {
                      Fluttertoast.showToast(
                          msg:
                              'You can only sell ${isGold ? availeGoldgram : availebaleSilveGram} Grams Gold');
                    } else if (pin == '' || pin == null) {
                      String iserId =
                          App.localStorage.getString("userId").toString();
                      SellSilverGoldModel a = await sellGoldOrSilver(
                          iserId,
                          resultGram,
                          choiceAmountController.text,
                          isGold,
                          context);
                      if (a != null && a.message != null) {
                        showDialog(
                          context: context,
                          builder: (ctxt) => new AlertDialog(
                            title: Text("${a.message}"),
                            actions: [
                              GestureDetector(
                                child: Center(child: Text("Okay")),
                                onTap: () {
                                  choiceAmountController.clear();
                                  choiceAmountControllerGram.clear();
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                },
                              )
                            ],
                          ),
                        );
                      }
                    } else {
                      showDialog(
                          context: context,
                          builder: (ctx) =>
                              StatefulBuilder(builder: (context, setState) {
                                return Dialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  // insetPadding: EdgeInsets.zero,
                                  // shape: RoundedRectangleBorder(
                                  //   borderRadius: BorderRadius.circular(30),
                                  // ),
                                  // title: const Center(
                                  //   child: Text(
                                  //     "Summary",
                                  //     style: TextStyle(
                                  //         color: backgroundblack,
                                  //         fontSize: 16,
                                  //         fontWeight: FontWeight.w600),
                                  //   ),
                                  // ),
                                  child: Container(
                                    padding: EdgeInsets.only(
                                        top: 40, left: 10, right: 10),
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(20)),

                                    // height: MediaQuery.of(context).size.width,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 10.0),
                                          child: Text(
                                            "Enter Mpin",
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 60.0),
                                          child: Container(
                                            width: 200,
                                            height: 60,
                                            child: TextFormField(
                                              onChanged: (value) {},
                                              validator: (value) {
                                                if (value!.isEmpty) {
                                                  return 'Please enter M-pin';
                                                }
                                                return null;
                                              },
                                              controller: mpinController,
                                              keyboardType:
                                                  TextInputType.number,
                                              maxLength: 4,
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                counterText: "",
                                                labelText: 'M-pin',
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 100,),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 40.0),
                                          child: GestureDetector(
                                            onTap: () async {
                                              //if (isBuyNow) {
                                              //   setState(() {
                                              //     isBuyNow = false;
                                              //   }
                                              if (pin ==
                                                  mpinController.text
                                                      .toString()) {
                                                String iserId = App
                                                    .localStorage
                                                    .getString("userId")
                                                    .toString();
                                                SellSilverGoldModel a =
                                                    await sellGoldOrSilver(
                                                        iserId,
                                                        resultGram,
                                                        choiceAmountController
                                                            .text,
                                                        isGold,
                                                        context);
                                                if (a != null &&
                                                    a.message != null) {
                                                  showDialog(
                                                    context: context,
                                                    builder: (ctxt) =>
                                                         AlertDialog(
                                                      title: Text(
                                                          "${a.message}"),
                                                      actions: [
                                                        GestureDetector(
                                                          child: Center(
                                                              child: Text(
                                                                  "Okay")),
                                                          onTap: () {
                                                            choiceAmountController
                                                                .clear();
                                                            choiceAmountControllerGram
                                                                .clear();
                                                            Navigator.pop(
                                                                ctxt);
                                                            Navigator.pop(
                                                                context);
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                        )
                                                      ],
                                                    ),
                                                  );

                                                }
                                              } else {
                                                Fluttertoast.showToast(
                                                    msg: "Wrong M-pin!");
                                              }
                                              // }
                                            },
                                            child: Container(
                                              height: 40,
                                              width: 200,
                                              decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      colors.gold1
                                                          .withOpacity(0.8),
                                                      colors.gold2
                                                          .withOpacity(0.8)
                                                    ],
                                                    begin:
                                                        Alignment.topCenter,
                                                    end: Alignment
                                                        .bottomCenter,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15.0)),
                                              child: Center(
                                                child: Text(
                                                  'SELL NOW ₹ ${choiceAmountController.text.toString()}',
                                                  style: TextStyle(
                                                      color:
                                                          Color(0xff0F261E),
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                              ),
                                            ),
                                          ),
                                        )

                                      ],
                                    ),
                                  ),
                                );
                              }));
                    }

                    // }
                  },
                  child: Container(
                    height: 40,
                    width: 200,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            /*colors.gold1.withOpacity(0.8),
                            colors.gold2.withOpacity(0.8)*/
                            colors.red,
                            colors.red
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(15.0)),
                    child: Center(
                      child: Text(
                        'SELL NOW ₹ ${choiceAmountController.text.toString()}',
                        style: TextStyle(
                            color: Color(0xff0F261E),
                            fontSize: 14,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
                adminCommission == 0.0 ? SizedBox():  Text(
                  'Admin Commission ₹${adminCommission.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  preFieldTextField() {
    double a = isGold ? goldRate : silverRate;

    choiceAmountControllerGram.text = availeGoldgram.toStringAsFixed(4);
    taotalPrice = double.parse(choiceAmountControllerGram.text.isEmpty
            ? '0.0'
            : choiceAmountControllerGram.text) *
        a;
    resultGram = double.parse(choiceAmountControllerGram.text.isEmpty
        ? '0.0'
        : choiceAmountControllerGram.text);
    choiceAmountController.text = taotalPrice.toStringAsFixed(2);
    setState(() {});
  }
}
