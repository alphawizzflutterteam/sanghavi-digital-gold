import 'dart:async';

import 'package:atticadesign/Helper/Session.dart';
import 'package:atticadesign/Utils/ApiBaseHelper.dart';
import 'package:atticadesign/Utils/constant.dart';
import 'package:flutter/material.dart';

class LivePriceProvider extends ChangeNotifier{
  String _gold1 = '',
      _gold2 = '';
  ApiBaseHelper apiBase = new ApiBaseHelper();


  String get gold1 => _gold1;
  String get gold2 => _gold2;

  void setGold916(String val){
    _gold1 = val;
    notifyListeners();
  }
  void setGold999(String val){
    _gold2 = val;
    notifyListeners();
  }

  getLivePrice(BuildContext context) async {
    try {
      // setState(() {
      //   cartList.clear();
      // });
      Map params = {
        // "get_user_cart": "1",
        // "user_id": App.localStorage.getString("userId").toString(),
      };
      Map response = await apiBase.postAPICall(
          Uri.parse(livePrice), params);
      if (response.isNotEmpty) {
        //context.read<LivePriceProvider>().setGold916(response['data']['916_gold_charge'].toString());
        setGold916(response['data']['916_gold_charge'].toString());
       setGold999(response['data']['999_gold_charge'].toString());
        // cartList.clear();
        // for (var v in response['cart_data']) {
        //   setState(() {
        //     cartList.add(CartData.fromJson(v));
        //   });
        // }
        // totalCount = cartList.length;
        print("gold-916 is@@ ${response['data']['916_gold_charge'].toString()}");
        print("gold-999 is** ${response['data']['999_gold_charge'].toString()}");
      }
    } on TimeoutException catch (_) {
      setSnackbar("Something Went Wrong", context);
      notifyListeners();
    }
  }
}