enum Flavor {
  hi,
  en,
}

class F {
  static Flavor? appFlavor;

  static String get name => appFlavor?.name ?? '';

  static String get title {
    switch (appFlavor) {
      case Flavor.hi:
        return 'चित्र पहेली';
      case Flavor.en:
        return 'PicPun';
      default:
        return 'title';
    }
  }

}
