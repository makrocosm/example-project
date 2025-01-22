cmake_minimum_required(VERSION 3.5)
project(HelloWorld)

find_package(PkgConfig REQUIRED)
pkg_check_modules(LIBUV REQUIRED IMPORTED_TARGET libuv)

add_executable(helloworld helloworld.c)
target_include_directories(helloworld PRIVATE ${LIBUV_INCLUDE_DIRS})
target_link_libraries(helloworld PkgConfig::LIBUV)

install(TARGETS helloworld DESTINATION bin)
