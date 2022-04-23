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
    _logger.v(message, error, stackTrace);
  }

  static void d(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error, stackTrace);
  }

  static void i(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error, stackTrace);
  }

  static void w(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error, stackTrace);
  }

  static void e(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error, stackTrace);
  }

  static void wtf(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error, stackTrace);
  }

  static void close() {
    _logger.close();
  }
}
