cmake_minimum_required (VERSION 2.6)

project (FothelloServe)

add_executable (FothelloServe smain.cpp board.cpp endgamecx.cpp minimax.cpp)

target_link_libraries(FothelloServe fcgi)

