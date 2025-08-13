CREATE TABLE IF NOT EXISTS bronze_file_checkpoints (
    source_file STRING,
    load_time TIMESTAMP
)
USING DELTA;
