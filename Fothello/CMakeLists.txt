cmake_minimum_required (VERSION 2.6)

project (fothellows.fcgi)

add_executable (fothellows.fcgi smain.cpp board.cpp endgamecx.cpp minimax.cpp)

target_link_libraries(fothellows.fcgi fcgi++ fcgi)
target_compile_options(fothellows.fcgi PUBLIC -std=c++11)


install(TARGETS fothellows.fcgi DESTINATION /home/ubuntu/fcgiws)
