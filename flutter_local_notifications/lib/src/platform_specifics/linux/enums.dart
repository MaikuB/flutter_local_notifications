/// Specifies the source for icons.
enum LinuxIconSource {
  /// Icon from file path or uri, see [FileLinuxIcon].
  file,

  /// Icon from bytes, which consist of data of picture file, like png/jpg, see [ByteDataLinuxIcon].
  byteData,

  /// Icon from theme, with a name, see [ThemeLinuxIcon].
  theme,
}
