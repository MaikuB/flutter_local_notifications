/// Helper method for validating notification IDs.
/// Ensures IDs are valid 32-bit integers.
void validateId(int id) {
  if (id == null) {
    throw ArgumentError.notNull('id');
  }

  if (id > 0x7FFFFFFF || id < -0x80000000) {
    throw ArgumentError.value(id, 'id',
        'must fit within the size of a 32-bit integer i.e. in the range [-2^31, 2^31 - 1]');
  }
}
