# Relation Database Postgres

## AWS RDS Proxy
- allow apps to pool and share databse connections
- improve resiliencey to database failures using standby DB instance
  (probably active passive setup)
- handle traffic spikes
    - by connection pooling and reuse
    - control number of connections that are created
- queue and throttle application connections
    - latencies might increase
    - but smooths out scaling
    - reject excess connections (load shedding)
- supported across various regions and DB engines
- Quotas and limitations
    - 20 proxies per account
    - 200 secret manager per proxy (200 accounts)
    - 20 enpoints per proxy
    - proxy only associated with write replicas
    - proxy and database must be in the same VPC
        - cant connect to proxy outside of VPC (aka localhost)
    - cant use proxy with tenancy set to dedicated
    - cant use proxy with custom DNS when using SSL hostname validation
    - multiple proxies can be associated with the same DB instance
    - if statement text size > 16 kB proxy pins it to the current connection
    - db parameter group modifications need instance or cluster level reboots
    - rdsproxyadmin - prototected DB user thats created when you register proxy target

## Go SQL
"database/sql" go std lib
- used in conjunction with a datbase driver
- pool := sql.Open("driver-name", dsn) 
    - dsn is data source name
    - returns a connection pool
    - usually doesnt attempt to connect to the database
- pool.QueryRowContext(ctx, "query");


## Go PGX
github.com/jackc/pgx
- pgx.Connect(ctx, "database_url")
- conn.QueryRow(ctx, "query").Scan(&var1);
