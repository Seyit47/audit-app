import 'package:audit_mobile/core/config/server_address.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses and rebuilds an address', () {
    final a = ServerAddress.parse('http://216.250.13.114:3100');
    expect((a.host, a.port, a.https), ('216.250.13.114', 3100, false));
    expect(a.url, 'http://216.250.13.114:3100');
    final b = ServerAddress.parse('https://audit-api-5r1n.onrender.com');
    expect((b.host, b.port, b.https), ('audit-api-5r1n.onrender.com', null, true));
    expect(const ServerAddress(host: 'api.example.com', port: 8443).url, 'https://api.example.com:8443');
  });

  test('accepts IPs and domains, rejects junk', () {
    for (final ok in ['192.168.1.10', 'localhost', 'api.example.com', 'a-b.example.tm']) {
      expect(isValidHost(ok), isTrue, reason: ok);
    }
    for (final bad in ['', '300.1.1.1', 'http://x.com', 'example', 'exa mple.com', '1.2.3']) {
      expect(isValidHost(bad), isFalse, reason: bad);
    }
    expect([isValidPort('1'), isValidPort('65535'), isValidPort('0'), isValidPort('70000'), isValidPort('x')], [true, true, false, false, false]);
  });
}
