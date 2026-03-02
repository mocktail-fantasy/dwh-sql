CREATE TABLE IF NOT EXISTS etl.job_logs (
    log_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    procedure_name TEXT NOT NULL,
    status TEXT NOT NULL, -- 'STARTED', 'COMPLETED', 'FAILED'
    message TEXT,
    log_time TIMESTAMPTZ DEFAULT now()
);
