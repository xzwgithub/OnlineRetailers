import 'package:dio/dio.dart';
import 'dart:async';
import 'dart:io';
import '../config/service_url.dart';


//获取数据通用方法
Future request(String url,dynamic data)async{
  try{
    print('$url:开始获取数据...');
    Response response;
    Dio dio = new Dio();
    dio.options.contentType =
        ContentType.parse('application/x-www-form-urlencoded');
    if(data == null){
      response = await dio.post(servicePath[url]);
    }else{
      response = await dio.post(servicePath[url], data: data);
    }

    if (response.statusCode == 200) {
      return response.data;
    }
    else{
      throw Exception('后端接口出现异常，请检查代码和服务器情况...');
    }
  }catch(e){
    return print('Error:$url==>$e');
  }
}


