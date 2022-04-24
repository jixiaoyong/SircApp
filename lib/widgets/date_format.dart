/*
* @description: date format utils
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/24
*/
class DateFormat {
  // format yyyy to yy
  static String yyyyToYY(String yyyy) {
    return yyyy.substring(2);
  }

  // format m to mm
  static String mToMM(String m) {
    return m.length == 1 ? "0" + m : m;
  }

  // format yyyy to yy
  static String yyyyToYYInt(int yyyy) {
    return yyyyToYY(yyyy.toString());
  }

  // format m to mm
  static String mToMMInt(int m) {
    return mToMM(m.toString());
  }
}
