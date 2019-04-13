import 'package:flutter/material.dart';
import '../service/service_method.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'dart:convert';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin {

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
  
  @override
  void initState() {
    print('---------');
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white12,
      appBar: AppBar(
        title: Text('百姓生活+'),
      ),
      body: FutureBuilder(
          future: request('homePageContent', {'lon': '115.02932', 'lat': '35.76189'}),
          builder:(context,snapshot){
            if(snapshot.hasData){
              var data = json.decode(snapshot.data.toString());
              List<Map> swiperDataList = (data['data']['slides'] as List).cast();//顶部轮播组件
              List<Map> navigatorList = (data['data']['category'] as List).cast();//类别列表
              String advertesPicture = data['data']['advertesPicture']['PICTURE_ADDRESS'];//广告图片
              String leaderImage = data['data']['shopInfo']['leaderImage'];//店长图片
              String leaderPhone = data['data']['shopInfo']['leaderPhone'];//店长电话
              List<Map> recommendList = (data['data']['recommend'] as List).cast();//商品推荐

              String floor1Title = data['data']['floor1Pic']['PICTURE_ADDRESS'];//楼层1的标题图片
              String floor2Title = data['data']['floor2Pic']['PICTURE_ADDRESS'];//楼层2的标题图片
              String floor3Title = data['data']['floor3Pic']['PICTURE_ADDRESS'];//楼层3的标题图片

              List<Map> floor1 = (data['data']['floor1'] as List).cast();//楼层1商品和图片
              List<Map> floor2 = (data['data']['floor2'] as List).cast();//楼层2商品和图片
              List<Map> floor3 = (data['data']['floor3'] as List).cast();//楼层3商品和图片

              //后台返回数据超过10了，作个限制
              if(navigatorList.length > 10){
                navigatorList.removeRange(10, navigatorList.length);
              }

              return SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Myswiper(myswiperDataList: swiperDataList),//页面顶部轮播控件
                    TopNavigator(navigatorList: navigatorList),//导航组件
                    AdBanner(advPicture: advertesPicture,),//广告组件
                    LeaderPhone(leaderImage: leaderImage,leaderPhone: leaderPhone),//店长模块组件
                    Recommend(recommendList: recommendList),//商品推荐
                    //楼层1
                    FloorTitle(pictureAddress: floor1Title),
                    FloorContent(floorGoodsList: floor1),
                    //楼层2
                    FloorTitle(pictureAddress: floor2Title),
                    FloorContent(floorGoodsList: floor2),
                    //楼层3
                    FloorTitle(pictureAddress: floor3Title),
                    FloorContent(floorGoodsList: floor3),

                    HotGoods(),

                  ],
                ),
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
          Text(item['mallCategoryName']),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: ScreenUtil().setHeight(260),
      padding: EdgeInsets.all(4.0),
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
        onTap: _launchURL,
        child: Image.network(leaderImage),
      ),
    );
  }

  void _launchURL() async{
    String url = 'tel:'+leaderPhone;
    print('----$url');
    if(await canLaunch(url)){
      await launch(url);
    }else{
      throw 'Could not lauch $url';
    }
  }

}

//推荐商品类的编写
class Recommend extends StatelessWidget {

  final List recommendList;
  Recommend({Key key,this.recommendList}):super(key:key);

  //推荐商品标题
  Widget _titleWidget(){
    return Container(
       alignment: Alignment.centerLeft,
       padding: EdgeInsets.fromLTRB(10.0, 5.0, 0, 20.0),
       decoration: BoxDecoration(
         color: Colors.white,
         border: Border(
           bottom: BorderSide(width: 0.5,color: Colors.black12)
         )
       ),
      child: Text(
        '商品推荐',
        style: TextStyle(color: Colors.pink),
      ),
    );
  }

  //横向列表子项
  Widget _item(index){
    return InkWell(
      onTap: (){},
      child: Container(
        height: ScreenUtil().setHeight(280),
        width: ScreenUtil().setWidth(250),
        padding: EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            left: BorderSide(width: 0.5,color: Colors.black12)
          )
        ),
        child: Column(
          children: <Widget>[
            Image.network(recommendList[index]['image']),
            Container(
              padding: EdgeInsets.only(top: 5.0),
              child: Text('¥${recommendList[index]['mallPrice']}'),
            ),
            Text(
              '¥${recommendList[index]['price']}',
               style: TextStyle(
                 decoration: TextDecoration.lineThrough,
                 color: Colors.grey
               ),
            )
          ],
        ),
      ),
    );
  }

  //横向列表组件的编写
  Widget _recommedList(){
    return Container(
      height: ScreenUtil().setHeight(280),
      child: ListView.builder(
          scrollDirection:Axis.horizontal,
          itemCount: recommendList.length,
          itemBuilder:(context,index){
            return _item(index);
          }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: ScreenUtil().setHeight(350),
      margin: EdgeInsets.only(top: 10.0),
      child: Column(
        children: <Widget>[
          _titleWidget(),
          _recommedList()
        ],
      ),
    );
  }
}

//楼层标题组件
class FloorTitle extends StatelessWidget {

  final String pictureAddress;//图片地址
  FloorTitle({Key key,this.pictureAddress}):super(key:key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: Image.network(pictureAddress),
    );
  }
}

//楼层商品组件
class FloorContent extends StatelessWidget {

  final List floorGoodsList;
  FloorContent({Key key,this.floorGoodsList}):super(key:key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          _firstRow(),
          _otherGoods()
        ],
      ),
    );
  }

  //第一行商品
  Widget _firstRow(){
    return Row(
      children: <Widget>[
        _goodsItem(floorGoodsList[0]),
        Column(
          children: <Widget>[
            _goodsItem(floorGoodsList[1]),
            _goodsItem(floorGoodsList[2]),
          ],
        )
      ],
    );
  }

  //第二行商品
  Widget _otherGoods(){
    return Row(
      children: <Widget>[
        _goodsItem(floorGoodsList[3]),
        _goodsItem(floorGoodsList[4]),
      ],
    );
  }

  //最小单元
  Widget _goodsItem(Map goods){
    return Container(
      width: ScreenUtil().setWidth(375),
      child: InkWell(
        onTap: (){print('点击了楼层商品');},
        child: Image.network(goods['image']),
      ),
    );
  }

}


//火爆商区商品组件
class HotGoods extends StatefulWidget {
  @override
  _HotGoodsState createState() => _HotGoodsState();
}

class _HotGoodsState extends State<HotGoods> {

  @override
  void initState() {
    super.initState();
    request('homePageBelowConten', 1).then((val){
      print("hotGoods-----$val");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('2222222222'),
    );
  }
}



