import 'package:web/web.dart' as web;

class ExternalLinkService {
  ExternalLinkService._();

  static final ExternalLinkService instance = ExternalLinkService._();

  void openInNewTab(String url) {
    web.window.open(url, '_blank');
  }
}
