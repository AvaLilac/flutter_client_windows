import 'package:fluxer_app/core/observability/measure_log_redaction.dart';
import 'package:test/test.dart';

void main() {
  test('redactMeasureHttpUrl replaces host', () {
    expect(
      redactMeasureHttpUrl('https://secret.example.com/api/v9/users?token=abc'),
      'https://instance/api/v9/users',
    );
  });

  test('redactDomainsForMeasure strips hosts from text', () {
    expect(
      redactDomainsForMeasure('GET https://my.guild.host/channels failed'),
      'GET https://instance/channels failed',
    );
  });
}
