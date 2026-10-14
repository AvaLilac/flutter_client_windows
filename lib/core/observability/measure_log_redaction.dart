const String _kRedactedMeasureHost = 'instance';

String redactMeasureHttpUrl(String url) {
  final Uri? uri = Uri.tryParse(url);
  if (uri == null || uri.host.isEmpty) {
    return url;
  }
  return Uri(
    scheme: uri.scheme,
    host: _kRedactedMeasureHost,
    path: uri.path,
    port: uri.hasPort ? uri.port : null,
  ).toString();
}

String redactDomainsForMeasure(String value) {
  if (value.isEmpty) {
    return value;
  }
  return value.replaceAllMapped(
    RegExp(
      r'https?://(?:[^\s/?#@]+@)?[^\s/?#:]+(?::\d+)?',
      caseSensitive: false,
    ),
    (Match match) {
      final String matched = match.group(0)!;
      if (matched.toLowerCase().startsWith('https://')) {
        return 'https://$_kRedactedMeasureHost';
      }
      return 'http://$_kRedactedMeasureHost';
    },
  );
}

Object sanitizeErrorForMeasure(Object error) {
  return _MeasureRedactedError(error);
}

StackTrace sanitizeStackTraceForMeasure(StackTrace stackTrace) {
  return StackTrace.fromString(redactDomainsForMeasure(stackTrace.toString()));
}

class _MeasureRedactedError implements Exception {
  _MeasureRedactedError(this._source);

  final Object _source;

  @override
  String toString() => redactDomainsForMeasure(_source.toString());
}
