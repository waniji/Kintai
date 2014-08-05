# NAME

Kintai - 勤怠管理Webアプリケーション

# Install

ソースの取得

```
git clone git@gitub.com:waniji/kintai.git
cd kintai
```

依存モジュールのインストール

```
carton install --development
```

DBの作成

```
sqlite3 db/development.db < sql/sqlite.sql
```

起動

```
carton exec -- perl -Ilib script/kintai-server
```

