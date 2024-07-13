import 'dart:async';

import 'package:atticadesign/Helper/Color.dart';
import 'package:atticadesign/Helper/Session.dart';
import 'package:atticadesign/Model/order_model.dart';
import 'package:atticadesign/Utils/ApiBaseHelper.dart';
import 'package:atticadesign/Utils/Common.dart';
import 'package:atticadesign/Utils/colors.dart';
import 'package:atticadesign/Utils/widget.dart';
import 'package:atticadesign/new_cart.dart';
import 'package:atticadesign/notifications.dart';
import 'package:flutter/material.dart';

import '../Utils/constant.dart';
import 'cart_product_view.dart';
import 'order_details.dart';

class OrderHistory extends StatefulWidget {
  const OrderHistory({Key? key}) : super(key: key);

  @override
  State<OrderHistory> createState() => _OrderHistoryState();
}

class _OrderHistoryState extends State<OrderHistory> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getOrderList();
  }


  @override
  Widget build(BuildContext context) {
    return  Scaffold(
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
          "Order History",
          style: TextStyle(
            color: colors.black54,
            fontSize: 20,
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
                      color: colors.secondary2)),
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
                        color: colors.secondary2)),
              ),
            ],
          )
        ],
      ),
      body: loadingWish
          ? orderList.length > 0
          ? ListView.builder(
          itemCount: orderList.length,
          physics: BouncingScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return OrderView(
              orderList[index],
                  () async {
                var result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            OrderDetailsScreen(
                                orderList[index])));
              },
            );
          })
          : Center(
          child: Container(
            height: 500,
            child: text("No Order Available",
                textColor: Theme.of(context).colorScheme.black),
          ))
          : Center(
        child: CircularProgressIndicator(
          color: MyColorName.primaryDark,
        ),
      ),
    );
  }

  List<OrderModel> orderList = [];
  bool loadingWish = false;
  ApiBaseHelper apiBase = new ApiBaseHelper();



  getOrderList() async {
    try {
      setState(() {
        loadingWish = false;
        orderList.clear();
      });
      Map params = {
        "get_favorites": "1",
        "user_id": App.localStorage.getString("userId").toString(),
        "limit": "10",
      };
      Map response =
      await apiBase.postAPICall(Uri.parse(baseUrl + "get_orders"), params);
      setState(() {
        loadingWish = true;
      });
      if (!response['error']) {
        for (var v in response['data']) {
          setState(() {
            orderList.add( OrderModel.fromJson(v));
          });
        }
      } else {
        setState(() {
          likeCount = 0;
        });
      }
    } on TimeoutException catch (_) {
      setSnackbar("Something Went Wrong", context);
      setState(() {
        loadingWish = true;
      });
    }
  }


}
