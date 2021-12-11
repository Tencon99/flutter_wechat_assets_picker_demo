///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2021/7/13 11:46
///
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart'
    show
        AssetEntity,
        DefaultAssetPickerProvider,
        DefaultAssetPickerBuilderDelegate;
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import '../widgets/method_list_view.dart';
import '../widgets/selected_assets_list_view.dart';
import 'picker_method.dart';

mixin ExamplePageMixin<T extends StatefulWidget> on State<T> {
  final ValueNotifier<bool> isDisplayingDetail = ValueNotifier<bool>(true);

  @override
  void dispose() {
    isDisplayingDetail.dispose();
    super.dispose();
  }

  int get maxAssetsCount;

  List<AssetEntity> assets = <AssetEntity>[];

  int get assetsLength => assets.length;

  List<PickMethod> get pickMethods;

  ///这些字段是保持滚动位置功能。
  late DefaultAssetPickerProvider keepScrollProvider =
      DefaultAssetPickerProvider();
  DefaultAssetPickerBuilderDelegate? keepScrollDelegate;

  Future<void> selectAssets(PickMethod model) async {
    final List<AssetEntity>? result = await model.method(context, assets);
    if (result != null) {
      assets = List<AssetEntity>.from(result);
      // 对选中图片进行压缩
      for (final AssetEntity item in assets) {
        if(item.type == AssetType.image){
          final File? file = await item.originFile; 
          final Directory _temp = await getTemporaryDirectory();
          final String _path = _temp.path;
          // 将要压缩的文件本地路径
          final String path =  file!.path;
          // 将要压缩的文件名称
          final String name = path.substring(path.lastIndexOf('/') +1,path.length);//todo---> name =  uuid+ '_' + name
          FlutterImageCompress.compressAndGetFile(path,'$_path/img_$name',quality: 50).then((File? value) {
            log('压缩前的原文件路径、大小----> 路径：${file.path} 原文件大小--->${file.lengthSync()/1024/1024}M');
            log('压缩后的文件路径、大小----> 路径：${value!.path} 文件大小--->${value.lengthSync()/1024/1024}M');
          });
        }
      }
      if (mounted) {
        setState(() {});
      }
    }
  }

  void removeAsset(int index) {
    assets.removeAt(index);
    if (assets.isEmpty) {
      isDisplayingDetail.value = false;
    }
    setState(() {});
  }

  Future<void> onResult(List<AssetEntity>? result) async {
    if (result != null && result != assets) {
      assets = List<AssetEntity>.from(result);
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  @mustCallSuper
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: <Widget>[
        Expanded(
          child: MethodListView(
            pickMethods: pickMethods,
            onSelectMethod: selectAssets,
          ),
        ),
        if (assets.isNotEmpty)
          SelectedAssetsListView(
            assets: assets,
            isDisplayingDetail: isDisplayingDetail,
            onResult: onResult,
            onRemoveAsset: removeAsset,
          ),
      ],
    );
  }
}
