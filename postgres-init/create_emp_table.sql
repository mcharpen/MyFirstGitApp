CREATE TABLE IF NOT EXISTS emp (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    birth_date DATE,
    salary NUMERIC(12,2)
);
