/* This is a generated file, edit the .stub.php file instead.
 * Stub hash: 15eeabd10fd045bbcd44886c3126a196b70a7603 */




static const zend_function_entry class_Cassandra_RetryPolicy_DefaultPolicy_methods[] = {
	ZEND_FE_END
};

static zend_class_entry *register_class_Cassandra_RetryPolicy_DefaultPolicy(zend_class_entry *class_entry_Cassandra_RetryPolicy)
{
	zend_class_entry ce, *class_entry;

	INIT_NS_CLASS_ENTRY(ce, "Cassandra\\RetryPolicy", "DefaultPolicy", class_Cassandra_RetryPolicy_DefaultPolicy_methods);
	class_entry = zend_register_internal_class_ex(&ce, NULL);
	class_entry->ce_flags |= ZEND_ACC_FINAL|ZEND_ACC_NO_DYNAMIC_PROPERTIES;
	zend_class_implements(class_entry, 1, class_entry_Cassandra_RetryPolicy);

	return class_entry;
}
