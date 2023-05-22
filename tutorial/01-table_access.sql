DROP INDEX id_idx;
DROP INDEX name_str_idx;

SET max_parallel_workers_per_gather = 0;
EXPLAIN ANALYZE SELECT * FROM tb_access WHERE id = 1500;

CREATE INDEX id_idx ON tb_access USING BTREE(id);
EXPLAIN ANALYZE SELECT * FROM tb_access WHERE id = 1500;
EXPLAIN ANALYZE SELECT * FROM tb_access WHERE id BETWEEN 1500 AND 1900;

EXPLAIN ANALYZE SELECT id FROM tb_access WHERE id = 1500;
EXPLAIN ANALYZE SELECT id FROM tb_access WHERE id BETWEEN 1500 AND 1900;

CREATE INDEX name_str_idx on tb_access USING BTREE(name);

EXPLAIN ANALYZE SELECT * FROM tb_access WHERE name = 'Victor Pittman';

EXPLAIN ANALYZE SELECT * FROM tb_access WHERE name = 'William Kelly' OR id = 1499;

EXPLAIN ANALYZE SELECT * FROM tb_access WHERE id <= 1501 AND name = 'William Kelly';


SELECT attname, correlation
FROM pg_stats WHERE tablename = 'tb_access'
ORDER BY abs(correlation) DESC;


EXPLAIN SELECT * FROM tb_access WHERE id < 100000;

SELECT round(98760::numeric/reltuples::numeric, 4)
FROM pg_class WHERE relname = 'tb_access';


WITH costs(idx_cost, tbl_cost) AS (
  SELECT
    ( SELECT round(
        current_setting('random_page_cost')::real * pages +
        current_setting('cpu_index_tuple_cost')::real * tuples +
        current_setting('cpu_operator_cost')::real * tuples
      )
      FROM (
        SELECT relpages * 0.0882 AS pages, reltuples * 0.0882 AS tuples
        FROM pg_class WHERE relname = 'id_idx'
      ) c
    ),
    ( SELECT round(
        current_setting('seq_page_cost')::real * pages +
        current_setting('cpu_tuple_cost')::real * tuples
      )
      FROM (
        SELECT relpages * 0.0882 AS pages, reltuples * 0.0882 AS tuples
        FROM pg_class WHERE relname = 'tb_access'
      ) c
    )
)
SELECT idx_cost, tbl_cost, idx_cost + tbl_cost AS total FROM costs;
