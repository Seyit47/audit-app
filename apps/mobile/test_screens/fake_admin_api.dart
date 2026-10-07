import 'package:audit_mobile/features/admin/data/admin_api.dart';

/// Demo API data for rendering admin screens.
class FakeAdminApi implements AdminApi {
  static final _shops = [
    for (final (i, (name, type, status)) in [
      ('Al-Noor Retail Group', 'SUPERMARKET', 'ACTIVE'),
      ('Kamil market', 'MARKET', 'ACTIVE'),
      ('City Fresh Local Market', 'MINIMARKET', 'PENDING_REVIEW'),
      ('Гастроном «У Дома №14»', 'MINIMARKET', 'ACTIVE'),
    ].indexed)
      <String, dynamic>{
        'id': 's$i', 'code': 'CL-10$i', 'name': name, 'type': type, 'status': status, 'address': 'ул. Битарап, 84 (рядом с Гос. Моллом)',
        'lat': 37.95, 'lng': 58.38, 'agent': {'id': 'g1', 'fullName': 'Ахмед Джораев', 'phone': '+99365124581'},
        'contacts': [{'phone': '+99362112233'}], 'auditCount': 32 + i * 10, 'version': 1,
        'lastVisit': i == 1 ? {'at': DateTime.now().toIso8601String(), 'agentName': 'x'} : null,
        'kpis': {'totalAudits': 64, 'lastAuditAt': DateTime.now().toIso8601String(), 'auditPhotos': 64},
      },
  ];

  @override
  Future<PageOf> shops({int page = 1, String? q, String? status, String? regionId, String dir = 'asc'}) async => PageOf(_shops, 135);

  @override
  Future<Json> shop(String id) async => _shops.first;

  @override
  Future<List<Json>> regions() async => [{'id': 'r1', 'name': 'Region 1 (Central Hub)'}];

  @override
  Future<PageOf> agents({int page = 1, String? q, String? status, String? regionId}) async => PageOf(_agents, _agents.length);

  static final _agents = [
    for (final (i, name) in ['Ахмед Каримов', 'Довлет Оразов', 'Мурад Бердыев'].indexed)
      <String, dynamic>{'id': 'g$i', 'code': 'SL-10$i', 'fullName': name, 'phone': '+99365124581', 'active': true, 'locations': 64, 'photos': 168, 'visits': 12,
        'lastActivityAt': DateTime.now().toIso8601String(), 'workStatus': 'ACTIVE', 'region': {'id': 'r1', 'name': 'Region 1'}, 'onRoute': i == 0},
  ];

  @override
  Future<Json> agentsSummary() async => {'totalStaff': 52, 'activeStaff': 48, 'activePct': 92.3, 'onRoute': 36, 'onRoutePct': 75.0, 'audits': 184,
        'auditsVsPlanPct': 18, 'photos': 1420, 'photosVerifiedPct': 98.4, 'shopsVisited': 0, 'shopsPlanned': 0, 'needsContact': 4, 'noSignalMinutes': 45};

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError(invocation.memberName.toString());
}
