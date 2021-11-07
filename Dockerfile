FROM postgres:14
ENV POSTGRES_PASSWORD=postgres
ADD init.sql /docker-entrypoint-initdb.d/