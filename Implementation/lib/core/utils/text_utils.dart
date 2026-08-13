class TextUtils {
  static String limitText(String text, {int maxLength = 12}) {
    if (text.length <= maxLength) return text;
    // Automatically adds the dots if it truncates
    return "${text.substring(0, maxLength)}..";
  }
}