/*
View to show blocking processes, and what they are blocking
Ordered in such a way that the top most result should be the root blocking pid (though there may be multiple)
Processes can be terminated with SELECT pg_terminate_backend(blocking_pid);
*/

CREATE VIEW lock_monitor_view AS(
SELECT
    blocking.pid AS blocking_pid,
    blocking.query AS blocking_query,
    blocking.client_addr AS blocking_address,
    blocking.backend_start AS blocking_start,
    activity.pid AS blocked_pid,
    activity.query AS blocked_query,
    activity.client_addr AS blocked_address
FROM pg_stat_activity AS activity
         JOIN pg_stat_activity AS blocking ON blocking.pid = ANY(pg_blocking_pids(activity.pid)) ORDER BY blocking.backend_start);