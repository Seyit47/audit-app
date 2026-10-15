import 'package:flutter/widgets.dart';

/// The gallery's photos in grid order with the audit each belongs to (a photo without an audit is its own),
/// handed to the photo detail so it can page between audits.
typedef GallerySequence = List<(String photoId, String audit)>;

/// The audits of [seq] in grid order, as the first photo of each, and the one [photoId] is in (-1: none).
({List<String> audits, int index}) auditPages(GallerySequence? seq, String photoId) {
  if (seq == null) return (audits: const [], index: -1);
  final firsts = <String, String>{};
  for (final (id, audit) in seq) {
    firsts.putIfAbsent(audit, () => id);
  }
  final audit = seq.where((e) => e.$1 == photoId).firstOrNull?.$2;
  return (audits: firsts.values.toList(), index: audit == null ? -1 : firsts.keys.toList().indexOf(audit));
}

/// The gallery's audits as pages swiped like the photos: a swipe on the photo moves between the audit's
/// photos, anywhere else to the previous / next audit, which opens on its first photo.
class AuditPager extends StatefulWidget {
  const AuditPager({super.key, required this.photoId, required this.sequence, required this.page});

  final String photoId;
  final GallerySequence? sequence;

  /// One audit: [id] is a photo of it; [first]: select the audit's first photo instead of [id].
  final Widget Function(BuildContext context, String id, bool first) page;

  @override
  State<AuditPager> createState() => _AuditPagerState();
}

class _AuditPagerState extends State<AuditPager> {
  late final _pages = auditPages(widget.sequence, widget.photoId);
  late final _controller = PageController(initialPage: _pages.index < 0 ? 0 : _pages.index);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Opened from outside the gallery (or the photo isn't in its list): this audit only.
    if (_pages.index < 0) return widget.page(context, widget.photoId, false);
    return PageView.builder(
      controller: _controller,
      itemCount: _pages.audits.length,
      itemBuilder: (context, i) {
        final opened = i == _pages.index;
        final id = opened ? widget.photoId : _pages.audits[i];
        return KeyedSubtree(key: ValueKey(id), child: widget.page(context, id, !opened));
      },
    );
  }
}
