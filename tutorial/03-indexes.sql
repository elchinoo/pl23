-- Operators
SELECT am.amname AS index_method,
       opf.opfname AS opfamily_name,
       amop.amopopr::regoperator AS opfamily_operator
  FROM pg_am am,
       pg_opfamily opf,
       pg_amop amop
 WHERE opf.opfmethod = am.oid AND amop.amopfamily = opf.oid;
 -- AND amop.amopopr = '@@(tsvector,tsquery)'::regoperator;

 -- Index info
select a.amname, p.name, pg_indexam_has_property(a.oid,p.name)
from pg_am a,
     unnest(array['can_order','can_unique','can_multi_col','can_exclude']) p(name)
where a.amname = 'btree'
order by a.amname;

select p.name,
     pg_index_column_has_property('t_a_idx'::regclass,1,p.name)
from unnest(array[
       'asc','desc','nulls_first','nulls_last','orderable','distance_orderable',
       'returnable','search_array','search_nulls'
     ]) p(name);