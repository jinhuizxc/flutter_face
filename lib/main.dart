import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:dio/dio.dart';

// 将图片从File转成Base64的库
import 'dart:convert';

/*
 * flutter_face + 百度人脸识别;
 *
 * https://www.liulongbin.top/
 *
 * Flutter开发中常用的快捷键
 * https://www.jianshu.com/p/b9efacbf6c34
 *
 * 百度AI平台：
 * 颜值大师

AppID 16889598

API Key Pbho8aGqK3u6aW1xidM9sSs1

Secret Key daVoxYCvz40kZ6qdSzVx6hwZTrHlGNNx
 */

// 初始化网络库dio
Dio dio = new Dio();

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

/*
* 之所以加进度条, 是因为拍照获取得到的图片采集响应太慢了！！！
 */
class _MyHomePageState extends State<MyHomePage> {
  // false 为不显示 loading
  // true 为显示 loading
  bool isloading = false;

  // 性别
  Map genderMap = {'male': '男', 'female': '女'};

// 表情
  Map expressionMap = {'none': '不笑', 'smile': '微笑', 'laugh': '大笑'};

  // 眼镜
  Map glassesMap = {'none': '无眼镜', 'common': '普通眼镜', 'sun': '墨镜'};

  // 情绪
  Map emotionMap = {
    'angry': '愤怒',
    'disgust': '厌恶',
    'fear': '恐惧',
    'happy': '高兴',
    'sad': '伤心',
    'surprise': '惊讶',
    'neutral': '无情绪'
  };

  // 用户通过摄像头或图片库选择的照片, 需要导入io库
  File _image;
  var _faceInfo;

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
    /*return Image.file(
      _image,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
    );*/
    // Stack 如同FrameLayout一样，帧布局
    return Stack(
      children: <Widget>[
        Image.file(
          _image,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
        renderFaceInfo(),
      ],
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

  /*
   * I/flutter: 获取到的结果: {
   * "refresh_token":"25.d88fd67ce4ddb40ecec0f88ab13f5337.315360000.1879429073.282335-16889598",
   * "expires_in":2592000,"session_key":"9mzdCy1Fy6CxZJH6eDVxxU4vbM3zkRDDG4QwagNNaKkg6GqXR+e9tsXHw+2E8Zmlqv7p3DEZ25e6Cx5UJBhmvmO5AhpeAg==",
   * "access_token":"24.05a9eb7bf2fc181ddeaba0093a09ec38.2592000.1566661073.282335-16889598",
   * "scope":"public brain_all_scope vis-faceverify_faceverify_h5-face-liveness vis-faceverify_FACE_V3 wise_adapt lebo_resource_base lightservice_public hetu_basic lightcms_map_poi kaidian_kaidian ApsMisTest_Test权限 vis-classify_flower lpq_开放 cop_helloScope ApsMis_fangdi_permission smartapp_snsapi_base iop_autocar oauth_tp_app smartapp_smart_game_openapi oauth_sessionkey smartapp_swanid_verify smartapp_opensource_openapi smartapp_opensource_recapi fake_face_detect_开放Scope",
   * "session_secret":"138b510d26076d11467a59ddcc3c0821"}
   */
  Future getFaceInfo() async {
    // 只要调用这个函数，就立即展示 loading 效果
    setState(() {
      isloading = true;
    });

    var url =
        'https://aip.baidubce.com/oauth/2.0/token?grant_type=client_credentials&client_id=Pbho8aGqK3u6aW1xidM9sSs1&client_secret=daVoxYCvz40kZ6qdSzVx6hwZTrHlGNNx';
    var response = await dio.post(url);
    print('获取到的结果: ' + response.toString());

    // 在Flutter中获取对象的属性，要使用[]
    var access_token = response.data['access_token'];
    print('获取到的access_token = ' +
        access_token); // I/flutter: 获取到的access_token = 24.d98ab522dce563600eb16b1b91040888.2592000.1566661257.282335-16889598

    // 鉴权失败
    if (response.data['access_token'] == null) {
      // 鉴权失败，隐藏 loading 效果
      setState(() {
        isloading = false;
      });
      return;
    }

    // 鉴权成功
    // 检测人脸信息
    var url2 =
        'https://aip.baidubce.com/rest/2.0/face/v3/detect?access_token=' +
            access_token;

    // 将照片转换为字节数组
    var imageBytes = await _image.readAsBytes();
    // 将字节数组转换为 base64 格式的字符串
    var imageBase64 = base64Encode(imageBytes);

    // 添加请求头
    var faceInfoResult = await dio.post(url2,
        // 请求配置
        options: Options(contentType: ContentType.json),
        // 发送到后台的 body 数据
        data: {
          'image': imageBase64, //  图片信息(总数据大小应小于10M)
          'image_type': 'BASE64',
          // face_field 是要获取的人脸信息字段，
          // 年龄，性别，颜值，表情，眼镜，情绪
          'face_field': 'age,gender,beauty,expression,glasses,emotion'
        });

    print('获取到人脸信息 = ' +
        faceInfoResult
            .toString()); // I/flutter: 获取到人脸信息 = Instance of 'Future<Response<dynamic>>'  需要添加await 异步操作
    /*
     * 获取到人脸信息 = {"error_code":0,"error_msg":"SUCCESS",
     * "log_id":747956940705524661,"timestamp":1564070552,"cached":0,
     * "result":{"face_num":1,
     * "face_list":[{"face_token":"6be976aaa32b125e825418e016394e80",
     * "location":{"left":220.03,"top":102.52,"width":92,"height":88,"rotation":-5},
     * "face_probability":1,"angle":{"yaw":22.86,"pitch":12.54,"roll":-12.08},
     * "age":23,
     * "gender":{"type":"male","probability":1},
     * "beauty":74.96,
     * "expression":{"type":"none","probability":1},
     * "glasses":{"type":"none","probability":1},
     * "emotion":{"type":"neutral","probability":0.82}}]}}
     */

    // 检测失败
    if (faceInfoResult.data['error_msg'] != 'SUCCESS' ||
        faceInfoResult.data['result']['face_num'] <= 0) {
      // 检测失败，隐藏 loading 效果
      setState(() {
        isloading = false;
      });
      // ... 省略不必要的代码
      return;
    }

    // 检测成功，隐藏 loading 效果
    if (faceInfoResult.data['error_msg'] == 'SUCCESS') {
      setState(() {
        isloading = false;
        _faceInfo = faceInfoResult.data['result']['face_list'][0];
      });
    } else {
      print('获取人脸信息失败...');
    }
  }

  // 渲染识别出来的人脸信息
  Widget renderFaceInfo() {
    // 如果人脸信息为空，则渲染空字符串
    if (_faceInfo == null) {
      //如果 isloading 为 true，就在页面正中央渲染 loading 效果
      if (isloading) {
        // 加载进度条
        return Center(child: CircularProgressIndicator());
      }
      return Text('_faceInfo = null');
    }
    return Center(
      /*
           * 设置圆角
           *  decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10.0)))
           */
      // 渲染矩形盒子区域
      child: Container(
        decoration: BoxDecoration(
            // 背景颜色【半透明的白色】
            color: Colors.white54,
            // 圆角
            borderRadius: BorderRadius.all(Radius.circular(5))),
        // 如果定义圆角的话这里的颜色属性就要去掉;
//        color: Colors.white54,
        width: 300,
        height: 200,
        child: Column(
          // 子元素在纵轴上分散对齐
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Row(
              // 子元素在横轴上分散对齐
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Text('年龄: ${_faceInfo['age']}岁'),
                Text('性别: ' + genderMap[_faceInfo['gender']['type']]),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Text('颜值: ${_faceInfo['beauty']}分'),
                Text('表情: ' + expressionMap[_faceInfo['expression']['type']]),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Text('眼镜:  ' + glassesMap[_faceInfo['glasses']['type']]),
                Text('情绪: ' + emotionMap[_faceInfo['emotion']['type']]),
              ],
            )
          ],
        ),
      ),
    );
  }
}
