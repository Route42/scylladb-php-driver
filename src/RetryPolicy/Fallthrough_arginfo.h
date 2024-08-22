/* This is a generated file, edit the .stub.php file instead.
 * Stub hash: 9fd473bdff77ce030786099f06fb2825b4242ae4 */




static const zend_function_entry class_Cassandra_RetryPolicy_Fallthrough_methods[] = {
	ZEND_FE_END
};

static zend_class_entry *register_class_Cassandra_RetryPolicy_Fallthrough(zend_class_entry *class_entry_Cassandra_RetryPolicy)
{
	zend_class_entry ce, *class_entry;

	INIT_NS_CLASS_ENTRY(ce, "Cassandra\\RetryPolicy", "Fallthrough", class_Cassandra_RetryPolicy_Fallthrough_methods);
	class_entry = zend_register_internal_class_ex(&ce, NULL);
	class_entry->ce_flags |= ZEND_ACC_FINAL|ZEND_ACC_NO_DYNAMIC_PROPERTIES;
	zend_class_implements(class_entry, 1, class_entry_Cassandra_RetryPolicy);

	return class_entry;
}
