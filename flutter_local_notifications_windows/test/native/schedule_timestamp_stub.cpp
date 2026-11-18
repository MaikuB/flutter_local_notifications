#include "../../src/ffi_api.h"

#include <cstdint>

template <typename Function> struct ScheduleTimestamp;
template <typename Result, typename Plugin, typename Id, typename Xml, typename Time>
struct ScheduleTimestamp<Result (*)(Plugin, Id, Xml, Time)> {
  using Type = Time;
};
using Timestamp = ScheduleTimestamp<decltype(&scheduleNotification)>::Type;
static int64_t receivedTime = 0;

bool scheduleNotification(NativePlugin*, int, char*, Timestamp time) {
  receivedTime = time;
  return true;
}
extern "C" FFI_PLUGIN_EXPORT int64_t capturedTimestamp() { return receivedTime; }
