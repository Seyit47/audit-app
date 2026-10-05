enum Role {
  agent('/agent'),
  admin('/admin');

  const Role(this.pathPrefix);

  /// All routes of this role live under this prefix.
  final String pathPrefix;

  String get homePath => '$pathPrefix/home';
}
