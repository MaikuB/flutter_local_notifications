## [1.0.0-dev.3]

* **Breaking change** Reworked the APIs around custom images and audio. Check the updated example for more details, but in short:
  * Instead of `WindowsNotificationAudio.fromFile()`, use `WindowsNotificationAudio.asset()`
  * Instead of `WindowsImage.file()`, use `WindowsImage.asset()` or `WindowsImage.network()`

## [1.0.0-dev.2]

* Fixed an issue that happens with MSIX app builds. Thanks to PR from [Levi Lesches](https://github.com/Levi-Lesches)

## [1.0.0-dev.1]

* Initial prerelease for Windows. Thanks to PR [Levi Lesches](https://github.com/Levi-Lesches) that continued the work done initially done by [Kenneth](https://github.com/kennethnym) and[lightrabbit](https://github.com/lightrabbit)