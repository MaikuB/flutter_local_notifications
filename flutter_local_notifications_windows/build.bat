@echo off
if not exist build mkdir build
cd build
cmake ../windows
cmake --build .
cd ..
copy build\shared\Debug\flutter_local_notifications_windows.dll .
