# Reviewed Flask/PostgreSQL files

Source reviewed: javierdelapuente/flask-12factor database branch, commit b01c9e37cce216840bb2c069b5fc2deeed474cb4.

Create Dockerfile, compose.yaml, start.sh and .dockerignore at the repository root. Update requirements.txt with the supplied content. Keep migrate.py unchanged. The supplied app.py differs from the reviewed branch only by using headers.get('User-Agent', '') so requests without that header do not violate the database NOT NULL constraint.

This is a NEW-stack recipe, not an in-place migration of your existing standalone PostgreSQL resource. Do not delete the current database or its volume. Existing visitor data is not automatically imported.

In Coolify create a separate Git-backed Application, select branch database and Compose build strategy; Base Directory /; Docker Compose Location /compose.yaml. Clear old pre/post-deployment and start-command overrides on the NEW resource: Dockerfile/start.sh handle startup and migrations. Do not change the old running resource.

Load the Compose configuration. Coolify should generate SERVICE_USER_POSTGRES and SERVICE_PASSWORD_64_POSTGRES. Confirm both exist without exposing values. No manual POSTGRESQL_DB_CONNECT_STRING entry is needed: Compose constructs it. These SERVICE_* generation rules are Coolify-specific. Outside Coolify define those two variables in a private local environment.

Configure a NEW test domain for service web using https://<chosen-test-domain>:5000. Port 5000 tells the Coolify proxy the internal app port; public HTTPS remains 443. Do not expose db publicly or add host port mappings.

First startup waits for PostgreSQL health, runs python migrate.py in the new app image, and starts Gunicorn only on migration success. Startup repeats on app restart. The schema operation is idempotent for this demo, not a replacement for Alembic/Flask-Migrate for future schema evolution. Keep one web instance until migration coordination is implemented.

The web health check calls /visitors, which checks DB/table availability without inserting rows. GET / inserts a visitor by application design.

PostgreSQL18 volume mounts /var/lib/postgresql. Use a separate new volume for this test stack. Never change PostgreSQL major version against an existing volume without a migration plan.

Validation: real isolated Docker Compose build/start against the exact source commit; table creation, HTTP read/write, non-root app, read-only health checks, web restart and full container recreation with data persistence, and startup failure before Gunicorn when DB is unavailable. All passed; test containers, volume and app image removed. Existing running container IDs unchanged. See TEST-RESULT.json. This validates Docker behavior; full Coolify parsing/domain deployment must still be verified when the new resource is created.

The Dockerfile makes start.sh executable, so no separate git executable-bit change is required. Keep shell files LF, not Windows CRLF. The .dockerignore is deliberately an allowlist for the current tiny repo; extend it and Dockerfile COPY when adding application files.

Backups: configure/test database dumps before storing valuable data. Persistent volume is not a backup. This recipe uses the per-stack PostgreSQL bootstrap role for the demo; it has elevated privileges inside this dedicated DB container, not a restricted production runtime role.
