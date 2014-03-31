CREATE TABLE IF NOT EXISTS user (
    id           INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    name         VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS kintai (
    user_id     INTEGER NOT NULL,
    date        CHAR(8) NOT NULL,
    attend_time CHAR(4),
    leave_time  CHAR(4),
    remarks     CHAR(255),
    PRIMARY KEY(
        user_id,
        date
    )
);

