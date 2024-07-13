

import 'package:atticadesign/Helper/Session.dart';
import 'package:atticadesign/Model/BankDetailResponse.dart';
import 'package:atticadesign/Utils/constant.dart';
import 'package:atticadesign/transaction.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import '../Api/api.dart';
import '../Helper/Color.dart';
import '../Model/withdraw_history.dart';
import '../Utils/Common.dart';
import '../Utils/withdrawmodel.dart';
import 'package:http/http.dart' as http;

class WithDrawPage extends StatefulWidget {
  const WithDrawPage({Key? key, this.walletAmount}) : super(key: key);
final String? walletAmount ;
  @override
  State<WithDrawPage> createState() => _WithDrawPageState();
}

class _WithDrawPageState extends State<WithDrawPage> {
  bool isGold = true, isUpi = true;
  List categories = [
    " ₹ 1000 ",
    " ₹ 2000 ",
    " ₹ 5000 ",
  ];
  List selectedCategories = [];
  TextEditingController choiceAmountController = TextEditingController();
  TextEditingController acccountNumber = TextEditingController();
  TextEditingController accountHolderName = TextEditingController();
  TextEditingController ifscCode = TextEditingController();
  TextEditingController bankName = TextEditingController();
  TextEditingController upiId = TextEditingController();
  TextEditingController brancController = TextEditingController();

  List <BankDetailData> bankDetail = [];
  bool isSelected = false;
  bool showBankFields = false;
  bool showUpiFields = false;
  bool isUpiSelected = false;

  getBankDetail({String? upi})async{
    bankDetail.clear();
    setState(() {

    });
    var headers = {
      'Cookie': 'ci_session=3aff9adf2fc5690a259804d394beb053a243e31d'
    };
    var request = http.MultipartRequest('POST', Uri.parse(upi == '' || upi == null ?'${baseUrl}save_user_bank_details/${App.localStorage.getString("userId").toString()}}' :'${baseUrl}save_user_bank_details/${App.localStorage.getString("userId").toString()}}/upi' ));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var finalResponse =  await response.stream.bytesToString();
      final jsonResponse = json.decode(finalResponse);
      print("final json response here ${jsonResponse}");
      setState(() {
        bankDetail = BankDetailsResponse.fromJson(jsonResponse).data ?? [];
      });
    }
    else {
    print(response.reasonPhrase);
    }

  }

  saveBankDetails()async{
    bool isSelected =  false ;
    int? index;

    bankDetail.forEach((element) {
      if(element.isSelected ??  false) {
        isSelected = true ;
        index = bankDetail.indexWhere((element1) => element1 == element);
      }
    });


    var headers = {
      'Cookie': 'ci_session=6ea9035eb03c3b37384816f4b92b8b4957a8b7bd'
    };
    var request = http.MultipartRequest('POST', Uri.parse('${baseUrl}save_user_bank_details'));
    request.fields.addAll({
      'user_id': App.localStorage.getString("userId").toString(),
      'bank_name': isUpi == true ? "" : bankName.text,
      'account_holder_name':isUpi == true ? "" : accountHolderName.text,
      'account_number':isUpi == true ? "" : acccountNumber.text,
      'ifsc_code': isUpi == true ? "" :ifscCode.text,
      'branch_name': isUpi == true ? "" : brancController.text,
      'upi_id': isUpi == true ? upiId.text : "",
      if(isSelected && index!=null) 'id': bankDetail[index!].id ?? ''




    });

    print("ssssssss ${request.fields}");
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var finalResult = await response.stream.bytesToString();
      final jsonResponse = json.decode(finalResult);
      print("final response here ${jsonResponse}");
      setState(() {
      });
      Fluttertoast.showToast(msg: "${jsonResponse['message']}");
      getBankDetail(upi: isUpi == true ? 'upi': '');
    }
    else {
      print(response.reasonPhrase);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getBankDetail(upi: 'upi');

    getTransationHistory(App.localStorage.getString("userId").toString());
  }
  // getBankDetails() async {
  //   String userId = App.localStorage.getString("userId").toString();
  //   var headers = {
  //     'Cookie': 'ci_session=3ab2e0bfe4c2535c351d13c7ca58f780dce6aa8f'
  //   };
  //   var request =
  //   http.MultipartRequest('POST', Uri.parse('${baseUrl.toString()}' + 'save_user_bank_details/$userId'));
  //   // request.fields.addAll({
  //   //   'vid': App.localStorage.getString("userId").toString(),
  //   //   //'$uid'
  //   // });
  //   print("this is request =====>>>>> ${request.fields.toString()}");
  //   request.headers.addAll(headers);
  //   http.StreamedResponse response = await request.send();
  //   if (response.statusCode == 200) {
  //     print("this response @@ ${response.statusCode}");
  //     final str = await response.stream.bytesToString();
  //     var result = GetProfileModel.fromJson(json.decode(str));
  //
  //
  //     return GetProfileModel.fromJson(json.decode(str));
  //   } else {
  //     return null;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Color(0xFF0F261E),
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
        title: Text("Withdraw Wallet TopUp"),
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
        child: ListView(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
              Padding(
                padding: const EdgeInsets.only(left: 18.0,right: 18),
                child: Text(
                  "Withdraw Wallet Balance: ",
                  style: TextStyle(color: colors.blackTemp, fontSize: 14),
                ),
              ),
              Text(
                "${widget.walletAmount}",
                style: TextStyle(color: colors.blackTemp, fontSize: 14),
              )
            ],),
            // Padding(
            //   padding: EdgeInsets.only(top: 10),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: [
            //       Expanded(
            //         child: Padding(
            //           padding: EdgeInsets.only(top: 10.0, left: 15.0),
            //           child: Container(
            //             height: 50,
            //             width: 150,
            //             decoration: BoxDecoration(
            //               color: isGold ? Colors.green : Colors.grey,
            //               border: Border.all(
            //                   color:
            //                   isGold ? Colors.green : Colors.black12),
            //               borderRadius:
            //               BorderRadius.all(Radius.circular(7.0) //
            //               ),
            //             ),
            //             child: InkWell(
            //               onTap: () {
            //                 setState(() {
            //                   isGold = !isGold;
            //                 });
            //               },
            //               child: Padding(
            //                 padding: const EdgeInsets.only(left: 15),
            //                 child: Row(
            //                   mainAxisAlignment: MainAxisAlignment.start,
            //                   children: [
            //                     Image.asset(
            //                       'assets/homepage/gold.png',
            //                       height: 30,
            //                     ),
            //                     SizedBox(
            //                       width: 5,
            //                     ),
            //                     Text(
            //                       'Gold',
            //                       style: TextStyle(
            //                         color: isGold
            //                             ? Colors.white
            //                             : Color(0xff0C3B2E),
            //                         fontSize: 15,
            //                         fontWeight: FontWeight.bold,
            //                       ),
            //                     ),
            //                   ],
            //                 ),
            //               ),
            //             ),
            //           ),
            //         ),
            //       ),
            //       SizedBox(
            //         width: 10,
            //       ),
            //       Expanded(
            //         child: Padding(
            //           padding: const EdgeInsets.only(top: 10.0, right: 15),
            //           child: Container(
            //             height: 50,
            //             width: 150,
            //             decoration: BoxDecoration(
            //               color: !isGold ? Colors.green : Colors.grey,
            //               border: Border.all(
            //                   color:
            //                   !isGold ? Colors.green : Colors.black12),
            //               borderRadius:
            //               BorderRadius.all(Radius.circular(7.0) //
            //               ),
            //             ),
            //             child: InkWell(
            //               onTap: () {
            //                 setState(() {
            //                   isGold = !isGold;
            //                 });
            //               },
            //               child: Padding(
            //                 padding: const EdgeInsets.only(left: 10),
            //                 child: Row(
            //                   mainAxisAlignment: MainAxisAlignment.start,
            //                   children: [
            //                     Image.asset(
            //                       'assets/homepage/silverbrick.png',
            //                       height: 30,
            //                     ),
            //                     SizedBox(
            //                       width: 5,
            //                     ),
            //                     Text(
            //                       'Silver',
            //                       style: TextStyle(
            //                         color: !isGold
            //                             ? Colors.white
            //                             : Color(0xff0C3B2E),
            //                         fontSize: 15,
            //                         fontWeight: FontWeight.bold,
            //                       ),
            //                     ),
            //                   ],
            //                 ),
            //               ),
            //             ),
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            Container(
              margin: EdgeInsets.all(10),
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
            amountChips(),
            // SizedBox(
            //   height: 20,
            // ),
            Padding(
              padding: EdgeInsets.only(top: 10),
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
                          color: isUpi ? Colors.green : Colors.grey,
                          border: Border.all(
                              color: isUpi ? Colors.green : Colors.black12),
                          borderRadius: BorderRadius.all(Radius.circular(7.0) //
                              ),
                        ),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              isUpi = !isUpi;
                            });
                            getBankDetail(upi: 'upi');
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '@-UPI',
                                style: TextStyle(
                                  color:
                                      isUpi ? Colors.white : Color(0xff0C3B2E),
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
                          color: !isUpi ? Colors.green : Colors.grey,
                          border: Border.all(
                              color: !isUpi ? Colors.green : Colors.black12),
                          borderRadius: BorderRadius.all(Radius.circular(7.0) //
                              ),
                        ),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              isUpi = !isUpi;
                            });
                            getBankDetail(upi: '');
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Bank Transfer',
                                style: TextStyle(
                                  color:
                                      !isUpi ? Colors.white : Color(0xff0C3B2E),
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
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),

           isUpi == false ? SizedBox.shrink() : InkWell(
            onTap: (){
              setState(() {
                showUpiFields = !showUpiFields;
              });
            },
            child: Container(
                margin: EdgeInsets.only(bottom: 10,left: 80,right: 80),
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
                    "ADD Upi Detail",
                    style: TextStyle(color: colors.white1, fontSize: 15),
                  ),
                ),
              ),
          ),

             isUpi && showUpiFields == true
              ?    Container(
                margin: EdgeInsets.all(15),
                child: TextFormField(
                  controller: upiId,
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.blue,
                    fontWeight: FontWeight.w600,
                  ),
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    focusColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.blue, width: 1.0),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    fillColor: Colors.grey,
                    hintText: "Enter UPI ID",
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                    labelText: 'Enter UPI ID',
                    labelStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              )
               : SizedBox.shrink(),
            SizedBox(
              height: 20,
            ),
          isUpi == true
              ? SizedBox.shrink()
              :  Center(
                    child: InkWell(
                           onTap: (){
                  setState(() {
                    showBankFields = !showBankFields;
                  });
                },
                child: Container(
                  margin: EdgeInsets.only(bottom: 10),
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
                      "ADD Bank Detail",
                      style: TextStyle(color: colors.white1, fontSize: 15),
                    ),
                  ),
                ),
              ),
            ) ,

            if (!isUpi)
              /*bankDetail.isEmpty &&*/ showBankFields == true ?
              Column(children: [
                Container(
                  margin: EdgeInsets.all(15),
                  child: TextFormField(
                    controller: bankName,
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      focusColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                        const BorderSide(color: Colors.blue, width: 1.0),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      fillColor: Colors.grey,
                      hintText: "Enter Bank name",
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      labelText: 'Enter Bank name',
                      labelStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(15),
                  child: TextFormField(
                    controller: acccountNumber,
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      focusColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                        const BorderSide(color: Colors.blue, width: 1.0),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      fillColor: Colors.grey,
                      hintText: "Enter Account Number",
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      labelText: 'Enter Account Number',
                      labelStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(15),
                  child: TextFormField(
                    controller: accountHolderName,
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      focusColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                        const BorderSide(color: Colors.blue, width: 1.0),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      fillColor: Colors.grey,
                      hintText: "Enter Account Holder Name",
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      labelText: 'Enter Account Holder Name',
                      labelStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
                Container(
                  margin:
                  EdgeInsets.only(left: 15, top: 15, right: 15, bottom: 10),
                  child: TextFormField(
                    controller: ifscCode,
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      focusColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                        const BorderSide(color: Colors.blue, width: 1.0),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      fillColor: Colors.grey,
                      hintText: "Enter IFSC Code",
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      labelText: "Enter IFSC Code",
                      labelStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
                Container(
                  margin:
                  EdgeInsets.only(left: 15, top: 15, right: 15, bottom: 10),
                  child: TextFormField(
                    controller: brancController,
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      focusColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                        const BorderSide(color: Colors.blue, width: 1.0),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      fillColor: Colors.grey,
                      hintText: "Enter branch name",
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      labelText: "Enter branch name",
                      labelStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                )


              ],): SizedBox.shrink(),



            isUpi == false
               ? bankDetail.isEmpty ? SizedBox()
                : SizedBox(height: 150,
              child: ListView.builder(
                itemCount: bankDetail.length,
                itemBuilder: (context, index) {

                  return InkWell(
                    onTap: (){
                      acccountNumber = TextEditingController(text: bankDetail [index].accountNumber);
                      ifscCode = TextEditingController(text: bankDetail[index].ifscCode);
                      bankName = TextEditingController(text: bankDetail[index].bankName);
                      accountHolderName = TextEditingController(text:bankDetail[index].accountHolderName);
                      brancController = TextEditingController(text: bankDetail[index].branchName);
                      bankDetail.forEach((element) {
                        element.isSelected = false ;
                      });
                      setState(() {
                        bankDetail[index].isSelected = !(bankDetail[index].isSelected ?? false);
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(color: bankDetail[index].isSelected == true ? Colors.green : Colors.grey,width: bankDetail[index].isSelected == true ? 2 :1)
                      ),
                      margin: EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(child: Text("Bank Name:")),
                                    Expanded(child: Text("${bankDetail[index].bankName}")),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(child: Text("Account Number:")),
                                    Expanded(child: Text("${bankDetail[index].accountNumber}")),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(child: Text("Account Holder Name: ")),
                                    Expanded(child: Text("${bankDetail[index].accountHolderName}")),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(child: Text("IFSC Code:")),
                                    Expanded(child: Text("${bankDetail[index].ifscCode}")),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(child: Text("Branch Name:")),
                                    Expanded(child: Text("${bankDetail[index].branchName}")),
                                  ],
                                ),

                              ],
                            ),
                          ),
                          InkWell(
                            onTap: (){

                              deleteBankDetail(bankDetail[index].id.toString());

                            },
                              child: Icon(Icons.delete))

                        ],
                      ),
                    ),
                  );
                },),)
               : bankDetail.isEmpty ? SizedBox()
                : SizedBox(height: 150,child: ListView.builder(
                  itemCount: bankDetail.length,
                  itemBuilder: (context, index) {
                 return InkWell(
                   onTap: (){
                     // acccountNumber = TextEditingController(text: bankDetail['data']['account_number']);
                     // ifscCode = TextEditingController(text: bankDetail['data']['ifsc_code']);
                     // bankName = TextEditingController(text: bankDetail['data']['bank_name']);
                     // accountHolderName = TextEditingController(text:bankDetail['data']['account_holder_name']);
                     // brancController = TextEditingController(text: bankDetail['data']['branch_name']);
                     upiId = TextEditingController(text: bankDetail[index].upiId);
                     bankDetail.forEach((element) {
                       element.isSelected = false ;
                     });
                     setState(() {
                       bankDetail[index].isSelected = !(bankDetail[index].isSelected ?? false);
                     });
                   },
                   child: Container(
                     padding: EdgeInsets.all(10),
                     decoration: BoxDecoration(
                         borderRadius: BorderRadius.circular(7),
                         border: Border.all(color: bankDetail[index].isSelected == true ? Colors.green : Colors.grey,width: bankDetail[index].isSelected == true ? 2 :1)
                     ),
                     margin: EdgeInsets.only(bottom: 10),
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Row(
                           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                           crossAxisAlignment: CrossAxisAlignment.center,
                           children: [
                             Expanded(child: Text("Upi Id:")),
                             Expanded(child: Text("${bankDetail[index].upiId}")),
                             Expanded(child: IconButton(onPressed: (){
                               deleteBankDetail(bankDetail[index].id.toString());
                             },icon: Icon(Icons.delete),))
                           ],
                         ),


                       ],
                     ),
                   ),
                 ) ;
               },),),

            GestureDetector(
              onTap: () async {
                if (choiceAmountController.text.isNotEmpty) {
                  if (isUpi) {
                    if ((upiId.text.isNotEmpty && upiId.text.contains("@"))) {
                      // if (upiId.text.isNotEmpty) {
                      Withdrawmodel? a = await withDrawApi(
                          amount: choiceAmountController.text,
                          accountHoldername: accountHolderName.text,
                          accountNumber: acccountNumber.text,
                          BankName: bankName.text,
                          ifscCode: ifscCode.text,
                          upiId: upiId.text);
                      saveBankDetails();
                      if (a != null) {
                        choiceAmountController.clear();
                        acccountNumber.clear();
                        accountHolderName.clear();
                        ifscCode.clear();
                        bankName.clear();
                        upiId.clear();
                        // Fluttertoast.showToast(
                        //     backgroundColor: Colors.green,
                        //     fontSize: 18, textColor: Colors.yellow,
                        //     msg: "Withdraw request successfully");
                      }
                    } else {
                      Fluttertoast.showToast(
                          backgroundColor: Colors.green,
                          fontSize: 18,
                          textColor: Colors.yellow,
                          msg: "Please enter valid upi link or bank details");
                    }
                  } else {
                    if ((acccountNumber.text.isNotEmpty &&
                            ifscCode.text.isNotEmpty) &&
                        bankName.text.isNotEmpty) {
                      Withdrawmodel? a = await withDrawApi(
                          amount: choiceAmountController.text,
                          accountHoldername: accountHolderName.text,
                          accountNumber: acccountNumber.text,
                          BankName: bankName.text,
                          ifscCode: ifscCode.text,
                          upiId: upiId.text);
                      saveBankDetails();
                      if (a != null) {
                        choiceAmountController.clear();
                        acccountNumber.clear();
                        accountHolderName.clear();
                        ifscCode.clear();
                        bankName.clear();
                        brancController.clear();
                        upiId.clear();
                        Fluttertoast.showToast(msg: "${a.message}");
                      }
                    } else {
                      Fluttertoast.showToast(
                          backgroundColor: Colors.green,
                          fontSize: 18,
                          textColor: Colors.yellow,
                          msg: "Please enter valid upi link or bank details");
                    }
                  }
                } else {
                  Fluttertoast.showToast(
                      backgroundColor: Colors.green,
                      fontSize: 18,
                      textColor: Colors.yellow,
                      msg: "Please enter amount you want to withdraw!!");
                }
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
                      "PROCEED TO WITHDRAW",
                      style: TextStyle(color: colors.white1, fontSize: 15),
                    ),
                  ),
                ),
              ),
            ),
            // TextButton(onPressed: (){
            //   Navigator.push(context, MaterialPageRoute(builder: (context)=> Transaction()));
            // }, child: Text("Wallet History",
            //   style: TextStyle(
            //       color: colors.secondary2,
            //       fontWeight: FontWeight.w600,
            //       fontSize: 18
            //   ),)),
            Padding(
              padding: const EdgeInsets.only(top: 20, left: 18.0, bottom: 15),
              child: Text(
                "Withdraw History",
                style: TextStyle(color: colors.blackTemp, fontSize: 20),
              ),
            ),
            FutureBuilder(
                future: getTransationHistory(
                    App.localStorage.getString("userId").toString()),
                // getTransationCash(
                //   App.localStorage.getString("userId").toString(),
                // ),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if(snapshot.connectionState == ConnectionState.waiting){
                    return Center(child: CircularProgressIndicator(),);
                  }else if (snapshot.hasError){
                    return  Center(child: Icon(Icons.error_outline));
                  } else {
                    WithdrawHistory? transationModel = snapshot.data;
                    double amount = 0.00, tranctionData = 0.00;

                    return transationModel!.data!.length > 0
                        ? Container(
                            //height: MediaQuery.of(context).size.height,
                            child: ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: transationModel.data!.length,
                                reverse: true,
                                itemBuilder: (context, index) {
                                  if (transationModel.data![index].amount !=
                                      null) {
                                    amount = double.parse(transationModel
                                        .data![index].amount
                                        .toString());
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Card(
                                      color: colors.secondary2,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      child: ListTile(
                                        leading: Padding(
                                          padding: const EdgeInsets.only(
                                              top: 8.0, bottom: 8),
                                          child: Image.asset(
                                            "assets/images/lockercupan.png",
                                          ),
                                        ),
                                        title:  Text(
                                          "${transationModel.data![index].createdAt.toString()}",
                                          style: TextStyle(
                                              color: colors.blackTemp,
                                              fontSize: 18),
                                        ),
                                        subtitle:transationModel.data![index].remarks !=null ? Text('${transationModel.data![index].remarks}') : SizedBox(),
                                        // subtitle: RichText(
                                        //   text: TextSpan(
                                        //     style: TextStyle(
                                        //         color: colors.blackTemp,
                                        //         fontSize: 17),
                                        //     children: <TextSpan>[
                                        //       // TextSpan(
                                        //       //     text:
                                        //       //     "${transationModel.data![index].dateCreated}",
                                        //       //     style: TextStyle(
                                        //       //       color:colors.blackTemp,)),
                                        //     ],
                                        //   ),
                                        // ),
                                        trailing: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                          Text(
                                            "₹ ${transationModel.data![index].amount.toString()}",
                                            style: TextStyle(
                                                color: colors.blackTemp,
                                                fontSize: 16),
                                          ),
                                          transationModel.data![index].remarks ==null && transationModel.data![index].isApproved == '0'
                                              ? Card(
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Text('Pending', style: TextStyle(color: Colors.blueAccent),),
                                              ))
                                              : transationModel.data![index].isApproved == '1'
                                                 ? Card(
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Text('Approved', style: TextStyle(color: Colors.green),),
                                              ))
                                                 : Card(
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Text('Rejected', style: TextStyle(color: Colors.red),),
                                              ))
                                        ],),
                                      ),
                                    ),
                                  );
                                }),
                          )
                        : SizedBox(
                            height: MediaQuery.of(context).size.height,
                            width: double.infinity,
                            child: Center(
                                child: Text(
                              "No History Yet",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 22),
                            )));
                  }
                })
          ],
        ),
      ),
    );
  }


  Widget amountChips() {
    return Container(
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
                  //  side: BorderSide(width: 1, color: Color(0xff0C3B2E)),
                  backgroundColor: colors.secondary2.withOpacity(0.5),
                  label: Text('1000',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: colors.blackTemp, fontSize: 20)),
                  labelPadding: EdgeInsets.symmetric(horizontal: 12),
                  selected: choiceAmountController.text == '1000',
                  onSelected: (bool selected) {
                    setState(() {
                      choiceAmountController.text =
                      (selected ? '1000' : '');
                      print("10::---$choiceAmountController");
                    });
                  },
                  selectedColor: colors.secondary2
                //Color(0xff699a8d),
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
                        color: colors.blackTemp, fontSize: 20)),
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
                //Color(0xff699a8d),
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
                label: Text('5000',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: colors.blackTemp, fontSize: 20)),
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
                // side: BorderSide(width: 1, color: Color(0xff0C3B2E)),
                backgroundColor: colors.secondary2.withOpacity(0.5),
                label: Text('10000',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: colors.blackTemp, fontSize: 20)),
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
    );
  }

  Future <void> deleteBankDetail (String id) async{
    var headers = {
      'Cookie': 'ci_session=6ea9035eb03c3b37384816f4b92b8b4957a8b7bd'
    };
    var request = http.MultipartRequest('POST', Uri.parse('${baseUrl}delete_user_payment_option/$id'));
    request.headers.addAll(headers);
    print('${request.url}');
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var finalResult = await response.stream.bytesToString();
      final jsonResponse = json.decode(finalResult);
      print("final response here ${jsonResponse}");
      bankDetail.removeWhere((element) => element.id.toString() == id);
      setState(() {
      });
      Fluttertoast.showToast(msg: "${jsonResponse['message']}");
    }
    else {
      print(response.reasonPhrase);
    }
  }
}

