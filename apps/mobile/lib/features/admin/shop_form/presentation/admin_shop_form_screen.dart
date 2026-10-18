import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../add_shop/presentation/map_picker_screen.dart';
import '../../../add_shop/presentation/shop_form_view.dart';
import '../../../audit/domain/geofence.dart';
import '../../../audit/presentation/audit_controller.dart';
import '../../data/admin_api.dart';
import '../../../../core/widgets/camera_capture_screen.dart';
import '../../../../core/widgets/skeleton.dart';
import '../../../../core/widgets/adaptive.dart';
import '../../../../core/widgets/multi_select_field.dart';
import '../../../../core/format/phone.dart';

/// Admin mobile Add/Edit shop (`252:25423` empty, `252:25542` filled): saved online with
/// `POST/PATCH /shops` after the storefront upload.
class AdminShopFormScreen extends ConsumerStatefulWidget {
  const AdminShopFormScreen({super.key, this.shopId, this.districtId});

  final String? shopId;

  /// A new shop opened from a district starts in it.
  final String? districtId;

  @override
  ConsumerState<AdminShopFormScreen> createState() => _AdminShopFormScreenState();
}

class _AdminShopFormScreenState extends ConsumerState<AdminShopFormScreen> {
  String _name = '', _address = '', _owner = '', _phone = '';
  Set<String> _agentIds = {};
  late String? _districtId = widget.districtId;
  List<Json> _districts = const [];
  Fix? _fix;

  /// Chosen on the map; wins over the GPS fix (admins pick anywhere).
  (double, double)? _picked;
  bool _locating = true;
  String? _photoPath;
  String? _photoUrl;
  int? _photoSize;
  bool _removedPhoto = false;
  bool _saving = false;
  bool _loaded = false;
  String? _error;
  bool _loadFailed = false;
  int? _version;
  List<Json> _agents = const [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final api = ref.read(adminApiProvider);
    try {
      final (agents, districts) = await (api.agents(), api.districts()).wait;
      _agents = agents.items.where((a) => a['active'] == true).toList();
      _districts = districts.where((d) => d['id'] != null).toList();
      if (widget.shopId != null) {
        final s = await api.shop(widget.shopId!);
        _name = s['name'] as String;
        _address = s['address'] as String;
        _owner = (s['ownerName'] as String?) ?? '';
        _phone = (((s['contacts'] as List?) ?? const []).cast<Map>().firstOrNull?['phone'] as String?) ?? '';
        _agentIds = {
          for (final a in ((s['agents'] as List?) ?? [?s['agent']]).cast<Map>()) a['id'] as String,
        };
        _districtId = (s['district'] as Map?)?['id'] as String?;
        _fix = Fix(lat: (s['lat'] as num).toDouble(), lng: (s['lng'] as num).toDouble(), accuracyM: 0);
        _photoUrl = ((s['facade'] as Map?)?['previewUrl400'] ?? (s['facade'] as Map?)?['url']) as String?;
        _version = s['version'] as int?;
        _locating = false;
      }
    } catch (_) {
      _loadFailed = true;
    }
    if (!mounted) return;
    setState(() => _loaded = true);
    if (widget.shopId == null) await _locate();
  }

  Future<void> _locate() async {
    setState(() => _locating = true);
    final fix = await ref.read(locatorProvider).current();
    if (mounted) {
      setState(() {
        _fix = fix ?? _fix;
        if (fix != null) _picked = null;
        _locating = false;
      });
    }
  }

  Future<void> _camera() async {
    final p = await ref.read(photoCaptureProvider).capture(fix: _fix);
    if (p != null && mounted) {
      setState(() {
        _photoPath = p.path;
        _photoSize = p.sizeBytes;
        _removedPhoto = false;
      });
    }
  }

  Future<void> _gallery() async {
    final x = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: photoQuality, maxWidth: photoMaxSide.toDouble());
    if (x != null && mounted) {
      setState(() {
        _photoPath = x.path;
        _photoSize = File(x.path).lengthSync();
        _removedPhoto = false;
      });
    }
  }

  bool get _hasPhoto => _photoPath != null || (_photoUrl != null && !_removedPhoto);
  bool get _canSave =>
      _name.trim().isNotEmpty &&
      _address.trim().isNotEmpty &&
      _owner.trim().isNotEmpty &&
      _agentIds.isNotEmpty &&
      _districtId != null &&
      tmPhone(_phone) != null &&
      (_picked != null || _fix != null) &&
      _hasPhoto;

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _saving = true;
      _error = null;
    });
    final api = ref.read(adminApiProvider);
    try {
      final facade = _photoPath == null ? null : await api.upload(File(_photoPath!), 'FACADE');
      final body = <String, dynamic>{
        'name': _name.trim(),
        'address': _address.trim(),
        'ownerName': _owner.trim(),
        'agentIds': _agentIds.toList(),
        'districtId': _districtId,
        'lat': _picked?.$1 ?? _fix!.lat,
        'lng': _picked?.$2 ?? _fix!.lng,
        'facadePhotoId': ?facade,
      };
      if (widget.shopId == null) {
        await api.createShop({
          ...body,
          'contacts': [
            {'phone': tmPhone(_phone)!},
          ],
        });
      } else {
        await api.updateShop(widget.shopId!, {...body, 'version': _version});
        await api.setContacts(widget.shopId!, [
          {'phone': tmPhone(_phone)!},
        ]);
      }
      if (mounted) context.pop(true);
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = l10n.saveFailed;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    if (!_loaded) {
      return Scaffold(
        backgroundColor: c.mainBg,
        body: const SafeArea(
          child: SingleChildScrollView(padding: EdgeInsets.all(16), physics: NeverScrollableScrollPhysics(), child: CardListSkeleton(count: 4, lines: 3)),
        ),
      );
    }
    return ShopFormView(
      title: widget.shopId == null ? l10n.addShopTitle : l10n.editShopTitle,
      name: _name,
      address: _address,
      owner: _owner,
      phone: _phone,
      onChanged: ({name, address, owner, phone}) => setState(() {
        _name = name ?? _name;
        _address = address ?? _address;
        _owner = owner ?? _owner;
        _phone = phone ?? _phone;
      }),
      districtField: AppSelect<String>(
        value: _districtId,
        hint: l10n.selectDistrict,
        items: [for (final d in _districts) (d['id'] as String, d['name'] as String)],
        onChanged: (v) => setState(() => _districtId = v),
      ),
      districtValid: _districtId != null,
      agentField: AppMultiSelect(
        title: l10n.agentsField,
        values: _agentIds,
        hint: l10n.selectAgents,
        // Active agents only; one deactivated since stays assigned (kept in the set) until removed on the web.
        items: [for (final a in _agents) (a['id'] as String, a['fullName'] as String)],
        onChanged: (v) => setState(() => _agentIds = v),
      ),
      agentValid: _agentIds.isNotEmpty,
      fix: _fix,
      locating: _locating,
      onRecheck: _locate,
      picked: _picked,
      onPickOnMap: () async {
        final point = await MapPickerScreen.open(context, start: _picked ?? (_fix == null ? (37.95, 58.38) : (_fix!.lat, _fix!.lng)));
        if (point != null && mounted) setState(() => _picked = point);
      },
      photo: _photoPath ?? (_removedPhoto ? null : _photoUrl),
      photoSizeBytes: _photoSize,
      onTakePhoto: _camera,
      onPickPhoto: _gallery,
      onRemovePhoto: () => setState(() {
        _photoPath = null;
        _photoSize = null;
        _removedPhoto = true;
      }),
      canSave: _canSave,
      saving: _saving,
      onSave: _save,
      error: _error ?? (_loadFailed ? l10n.loadError : null),
    );
  }
}
