CREATE TABLE IF NOT EXISTS kintai (
    id          INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    year_month  CHAR(6) NOT NULL
);

CREATE TABLE IF NOT EXISTS kintai_detail (
    id          INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    kintai_id   INTEGER NOT NULL,
    day         INTEGER NOT NULL,
    attend_time CHAR(4),
    leave_time  CHAR(4),
    remarks     CHAR(255)
);

