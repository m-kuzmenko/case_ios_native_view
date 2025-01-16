import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const String viewType = 'com.case_ios_native_view/snow';

class PresentPage extends StatelessWidget {
  const PresentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Подарок'),
      ),
      child: Stack(fit: StackFit.expand, children: [
        Center(
          child: Icon(
            CupertinoIcons.car,
            size: 100,
          ),
        ),
        UiKitView(
          viewType: viewType,
          layoutDirection: TextDirection.ltr,
          creationParamsCodec: const StandardMessageCodec(),
          onPlatformViewCreated: (id) {
            _onIOSPlatformViewCreated(context, id);
          },
        )
      ]),
    );
  }

  Future<void> _onIOSPlatformViewCreated(BuildContext context, int id) async {
    if (!context.mounted) {
      return;
    }
    print('Created native platform view $viewType with id $id');
    await Future.delayed(Durations.short4);

    try {
      MethodChannel('$viewType$id').invokeMethod<int>('startAnimation');
    } on PlatformException catch (e) {
      print(
          "Failed to call startAnimation in methodChanel $viewType$id: '${e.message}'.");
    }
  }
}
