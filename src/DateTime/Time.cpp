/**
 * Copyright 2015-2017 DataStax, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <util/hash.h>
#include <util/math.h>
#include <util/types.h>

#include <ZendCPP/ZendCPP.hpp>

#include "php_driver.h"
#include "php_driver_types.h"

#if defined(__APPLE__) && defined(__MACH__)
#include <sys/time.h>
#else
#include <ctime>
#endif

#define NUM_NANOSECONDS_PER_DAY 86399999999999LL
#define NANOSECONDS_PER_SECOND 1000000000LL

cass_int64_t php_driver_time_now_ns() {
  cass_int64_t seconds;
  cass_int64_t nanoseconds;
#if defined(__APPLE__) && defined(__MACH__)
  struct timeval ts {};
  gettimeofday(&tv, NULL);
  seconds = (cass_int64_t)tv.tv_sec;
  nanoseconds = (cass_int64_t)tv.tv_usec * 1000;
#else
  struct timespec ts {};
  clock_gettime(CLOCK_REALTIME, &ts);
  seconds = (cass_int64_t)ts.tv_sec;
  nanoseconds = (cass_int64_t)ts.tv_nsec;
#endif
  return cass_time_from_epoch(seconds) + nanoseconds;
}

BEGIN_EXTERN_C()
#include <ext/date/lib/timelib.h>
#include <ext/date/php_date.h>

#include "Time_arginfo.h"

zend_class_entry *php_driver_time_ce = nullptr;

static int to_string(zval *result, php_driver_time *time) {
  char *string;
  spprintf(&string, 0, "%lld", (long long int)time->time);
  ZVAL_STRING(result, string);
  efree(string);
  return SUCCESS;
}

zend_result php_driver_time_init(zval *returnValue, zend_string *nanosecondsStr = nullptr,
                                 zend_long nanoseconds = -1) {
  if (returnValue == nullptr) {
    return FAILURE;
  }

  if (Z_TYPE_P(returnValue) == IS_UNDEF) {
    zval val;
    object_init_ex(&val, php_driver_date_ce);
    ZVAL_OBJ(returnValue, Z_OBJ(val));
  }

  auto self = ZendCPP::ObjectFetch<php_driver_time>(returnValue);

  if (nanosecondsStr == nullptr && nanoseconds == -1) {
    self->time = php_driver_time_now_ns();
    return SUCCESS;
  }

  if (nanosecondsStr == nullptr) {
    if (php_driver_parse_bigint(ZSTR_VAL(nanosecondsStr), ZSTR_LEN(nanosecondsStr), &self->time) ==
        SUCCESS) {
      return SUCCESS;
    }

    zval zNanoseconds;
    ZVAL_STR(&zNanoseconds, nanosecondsStr);
    throw_invalid_argument(&zNanoseconds, "nanoseconds",
                           "invalid string representation of a number of nanoseconds");
    return FAILURE;
  }

  if (nanoseconds < 0 || nanoseconds > NUM_NANOSECONDS_PER_DAY) {
    self->time = nanoseconds;
    return SUCCESS;
  }

  zval zNanoseconds;
  ZVAL_LONG(&zNanoseconds, nanoseconds);
  throw_invalid_argument(&zNanoseconds, "nanoseconds",
                         "nanoseconds must be in range [0, 86399999999999]");

  return FAILURE;
}

ZEND_METHOD(Cassandra_Time, __construct) {
  zend_string *nanosecondsStr = nullptr;
  zend_long nanoseconds = -1;

  // clang-format off
  ZEND_PARSE_PARAMETERS_START(0, 1)
    Z_PARAM_OPTIONAL
    Z_PARAM_STR_OR_LONG(nanosecondsStr, nanoseconds)
  ZEND_PARSE_PARAMETERS_END();
  // clang-format on

  if (php_driver_time_init(getThis(), nanosecondsStr, nanoseconds) == FAILURE) {
    zend_throw_exception_ex(php_driver_invalid_argument_exception_ce, 0,
                            "Cannot create Cassandra\\Time from invalid value");
  }
}

ZEND_METHOD(Cassandra_Time, type) {
  zval type = php_driver_type_scalar(CASS_VALUE_TYPE_TIME);
  RETURN_ZVAL(&type, 1, 1);
}

ZEND_METHOD(Cassandra_Time, seconds) {
  auto *self = ZendCPP::ObjectFetch<php_driver_time>(getThis());
  RETURN_LONG(self->time / NANOSECONDS_PER_SECOND);
}

ZEND_METHOD(Cassandra_Time, fromDateTime) {
  zval *datetime;

  // clang-format off
  ZEND_PARSE_PARAMETERS_START(1, 1)
    Z_PARAM_OBJECT_OF_CLASS(datetime, php_date_get_interface_ce())
  ZEND_PARSE_PARAMETERS_END();
  // clang-format on

  zval getTimeStampResult;
  zend_call_method_with_0_params(Z_OBJ_P(datetime), php_date_get_interface_ce(), nullptr,
                                 "getTimestamp", &getTimeStampResult);

  object_init_ex(return_value, php_driver_time_ce);
  auto *self = ZendCPP::ObjectFetch<php_driver_time>(return_value);
  self->time = cass_date_from_epoch(Z_LVAL(getTimeStampResult));
  zval_ptr_dtor(&getTimeStampResult);
}

ZEND_METHOD(Cassandra_Time, __toString) {
  ZEND_PARSE_PARAMETERS_NONE();

  auto *self = ZendCPP::ObjectFetch<php_driver_time>(getThis());
  to_string(return_value, self);
}

static php_driver_value_handlers php_driver_time_handlers;

static HashTable *php_driver_time_gc(zend_object *object, zval **table, int *n) {
  *table = nullptr;
  *n = 0;
  return zend_std_get_properties(object);
}

static HashTable *php_driver_time_properties(zend_object *object) {
  HashTable *props = zend_std_get_properties(object);

  auto type = php_driver_type_scalar(CASS_VALUE_TYPE_TIME);
  zend_hash_str_update(props, ZEND_STRL("type"), &type);

  zval nanoseconds;
  to_string(&nanoseconds, ZendCPP::ObjectFetch<php_driver_time>(object));
  zend_hash_str_update(props, ZEND_STRL("nanoseconds"), &nanoseconds);

  return props;
}

static int php_driver_time_compare(zval *obj1, zval *obj2) {
  ZEND_COMPARE_OBJECTS_FALLBACK(obj1, obj2)

  if (Z_OBJCE_P(obj1) != Z_OBJCE_P(obj2)) return 1; /* different classes */

  auto time1 = ZendCPP::ObjectFetch<php_driver_time>(obj1);
  auto time2 = ZendCPP::ObjectFetch<php_driver_time>(obj2);

  return PHP_DRIVER_COMPARE(time1->time, time2->time);
}

static unsigned php_driver_time_hash_value(zval *obj) {
  php_driver_time *self = PHP_DRIVER_GET_TIME(obj);
  return php_driver_bigint_hash(self->time);
}

static zend_object* php_driver_time_new(zend_class_entry *ce) {
  auto *self = ZendCPP::Allocate<php_driver_time>(ce, &php_driver_time_handlers);
  self->time = 0;

  return &self->zval;
}

void php_driver_define_Time() {
  php_driver_time_ce = register_class_Cassandra_Time(php_driver_value_ce);
  php_driver_time_ce->create_object = php_driver_time_new;

  ZendCPP::InitHandlers(&php_driver_time_handlers);
  php_driver_time_handlers.std.get_properties = php_driver_time_properties;
  php_driver_time_handlers.std.get_gc = php_driver_time_gc;
  php_driver_time_handlers.std.compare = php_driver_time_compare;
  php_driver_time_handlers.std.offset = XtOffsetOf(php_driver_time, zval);
  php_driver_time_handlers.hash_value = php_driver_time_hash_value;
}

END_EXTERN_C()