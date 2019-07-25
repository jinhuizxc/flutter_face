import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

/*
 * flutter_face + 百度人脸识别;
 *
 * https://www.liulongbin.top/
 *
 * Flutter开发中常用的快捷键
 * https://www.jianshu.com/p/b9efacbf6c34
 */
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'flutter_face'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  // 用户通过摄像头或图片库选择的照片, 需要导入io库
  File _image;

  // 选择照片
  void choosePic(ImageSource source) async {
    var image = await ImagePicker.pickImage(source: source);

    // 设置照片   rn: this.setState()   小程序：this.setState{()}
    setState(() {
      _image = image;
    });

    print("选择的照片 = " + image.toString());
    // I/flutter: 选择的照片 = File: '/storage/emulated/0/DCIM/Camera/IMG_20190725_211557.jpg'
    // I/flutter: 选择的照片 = File: '/storage/emulated/0/Android/data/com.example.flutter_face/files/Pictures/c4ddf1e3-e6ac-49bf-92e5-a4a32e789fca7414828943492455094.jpg'

    // 调用api获取颜值信息
    getFaceInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: renderAppBar(),
      body: renderBody(),
      floatingActionButton: renderFloatActionButton(),
    );
  }

  /*
   * 渲染页面的主体区域
   */
  Widget renderBody() {
    if (_image == null) {
      // 并非居中，添加center使居中
      return Center(
        child: Text('请选择照片!'),
      );
    }
    return Image.file(
      _image,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
    );
  }

  /*
   * 渲染底部的浮动按钮区域
   */
  Widget renderFloatActionButton() {
    return ButtonBar(
        alignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          FloatingActionButton(
            onPressed: () {
              // 打开相机
              choosePic(ImageSource.camera);
            },
            tooltip: 'Increment',
            child: Icon(Icons.camera_alt),
          ),
          FloatingActionButton(
            // 打开相册
            onPressed: () {
              choosePic(ImageSource.gallery);
            },
            tooltip: 'Increment',
            child: Icon(Icons.photo_library),
          )
        ]);
  }

  /*
   * 渲染头部的appbar
   */
  Widget renderAppBar() {
    return AppBar(
      title: Text(widget.title),
    );
  }

  void getFaceInfo() {}
}
