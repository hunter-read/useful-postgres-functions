/*
 This function is used to count foreign key refrences to a given table name and it's primary key
 This does require that the correct foreign key constraints be set on the tables in question

 Example:
 user
 id | name
 4  | John Doe

 contact_info
 id | user_id | phone   | type
 8  | 4       | 8675309 | home
 9  | 4       | 4567890 | cell

USAGE: SELECT * FROM find_fk_counts('user', 4)
table_name   | column_name | count
contact_info | user_id     | 2
*/
CREATE OR REPLACE FUNCTION find_fk_counts(tablename text, pk_id bigint) RETURNS TABLE (table_name text, column_name text, count int)
AS $find_fk_counts$
DECLARE
    count INT;
    foreign_key_restraints RECORD;
BEGIN
    CREATE TEMP TABLE temp_fk_counts (table_name text, column_name text, count int) ON COMMIT DROP;
    FOR foreign_key_restraints IN (SELECT
                                       (SELECT r.relname FROM pg_class r WHERE r.oid = c.conrelid) AS tbl,
                                       (SELECT attname FROM pg_attribute
                                        WHERE attrelid = c.conrelid AND ARRAY[attnum] <@ c.conkey) AS col
                                   FROM pg_constraint c
                                   WHERE c.confrelid = (SELECT oid FROM pg_class WHERE relname = tablename))
        LOOP
            EXECUTE format('SELECT count(*) FROM %I WHERE %I = %L', foreign_key_restraints.tbl, foreign_key_restraints.col, pk_id) INTO count;
            INSERT INTO  temp_fk_counts VALUES (foreign_key_restraints.tbl::text, foreign_key_restraints.col::text, count);
        END LOOP;

    RETURN QUERY SELECT * FROM temp_fk_counts;
    DROP TABLE temp_fk_counts;
    RETURN;
END
$find_fk_counts$ LANGUAGE plpgsql;