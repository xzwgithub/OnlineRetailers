import 'package:flutter/material.dart';
import '../service/service_method.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'dart:convert';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  
  String homePageContent='正在获取数据';
  
  @override
  void initState() {
    getHomePageContent().then((val){
        setState(() {
            homePageContent = val.toString();
        });
    });
    
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.greenAccent,
      appBar: AppBar(
        title: Text('百姓生活+'),
      ),
      body: FutureBuilder(
          future: getHomePageContent(),
          builder:(context,snapshot){
            if(snapshot.hasData){
              var data = json.decode(snapshot.data.toString());
              List<Map> swiperDataList = (data['data']['slides'] as List).cast();//顶部轮播组件
              List<Map> navigatorList = (data['data']['category'] as List).cast();//类别列表
              String advertesPicture = data['data']['advertesPicture']['PICTURE_ADDRESS'];//广告图片
              String leaderImage = data['data']['shopInfo']['leaderImage'];//店长图片
              String leaderPhone = data['data']['shopInfo']['leaderPhone'];//店长电话

              //后台返回数据超过10了，作个限制
              if(navigatorList.length > 10){
                navigatorList.removeRange(10, navigatorList.length);
              }

              return Column(
                children: <Widget>[
                  Myswiper(myswiperDataList: swiperDataList),//页面顶部轮播控件
                  TopNavigator(navigatorList: navigatorList),//导航组件
                  AdBanner(advPicture: advertesPicture,),//广告组件
                  LeaderPhone(leaderImage: leaderImage,leaderPhone: leaderPhone),//店长模块组件
                ],
              );
            }else{
              return Center(
                child: Text('加载中...'),
              );
            }
          }
      )
    );
  }

}

//首页轮播控件编写
class Myswiper extends StatelessWidget {

  final List myswiperDataList;

  Myswiper({Key key,this.myswiperDataList}):super(key:key);

  @override
  Widget build(BuildContext context) {
    
    return Container(
       width: ScreenUtil().setWidth(750),
       height: ScreenUtil().setHeight(320),
       child: Swiper(
           itemCount:myswiperDataList.length,
           itemBuilder: (BuildContext context,int index){
             return Image.network('${myswiperDataList[index]['image']}',fit: BoxFit.fill,);
           },
           pagination:SwiperPagination(),
           autoplay: true,
       ),
    );
  }
}

//导航单元素的编写
class TopNavigator extends StatelessWidget {

  final List navigatorList;

  TopNavigator({Key key,this.navigatorList}):super(key:key);

  //自定义控件
  Widget _gridViewItemUI(BuildContext context,item){
    //点击有水波效果
    return InkWell(
      onTap: (){print('点击了导航');},
      child: Column(
        children: <Widget>[
          Image.network(item['image'],width:ScreenUtil().setWidth(95)),
          Text(item['mallCategoryName'])
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: ScreenUtil().setHeight(260),
      padding: EdgeInsets.all(10.0),
      child: GridView.count(//网格控件
          crossAxisCount:5,
          padding: EdgeInsets.all(4.0),
          children: navigatorList.map((item){
            return _gridViewItemUI(context, item);
          }).toList(),
      ),
    );
  }
}

//AdBanner组件的编写
class AdBanner extends StatelessWidget {

  final String advPicture;

  AdBanner({Key key,this.advPicture}):super(key:key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Image.network(advPicture),
    );
  }
}

//编写店长电话模块
class LeaderPhone extends StatelessWidget {

  final String leaderImage;//店长图片
  final String leaderPhone;//店长电话

  LeaderPhone({Key key,this.leaderImage,this.leaderPhone}):super(key:key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: InkWell(
        onTap: (){},
        child: Image.network(leaderImage),
      ),
    );
  }
}

