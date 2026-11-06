import 'package:logger/logger.dart';

/*
* @description: 对logger进行简单封装
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/17
*/
class LogUtils {
  static Logger _logger = Logger(
    filter: null,
    printer: PrettyPrinter(),
    output: null,
  );

  static void forceOpenLog() {
    _logger = Logger(
      filter: ProductionFilter(),
      printer: PrettyPrinter(),
      output: null,
    );
  }

  static void v(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.t(message, error: error, stackTrace: stackTrace);
  }

  static void d(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  static void i(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  static void w(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  static void e(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  static void wtf(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }

  static void close() {
    _logger.close();
  }
}
