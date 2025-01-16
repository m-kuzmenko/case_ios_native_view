import 'package:case_ios_native_view/pages/present_page.dart';
import 'package:flutter/cupertino.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Center(
        child: CupertinoButton.filled(
          onPressed: () {
            Navigator.of(context)
                .push(CupertinoPageRoute(builder: (context) => PresentPage()));
          },
          child: Text('Получить подарок'),
        ),
      ),
    );
  }
}
