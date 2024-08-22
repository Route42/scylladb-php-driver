/* This is a generated file, edit the .stub.php file instead.
 * Stub hash: 36db175b25ad8d988ad4abce8e4577c3fa97b447 */

ZEND_BEGIN_ARG_INFO_EX(arginfo_class_Cassandra_Timeuuid___construct, 0, 0, 0)
	ZEND_ARG_TYPE_INFO(0, uuid, IS_STRING, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_Cassandra_Timeuuid_type, 0, 0, Cassandra\\Type, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_Cassandra_Timeuuid_time, 0, 0, IS_LONG, 0)
ZEND_END_ARG_INFO()

#define arginfo_class_Cassandra_Timeuuid_version arginfo_class_Cassandra_Timeuuid_time

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_Cassandra_Timeuuid_uuid, 0, 0, IS_STRING, 0)
ZEND_END_ARG_INFO()

#define arginfo_class_Cassandra_Timeuuid___toString arginfo_class_Cassandra_Timeuuid_uuid


ZEND_METHOD(Cassandra_Timeuuid, __construct);
ZEND_METHOD(Cassandra_Timeuuid, type);
ZEND_METHOD(Cassandra_Timeuuid, time);
ZEND_METHOD(Cassandra_Timeuuid, version);
ZEND_METHOD(Cassandra_Timeuuid, uuid);
ZEND_METHOD(Cassandra_Timeuuid, __toString);


static const zend_function_entry class_Cassandra_Timeuuid_methods[] = {
	ZEND_ME(Cassandra_Timeuuid, __construct, arginfo_class_Cassandra_Timeuuid___construct, ZEND_ACC_PUBLIC)
	ZEND_ME(Cassandra_Timeuuid, type, arginfo_class_Cassandra_Timeuuid_type, ZEND_ACC_PUBLIC)
	ZEND_ME(Cassandra_Timeuuid, time, arginfo_class_Cassandra_Timeuuid_time, ZEND_ACC_PUBLIC)
	ZEND_ME(Cassandra_Timeuuid, version, arginfo_class_Cassandra_Timeuuid_version, ZEND_ACC_PUBLIC)
	ZEND_ME(Cassandra_Timeuuid, uuid, arginfo_class_Cassandra_Timeuuid_uuid, ZEND_ACC_PUBLIC)
	ZEND_ME(Cassandra_Timeuuid, __toString, arginfo_class_Cassandra_Timeuuid___toString, ZEND_ACC_PUBLIC)
	ZEND_FE_END
};

static zend_class_entry *register_class_Cassandra_Timeuuid(zend_class_entry *class_entry_Cassandra_Value)
{
	zend_class_entry ce, *class_entry;

	INIT_NS_CLASS_ENTRY(ce, "Cassandra", "Timeuuid", class_Cassandra_Timeuuid_methods);
	class_entry = zend_register_internal_class_ex(&ce, NULL);
	class_entry->ce_flags |= ZEND_ACC_FINAL|ZEND_ACC_NO_DYNAMIC_PROPERTIES;
	zend_class_implements(class_entry, 1, class_entry_Cassandra_Value);

	return class_entry;
}
