enum FileStatus {
  pending('PENDING'),
  processing('PROCESSING'),
  parsed('PARSED'),
  error('ERROR');

  final String value;
  const FileStatus(this.value);

  factory FileStatus.fromString(String value) {
    return FileStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => FileStatus.pending,
    );
  }
}
