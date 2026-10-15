/// The gallery's photos in grid order with the audit each belongs to (a photo without an audit is its own),
/// handed to the photo detail so swiping its details area moves between audits.
typedef GallerySequence = List<(String photoId, String audit)>;

/// The first photo (in grid order) of the audit before / after the one [photoId] is in.
({String? prev, String? next}) auditNeighbours(GallerySequence? seq, String photoId) {
  if (seq == null) return (prev: null, next: null);
  final firsts = <String, String>{};
  for (final (id, audit) in seq) {
    firsts.putIfAbsent(audit, () => id);
  }
  final audits = firsts.keys.toList();
  final audit = seq.where((e) => e.$1 == photoId).firstOrNull?.$2;
  final i = audit == null ? -1 : audits.indexOf(audit);
  if (i < 0) return (prev: null, next: null);
  return (prev: i > 0 ? firsts[audits[i - 1]] : null, next: i < audits.length - 1 ? firsts[audits[i + 1]] : null);
}
