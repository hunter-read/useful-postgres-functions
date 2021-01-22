/*
List views, their definition, and refrenced tables.
*/

SELECT u.view_name,
       v.view_definition,
       json_agg(u.table_name)
FROM information_schema.view_table_usage u
JOIN information_schema.views v 
    ON u.view_schema = v.table_schema
    AND u.view_name = v.table_name 
GROUP BY u.view_name, v.view_definition;