
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';


import 'package:atticadesign/Model/order_model.dart';
import 'package:atticadesign/Utils/ApiBaseHelper.dart';
import 'package:atticadesign/Utils/Session.dart';
import 'package:atticadesign/Utils/colors.dart';
import 'package:atticadesign/Utils/constant.dart';
import 'package:atticadesign/Utils/widget.dart';
import 'package:atticadesign/screen/add_order_review.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sizer/sizer.dart';
import 'dart:ui' as ui;

import '../Helper/Color.dart';
class OrderDetailsScreen extends StatefulWidget {
  OrderModel model;


  OrderDetailsScreen(this.model);

  @override
  _OrderDetailsScreenState createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  OrderModel? model;
  GlobalKey globalKey = GlobalKey();
  Map<String,Color> colorStatus = {
    "received": colors.blackTemp,
    //Colors.orange,
    "cancelled":Colors.red,
    "delivered":Colors.green,
    "shipped":Colors.deepOrange,
    "processed":Colors.yellow,
  };
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    model = widget.model;
   // getCurrentPro();
  }
  double subTotal=0,proDiscount = 0;
  ApiBaseHelper apiBase = new ApiBaseHelper();
  bool isNetwork = false;
  bool loading = true;

  Future<bool> backContext()async{
    Navigator.pop(context,"yes");
    return true;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Color(0xff0F261E),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: colors.primaryNew,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: InkWell(
            onTap: (){
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back,
              color: colors.secondary2,
            ),
          ),
        ),
        title: Text(
          "Order Details",
          style: TextStyle(
            color: colors.black54,
            fontSize: 20,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: InkWell(
                onTap: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => NotiPage()),
                  // );
                },
                child: Icon(Icons.notifications_active,
                    color:colors.secondary2)),
          ),
        ],
      ),
      body: WillPopScope(
        onWillPop: backContext,
        child: SingleChildScrollView(
          child: Container(
            width: 100.w,
            child: Column(
              children: [
                SizedBox(height: 2.h,),
                /*Container(
                  width: 83.33.w,
                  decoration:
                  boxDecoration(radius: 10.0, bgColor: colors.secondary2),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 78.10.w,
                      height: 18.51.h,
                      child: commonHWImage(
                          model!.orderItems![0].image,
                          18.51.h,
                          78.10.w,
                          "images/product/product0.png",
                          context,
                          "images/product/product0.png"
                      ),
                    ),
                  ),
                ),*/
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: model?.orderItems?.length ?? 0,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: getWidth(330),
                      height: getHeight(130),
                      margin: EdgeInsets.only(bottom: getHeight(10)),
                      decoration: boxDecoration(
                        radius: 15,
                        bgColor: colors.secondary2,
                      ),
                      padding: EdgeInsets.symmetric(
                          horizontal: getWidth(10), vertical: getHeight(10)),
                      child:   Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: commonHWImage(
                                model?.orderItems![index].image,
                                100.0,
                                100.0,
                                "images/product/product0.png",
                                context,
                                "images/product/product0.png"),
                          ),
                          Container(
                            width: getWidth(210),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: text(getString1(model?.orderItems?[index].name ?? ''),
                                          fontSize: 14.sp, fontFamily: fontRegular,textColor: colors.blackTemp),
                                    ),
                                    /*Column(
                                      children: [
                                        Icon(Icons.check_circle,color: back,),
                                        text(model.orderItems![0].activeStatus.toString(), fontSize: 8.sp, fontFamily: fontRegular,textColor: back),
                                      ],
                                    )*/
                                  ],
                                ),
                                Row(
                                  children: [
                                    text("₹"+(model?.orderItems?[index].price ?? ''),
                                        // orderItems![0].price.toString(),
                                        fontSize: 14.sp, fontFamily: fontMedium),
                                  ],
                                ),
                                boxHeight(20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        text("Qty. : ", fontSize: 10.sp, fontFamily: fontRegular),
                                        text(model?.orderItems?[index].quantity.toString() ?? '', fontSize: 10.sp, fontFamily: fontRegular),
                                      ],
                                    ),
                                    text(DateFormat("dd-MM-yyyy").format(DateTime.parse(model!.dateAdded!)),
                                      fontSize: 10.sp,
                                      fontFamily:
                                      fontMedium,
                                    )
                                  ],
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },),
                SizedBox(height: 2.h,),
                Container(
                  width: 83.33.w,
                  child: text(
                    "Order Details",
                    textColor: colors.blackTemp,
                    fontSize: 12.5.sp,
                    fontFamily: fontBold,
                  ),
                ),
                SizedBox(height: 4.h,),
                RepaintBoundary(
                  key: globalKey,
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    width: 83.33.w,
                    height:  20.37.h ,
                    decoration:
                    boxDecoration(radius: 10.0, bgColor: colors.secondary2),
                    child: Column(
                      children: [
                        SizedBox(height: 2.h,),
                        Center(
                          child: Container(
                            width: 75.10.w,
                            child: Row(
                              children: [
                                text(
                                  "Order Date",
                                  textColor: colors.blackTemp,
                                  fontSize: 10.sp,
                                  fontFamily: fontRegular,
                                  isCentered: true,
                                ),
                                SizedBox(width: 3.w,),
                                text(
                                  getDate(model!.dateAdded),
                                  textColor: colors.blackTemp,
                                  fontSize: 10.sp,
                                  fontFamily: fontRegular,
                                  isCentered: true,
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 2.h,),
                        Container(
                          width: 75.10.w,
                          child: Row(
                            children: [
                              text(
                                "Order Time",
                                textColor: colors.blackTemp,
                                fontSize: 10.sp,
                                fontFamily: fontRegular,
                                isCentered: true,
                              ),
                              SizedBox(width: 3.w,),
                              text(
                                "- ${ getTime(model!.dateAdded)}",
                                textColor: colors.blackTemp,
                                fontSize: 10.sp,
                                fontFamily: fontRegular,
                                isCentered: true,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 2.h,),
                        Container(
                          width: 75.10.w,
                          child: Row(
                            children: [
                              text(
                                "Order Total",
                                textColor: colors.blackTemp,
                                fontSize: 10.sp,
                                fontFamily: fontRegular,
                                isCentered: true,
                              ),
                              SizedBox(width: 3.w,),
                              text(
                                "₹${getString1((double.parse(model!.finalTotal!.toString()) - double.parse(model!.deliveryCharge.toString())).toString())}",
                                textColor: colors.blackTemp,
                                fontSize: 10.sp,
                                fontFamily: fontRegular,
                                isCentered: true,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 2.h,),
                        Container(
                          width: 75.10.w,
                          child: Row(
                            children: [
                              text(
                                "Order Id #",
                                textColor: colors.blackTemp,
                                fontSize: 10.sp,
                                fontFamily: fontRegular,
                                isCentered: true,
                              ),
                              SizedBox(width: 3.w,),
                              text(
                                model!.id.toString(),
                                textColor: colors.blackTemp,
                                fontSize: 10.sp,
                                fontFamily: fontRegular,
                                isCentered: true,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 2.h,),
                Container(
                  width: 83.33.w,
                  child: text(
                    "Shipping Details",
                    textColor: colors.blackTemp,
                    fontSize: 12.5.sp,
                    fontFamily: fontBold,
                    isCentered: false,
                  ),
                ),
                SizedBox(height: 2.h,),
                AnimatedContainer(
                  duration: Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  width: getWidth1(625),
                  height:  getHeight1(246) ,
                  decoration:
                  boxDecoration(radius: 10.0, bgColor: colors.secondary2 ),
                  child: Column(
                    children: [
                      SizedBox(height: 2.h,),
                      Center(
                        child: Container(
                          width: 75.10.w,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              text(
                                "Order Status",
                                textColor: colors.blackTemp,
                                fontSize: 10.sp,fontFamily: fontRegular,

                                isCentered: true,
                              ),
                              SizedBox(width: 3.w,),
                              checkIf(model!.orderItems![0].activeStatus)?Row(
                                children: [
                                  text(
                                    getString1(model!.orderItems![0].activeStatus.toString()),
                                    textColor: colorStatus[model!.orderItems![0].activeStatus],
                                    fontSize: 8.sp,
                                    fontFamily: fontSemibold,
                                    isCentered: true,
                                  ),
                                  SizedBox(width: 2,),
                                  Container(
                                    width: getWidth1(40),
                                    height: getWidth1(40),
                                    decoration: boxDecoration(radius: 100,bgColor:colorStatus[model!.orderItems![0].activeStatus]!),
                                    child: Center(
                                      child: Icon(
                                        model!.orderItems![0].activeStatus=="cancelled"?Icons.close:Icons.check,
                                        size: 12.sp,
                                        color: colors.white1,
                                      ),
                                    ),
                                  ),
                                ],
                              ):SizedBox(),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 1.h,),
                      Divider(
                        color:colors.blackTemp ,
                      ),
                      SizedBox(height: 1.h,),
                      Container(
                        width: 80.10.w,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            text(
                              "Billing Address",
                              textColor: colors.blackTemp,
                              fontSize: 10.sp,
                              fontFamily: fontSemibold,
                              isCentered: true,
                            ),
                            SizedBox(height: 2.w,),
                            text(
                              getString1(model!.address.toString()),
                              textColor: colors.blackTemp,
                              fontSize: 10.sp,
                              fontFamily: fontRegular,
                              isCentered: false,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 2.h,),
                Container(
                  width: 83.33.w,
                  child: text(
                    "Payment Information",
                    textColor: colors.blackTemp,
                    fontSize: 12.5.sp,
                    fontFamily: fontBold,
                    isCentered: false,
                  ),
                ),
                SizedBox(height: 2.h,),
                Container(
                  width: 86.80.w,
                  height: 7.42.h,
                  decoration: boxDecoration(
                    radius: 10,
                    bgColor: colors.secondary2,
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 5.w,),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      text(
                        "Payment Method",
                        fontSize: 10.sp,
                        fontFamily: fontSemibold,
                        textColor:colors.blackTemp,
                      ),
                      text(
                        getString1(model!.paymentMethod.toString()),
                        fontSize: 10.sp,
                        fontFamily: fontBold,
                        textColor: colors.blackTemp,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 2.h,),
                Container(
                  width: 83.33.w,
                  child: text(
                    "Order Summary",
                    textColor: colors.blackTemp,
                    fontSize: 12.5.sp,
                    fontFamily: fontBold,
                    isCentered: false,
                  ),
                ),
                SizedBox(height: 2.h,),
                Container(
                  width: 86.80.w,
                  decoration: boxDecoration(
                    radius: 10,
                    bgColor: colors.secondary2,
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 5.w,vertical: 1.6.h),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          text(
                            "Sub Total ( ${model!.orderItems!.length} Items)",
                            fontSize: 10.sp,
                            fontFamily: fontBold,
                            textColor: colors.blackTemp,
                          ),
                          text(
                            "₹${getString1(double.parse(model!.total.toString()).toString())}",
                            fontSize: 10.sp,
                            fontFamily: fontBold,
                            textColor: colors.blackTemp,
                          ),
                        ],
                      ),
                      SizedBox(height: 1.h,),
                      Divider(color: MyColorName.colorTextSecondary,),
                      SizedBox(height: 2.h,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          text(
                            "Voucher Discount",
                            fontSize: 10.sp,
                            fontFamily: fontRegular,
                            textColor: colors.blackTemp,
                          ),
                          text(
                            "-₹${getString1(model!.promoDiscount.toString())}",
                            fontSize: 10.sp,
                            fontFamily: fontRegular,
                            textColor: colors.blackTemp,
                          ),
                        ],
                      ),
                      /*SizedBox(height: 4.2.h,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          text(
                            "Wallet Amount Used" ,
                            fontSize: 10.sp,
                            fontFamily: fontRegular,
                            textColor: colors.blackTemp,
                          ),
                          text(
                            "-₹${getString1(model!.walletBalance.toString())}",
                            fontSize: 10.sp,
                            fontFamily: fontRegular,
                            textColor: colors.blackTemp,
                          ),
                        ],
                      ),*/
                      proDiscount>0?SizedBox(height: 4.2.h,):boxHeight(0),
                      proDiscount>0?Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          text(
                            "Pro Discount",
                            fontSize: 10.sp,
                            fontFamily: fontRegular,
                            textColor: colors.blackTemp,
                          ),
                          text(
                            "-₹${proDiscount}",
                            fontSize: 10.sp,
                            fontFamily: fontRegular,
                            textColor: colors.blackTemp,
                          ),
                        ],
                      ):boxHeight(0),
                      SizedBox(height: 4.2.h,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          text(
                            "Tax Rate",
                            fontSize: 10.sp,
                            fontFamily: fontRegular,
                            textColor: colors.blackTemp,
                          ),
                          text(
                            "${getString1(model!.orderItems![0].taxPercent.toString())}%",
                            fontSize: 10.sp,
                            fontFamily: fontRegular,
                            textColor: colors.blackTemp,
                          ),
                        ],
                      ),
                      SizedBox(height: 4.2.h,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          text(
                            "GST",
                            fontSize: 10.sp,
                            fontFamily: fontRegular,
                            textColor: colors.blackTemp,
                          ),
                          text(
                            "₹${getString1(model!.totalTaxAmount.toString())}",
                            fontSize: 10.sp,
                            fontFamily: fontRegular,
                            textColor: colors.blackTemp,
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h,),
                      Divider(color:  MyColorName.colorTextSecondary,),
                      SizedBox(height: 3.2.h,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          text(
                            "Total",
                            fontSize: 14.sp,
                            fontFamily: fontBold,
                            textColor: colors.blackTemp,
                          ),
                          text(
                            "₹${getString1((double.parse(model!.finalTotal!.toString()) - double.parse(model!.deliveryCharge.toString())).toString())}",
                            fontSize: 14.sp,
                            fontFamily: fontBold,
                            textColor: colors.blackTemp,
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                boxHeight(29),
                model!.orderItems![0].activeStatus!.toLowerCase()!="delivered"?InkWell(
                  onTap: (){
                    showDialog(context: context, builder: (BuildContext ctx){
                      return AddOrderReview(model!,ctx);
                    });
                  },
                  child: DottedBorder(
                      borderType: BorderType.RRect,
                      radius: Radius.circular(48),
                      color: colors.secondary2,
                      child: Container(
                        width: getWidth1(622),
                        height: getHeight1(88),
                        child: Center(
                          child: text(
                            "Give Feedback",
                            fontFamily: fontMedium,
                            fontSize: 14.sp,
                            textColor: colors.secondary2
                          ),
                        ),
                      )),
                ):SizedBox(),
                boxHeight(50),
              ],
            ),
          ),
        ),
      ),

    );
  }

  Future<void> _capturePng() async {
/*    RenderRepaintBoundary? boundary = globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary?;
    ui.Image image = await boundary!.toImage();
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();
    print(pngBytes);*/

  }
}
