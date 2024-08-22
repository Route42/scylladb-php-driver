<?php

/**
* @generate-class-entries
*/
namespace Cassandra\RetryPolicy {
    /**
     * @strict-properties
     * @deprecated
     *
     * This still works, but should not be used in new applications.
     * It can lead to unexpected behavior when the cluster is in a degraded state.
     * Instead, applications should prefer using the lowest consistency level
     * on statements that can be tolerated by a specific use case.
     */
    final class DowngradingConsistency implements \Cassandra\RetryPolicy { }
}
