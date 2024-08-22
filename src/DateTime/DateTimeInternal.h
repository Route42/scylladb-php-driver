#pragma once

#include <ZendCPP/ZendCPP.hpp>
#include <functional>
#include <string>
#include <string_view>

EXTERN_C()
void php_driver_define_Time();
void php_driver_define_Date();
void php_driver_define_Timestamp();
void php_driver_define_Timeuuid();
END_EXTERN_C()

zend_result scylladb_php_to_datetime_internal(
    zval* dst, const char* format, const std::function<zend_string*()>& get_timestamp) noexcept;