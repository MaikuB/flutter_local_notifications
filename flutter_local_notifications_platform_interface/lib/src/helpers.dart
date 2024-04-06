/// Helper method for validating notification IDs.
/// Ensures IDs are valid 32-bit integers.
void validateId(dynamic id) {
  ArgumentError.checkNotNull(id, 'id');
}
