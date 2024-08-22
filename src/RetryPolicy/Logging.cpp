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

#include <ZendCPP/ZendCPP.hpp>
#include <php_driver.h>
#include <php_driver_types.h>

BEGIN_EXTERN_C()

#include "Logging_arginfo.h"

zend_class_entry *php_driver_retry_policy_logging_ce = nullptr;
static zend_object_handlers php_driver_retry_policy_logging_handlers;

ZEND_METHOD(Cassandra_RetryPolicy_Logging, __construct)
{
  zval *child_policy = nullptr;

  //clang-format off
  ZEND_PARSE_PARAMETERS_START(1,1)
      Z_PARAM_OBJECT_OF_CLASS(child_policy, php_scylladb_retry_policy_ce)
  ZEND_PARSE_PARAMETERS_END();
  //clang-format on

  if (instanceof_function(Z_OBJCE_P(child_policy), php_driver_retry_policy_logging_ce)) {
    zend_throw_exception_ex(php_driver_invalid_argument_exception_ce, 0 ,
                            "Cannot add a " PHP_DRIVER_NAMESPACE "\\Logging as child policy of " PHP_DRIVER_NAMESPACE "\\Logging");
    RETURN_THROWS();
  }

  auto *self = ZendCPP::ObjectFetch<php_driver_retry_policy>(ZEND_THIS);
  self->policy = cass_retry_policy_logging_new(ZendCPP::ObjectFetch<php_driver_retry_policy>(child_policy)->policy);
}

static void php_driver_retry_policy_logging_free(zend_object *object)
{
  auto *self = ZendCPP::ObjectFetch<php_driver_retry_policy>(object);

  if (self->policy) {
    cass_retry_policy_free(self->policy);
  }
}

static zend_object*
php_driver_retry_policy_logging_new(zend_class_entry *ce)
{
  auto *self = ZendCPP::Allocate<php_driver_retry_policy>(ce, &php_driver_retry_policy_logging_handlers);
  self->policy = nullptr;
  return &self->zendObject;
}

PHP_SCYLLADB_API php_driver_retry_policy *php_scylladb_retry_policy_logging_instantiate(zval *dst, php_driver_retry_policy *retry_policy)
{
  zval val;

  if (object_init_ex(&val, php_scylladb_retry_policy_default_ce) == FAILURE) {
    return nullptr;
  }

  ZVAL_OBJ(dst, Z_OBJ(val));

  auto* obj = ZendCPP::ObjectFetch<php_driver_retry_policy>(dst);
  obj->policy = cass_retry_policy_logging_new(retry_policy->policy);
  return obj;
}

void php_driver_define_RetryPolicyLogging(zend_class_entry* retry_policy_interface)
{
  php_driver_retry_policy_logging_ce = register_class_Cassandra_RetryPolicy_Logging(retry_policy_interface);
  php_driver_retry_policy_logging_ce->create_object = php_driver_retry_policy_logging_new;

  ZendCPP::InitHandlers<php_driver_retry_policy>(&php_driver_retry_policy_logging_handlers);
  php_driver_retry_policy_logging_handlers.free_obj = php_driver_retry_policy_logging_free;
}

END_EXTERN_C()
