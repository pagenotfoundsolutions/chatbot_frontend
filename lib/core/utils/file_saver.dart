import 'dart:js_interop';
import 'dart:typed_data';
import 'package:web/web.dart' as web;

/// Triggers a browser "Save As" download for the given bytes.
///
/// Web-only (uses `package:web`), consistent with the app's web target.
class FileSaver {
  static void saveBytes(List<int> bytes, String filename, String mimeType) {
    final data = bytes is Uint8List ? bytes : Uint8List.fromList(bytes);
    final type = mimeType.isEmpty ? 'application/octet-stream' : mimeType;

    final blob = web.Blob(
      <JSAny>[data.toJS].toJS,
      web.BlobPropertyBag(type: type),
    );
    final url = web.URL.createObjectURL(blob);

    final anchor = web.HTMLAnchorElement()
      ..href = url
      ..download = filename
      ..style.display = 'none';
    web.document.body?.appendChild(anchor);
    anchor.click();
    anchor.remove();

    web.URL.revokeObjectURL(url);
  }
}
