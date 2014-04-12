CREATE TABLE IF NOT EXISTS user (
    id           INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    name         VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS kintai (
    id          INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    user_id     INTEGER NOT NULL,
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

