import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirc/routes/app_routes.dart';

import 'not_found_logic.dart';

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final logic = Get.put(NotFoundLogic());

    return Container(
      child: Column(
        children: [
          const Icon(Icons.details, size: 100),
          const Text('Not Found'),
          RaisedButton(
            child: const Text('Go to Home'),
            onPressed: () => Get.offAllNamed(AppRoutes.INITIAL),
          ),
        ],
      ),
    );
  }
}
