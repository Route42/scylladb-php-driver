add_library(zend STATIC Zend.cpp)
add_library(Zend ALIAS zend)

add_subdirectory(String)

target_link_libraries(zend PUBLIC zend_strings)
scylladb_php_library(zend OFF ${PHP_SCYLLADB_OPTIMISE_FOR_CURRENT_MACHINE} ON)