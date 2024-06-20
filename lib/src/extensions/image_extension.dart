



extension ImageExtension on String {

  String isImage({String? folderName}) {
    String result;
    if (folderName != null) {
      result = 'resources/img/$folderName/$this.png';
    } else {
      result = 'resources/img/$this.png';
    }
    return result;
  }

  String isIcon({String? folderName}) {
    String result;
    if (folderName != null) {
      result = 'resources/svg/$folderName/$this.svg';
    } else {
      result = 'resources/svg/$this.svg';
    }
    return result;
  }
}
