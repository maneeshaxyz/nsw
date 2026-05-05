# Build execution image
FROM alpine:3.20

ARG MIGRATE_VERSION=v4.17.0

RUN apk add --no-cache \
    ca-certificates \
    postgresql-client \
    curl \
    tar

# OPENSHIFT COMPLIANCE: UID 1001, GID 0
RUN adduser -D -u 1001 -G root -s /bin/false migrate

WORKDIR /migrations

# Install migrate binary directly (no upstream image)
RUN curl -L https://github.com/golang-migrate/migrate/releases/download/${MIGRATE_VERSION}/migrate.linux-amd64.tar.gz \
    | tar xvz \
 && mv migrate /usr/local/bin/migrate \
 && chmod +x /usr/local/bin/migrate

# Copy SQL migrations
COPY backend/internal/database/migrations/*.sql ./

RUN chgrp -R 0 /migrations && \
    chmod -R g+rwX /migrations

USER 1001