CREATE TABLE IF NOT EXISTS user_info(
    id text, 
    phone text, 
    name text, 
    job text, 
    address text
);


CREATE TABLE IF NOT EXISTS payment_info(
    id text, 
    account_number text, 
    intl_account_number text,
    bank_country text
);


-- Nested Loop
EXPLAIN ANALYZE
SELECT *
FROM user_info, payment_info
WHERE user_info.id < payment_info.id
LIMIT 10 OFFSET 200;

-- Hash Join
EXPLAIN (analyze, buffers, costs off, timing off, summary off)
SELECT *
FROM user_info JOIN payment_info on user_info.id = payment_info.id
LIMIT 10;

SET log_temp_files = 1;

EXPLAIN (analyze, buffers, costs off, timing off, summary off)
SELECT *
FROM user_info JOIN payment_info on user_info.id = payment_info.id
LIMIT 10;

SET log_temp_files = 0;

-- Merge Join
CREATE index id_idx_usr on user_info using btree(id);
CREATE index id_idx_payment on payment_info using btree(id);

EXPLAIN ANALYZE
SELECT *
FROM user_info JOIN payment_info on user_info.id = payment_info.id
LIMIT 10;

SET search_path = bookings, public;
EXPLAIN (costs off) 
SELECT *
FROM tickets t
  JOIN ticket_flights tf ON t.ticket_no = tf.ticket_no
  JOIN boarding_passes bp ON bp.ticket_no = tf.ticket_no
                         AND bp.flight_id = tf.flight_id
ORDER BY t.ticket_no;

