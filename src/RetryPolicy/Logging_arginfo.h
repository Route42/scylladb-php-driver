/* This is a generated file, edit the .stub.php file instead.
 * Stub hash: cb34fdaa46084899a16ee3e8fb7b223b6a1aaa74 */

ZEND_BEGIN_ARG_INFO_EX(arginfo_class_Cassandra_RetryPolicy_Logging___construct, 0, 0, 1)
	ZEND_ARG_OBJ_INFO(0, policy, Cassandra\\RetryPolicy, 0)
ZEND_END_ARG_INFO()


ZEND_METHOD(Cassandra_RetryPolicy_Logging, __construct);


static const zend_function_entry class_Cassandra_RetryPolicy_Logging_methods[] = {
	ZEND_ME(Cassandra_RetryPolicy_Logging, __construct, arginfo_class_Cassandra_RetryPolicy_Logging___construct, ZEND_ACC_PUBLIC)
	ZEND_FE_END
};

static zend_class_entry *register_class_Cassandra_RetryPolicy_Logging(zend_class_entry *class_entry_Cassandra_RetryPolicy)
{
	zend_class_entry ce, *class_entry;

	INIT_NS_CLASS_ENTRY(ce, "Cassandra\\RetryPolicy", "Logging", class_Cassandra_RetryPolicy_Logging_methods);
	class_entry = zend_register_internal_class_ex(&ce, NULL);
	class_entry->ce_flags |= ZEND_ACC_FINAL|ZEND_ACC_NO_DYNAMIC_PROPERTIES;
	zend_class_implements(class_entry, 1, class_entry_Cassandra_RetryPolicy);

	return class_entry;
}
