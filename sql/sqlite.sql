CREATE TABLE IF NOT EXISTS user (
    id           INTEGER NOT NULL PRIMARY KEY,
    name         VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS kintai (
    user_id     INTEGER NOT NULL,
    date        CHAR(8) NOT NULL,
    attend_time CHAR(6),
    leave_time  CHAR(6),
    PRIMARY KEY(
        user_id,
        date
    )
);

