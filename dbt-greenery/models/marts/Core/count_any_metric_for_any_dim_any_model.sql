select * from ({{count_any_model_dimension_measure('stg_events','event_type','session_uuid')}}) t
/* Exemple 1: count web sessions per event type usig the 'stg_events' model */

/* select * from ({{count_any_model_dimension_measure('dim_users','user_state','user_uuid')}}) t */
/* Example 2: count web sessions per event type usig the 'stg_events' model */