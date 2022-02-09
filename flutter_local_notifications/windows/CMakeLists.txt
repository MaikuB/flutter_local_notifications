cmake_minimum_required(VERSION 3.14)
set(PROJECT_NAME "flutter_local_notifications")
project(${PROJECT_NAME} LANGUAGES CXX)
include(FetchContent)

# This value is used when generating builds using this plugin, so it must
# not be changed
set(PLUGIN_NAME "flutter_local_notifications_plugin")

# nuget configuration
set(NUGET_PACKAGES_PATH "${CMAKE_BINARY_DIR}/packages")
set(CPPWINRT_VERSION "2.0.220131.2")

FetchContent_Declare(nuget
  URL "https://dist.nuget.org/win-x86-commandline/v6.0.0/nuget.exe"
  URL_HASH SHA256=04eb6c4fe4213907e2773e1be1bbbd730e9a655a3c9c58387ce8d4a714a5b9e1
  DOWNLOAD_NO_EXTRACT true
)
find_program(NUGET nuget)
if (NOT NUGET)
    message("Nuget.exe not found, trying to download or use cached version.")
    FetchContent_MakeAvailable(nuget)
    set(NUGET ${nuget_SOURCE_DIR}/nuget.exe)
endif()

function(nuget_install pkg ver)
	execute_process(COMMAND
		${NUGET} install ${pkg} -Version ${ver} -OutputDirectory ${NUGET_PACKAGES_PATH}
	    RESULT_VARIABLE result)
	if (NOT result EQUAL 0)
	    message(FATAL_ERROR "Failed to install nuget package ${pkg}, version ${ver}")
	endif()
endfunction()

add_library(${PLUGIN_NAME} SHARED
  "flutter_local_notifications_plugin.cpp"
  "methods.cpp"
  "utils/utils.cpp")

# setup c++/winrt
nuget_install("Microsoft.Windows.CppWinRT" ${CPPWINRT_VERSION})
set(CPPWINRT ${NUGET_PACKAGES_PATH}/Microsoft.Windows.CppWinRT.${CPPWINRT_VERSION}/bin/cppwinrt.exe)
execute_process(COMMAND
    ${CPPWINRT} -input sdk -output include
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    RESULT_VARIABLE ret)
if (NOT ret EQUAL 0)
    message(FATAL_ERROR "Result ${ret} ${CPPWINRT} Failed to run cppwinrt.exe")
endif()

include_directories(BEFORE SYSTEM ${CMAKE_BINARY_DIR}/include)

apply_standard_settings(${PLUGIN_NAME})
set_target_properties(${PLUGIN_NAME} PROPERTIES
  CXX_VISIBILITY_PRESET hidden)
target_compile_definitions(${PLUGIN_NAME} PRIVATE FLUTTER_PLUGIN_IMPL)
target_include_directories(${PLUGIN_NAME} INTERFACE
  "${CMAKE_CURRENT_SOURCE_DIR}/include")
target_link_libraries(${PLUGIN_NAME} PRIVATE flutter flutter_wrapper_plugin)

# List of absolute paths to libraries that should be bundled with the plugin
set(flutter_local_notifications_bundled_libraries
  ""
  PARENT_SCOPE
)
