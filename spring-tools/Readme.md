
# .env
# docker-compose.dev.yml
# docker-compose.prod.yml
# docker-compose.monitoring.yml
# docker-compose.tools.yml
# prometheus.yml
# Dockerfile
# src/main/resources/application-dev.properties
# src/main/resources/application-prod.properties
# ──────────────────────────────────────────────────────────────────────────────

# ==========================
# .env (shared variables)
# ==========================
# Adjust to your environment as needed
COMPOSE_PROJECT_NAME=petclinic
PETCLINIC_IMAGE=localhost:8082/petclinic/app
PETCLINIC_TAG_DEV=dev
PETCLINIC_TAG_PROD=prod
APP_PORT=8080

# MySQL
MYSQL_DB=petclinic
MYSQL_USER=petclinic
MYSQL_PASSWORD=petclinic
MYSQL_ROOT_PASSWORD=root
MYSQL_PORT=3306

# Postgres
POSTGRES_DB=petclinic
POSTGRES_USER=petclinic
POSTGRES_PASSWORD=petclinic
POSTGRES_PORT=5432

# Monitoring
PROMETHEUS_PORT=9090
GRAFANA_PORT=3000

# Tools
NEXUS_PORT_UI=8081
NEXUS_PORT_DOCKER=8082
SONARQUBE_PORT=9000


# ============================================================================
# docker-compose.dev.yml  (Development: MySQL + volumes)
# ============================================================================
version: "3.9"

name: ${COMPOSE_PROJECT_NAME}-dev

services:
  mysql:
    image: mysql:8.4
    container_name: ${COMPOSE_PROJECT_NAME}-mysql
    command: ["--default-authentication-plugin=mysql_native_password", "--lower_case_table_names=1"]
    environment:
      MYSQL_DATABASE: ${MYSQL_DB}
      MYSQL_USER: ${MYSQL_USER}
      MYSQL_PASSWORD: ${MYSQL_PASSWORD}
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
    ports:
      - "${MYSQL_PORT}:3306"
    volumes:
      - mysql_data:/var/lib/mysql
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "127.0.0.1", "-u", "root", "-p${MYSQL_ROOT_PASSWORD}"]
      interval: 10s
      timeout: 5s
      retries: 10

  petclinic:
    image: ${PETCLINIC_IMAGE}:${PETCLINIC_TAG_DEV}
    container_name: ${COMPOSE_PROJECT_NAME}-app-dev
    depends_on:
      mysql:
        condition: service_healthy
    environment:
      SPRING_PROFILES_ACTIVE: dev
      SPRING_DATASOURCE_URL: jdbc:mysql://mysql:3306/${MYSQL_DB}?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC
      SPRING_DATASOURCE_USERNAME: ${MYSQL_USER}
      SPRING_DATASOURCE_PASSWORD: ${MYSQL_PASSWORD}
    ports:
      - "${APP_PORT}:8080"
    # mount local target/ for hot-reload of the built jar if you prefer (optional)
    volumes:
      - type: volume
        source: logs
        target: /app/logs
    healthcheck:
      test: ["CMD", "curl", "-fsS", "http://localhost:8080/actuator/health"]
      interval: 10s
      timeout: 5s
      retries: 20

volumes:
  mysql_data:
  logs:


# ============================================================================
# docker-compose.prod.yml (Production-like: Postgres + volumes)
# ============================================================================
version: "3.9"

name: ${COMPOSE_PROJECT_NAME}-prod

services:
  postgres:
    image: postgres:16
    container_name: ${COMPOSE_PROJECT_NAME}-postgres
    environment:
      POSTGRES_DB: ${POSTGRES_DB}
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    ports:
      - "${POSTGRES_PORT}:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER}"]
      interval: 10s
      timeout: 5s
      retries: 10

  petclinic:
    image: ${PETCLINIC_IMAGE}:${PETCLINIC_TAG_PROD}
    container_name: ${COMPOSE_PROJECT_NAME}-app-prod
    depends_on:
      postgres:
        condition: service_healthy
    environment:
      SPRING_PROFILES_ACTIVE: prod
      SPRING_DATASOURCE_URL: jdbc:postgresql://postgres:5432/${POSTGRES_DB}
      SPRING_DATASOURCE_USERNAME: ${POSTGRES_USER}
      SPRING_DATASOURCE_PASSWORD: ${POSTGRES_PASSWORD}
    ports:
      - "${APP_PORT}:8080"
    volumes:
      - type: volume
        source: logs
        target: /app/logs
    healthcheck:
      test: ["CMD", "curl", "-fsS", "http://localhost:8080/actuator/health"]
      interval: 10s
      timeout: 5s
      retries: 20

volumes:
  postgres_data:
  logs:


# ============================================================================
# docker-compose.monitoring.yml  (Prometheus + Grafana)
# ============================================================================
version: "3.9"

name: ${COMPOSE_PROJECT_NAME}-mon

services:
  prometheus:
    image: prom/prometheus:latest
    container_name: ${COMPOSE_PROJECT_NAME}-prometheus
    command: ["--config.file=/etc/prometheus/prometheus.yml", "--web.enable-lifecycle"]
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml:ro
      - prom_data:/prometheus
    ports:
      - "${PROMETHEUS_PORT}:9090"

  grafana:
    image: grafana/grafana:latest
    container_name: ${COMPOSE_PROJECT_NAME}-grafana
    environment:
      - GF_SECURITY_ADMIN_USER=admin
      - GF_SECURITY_ADMIN_PASSWORD=admin
    ports:
      - "${GRAFANA_PORT}:3000"
    volumes:
      - grafana_data:/var/lib/grafana
    depends_on:
      - prometheus

volumes:
  prom_data:
  grafana_data:


# ============================================================================
# docker-compose.tools.yml  (Nexus for images/artifacts + SonarQube)
# ============================================================================
version: "3.9"

name: ${COMPOSE_PROJECT_NAME}-tools

services:
  nexus:
    image: sonatype/nexus3:latest
    container_name: ${COMPOSE_PROJECT_NAME}-nexus
    ports:
      - "${NEXUS_PORT_UI}:8081"    # Nexus UI
      - "${NEXUS_PORT_DOCKER}:8082" # Docker (hosted) registry (configure in UI)
    volumes:
      - nexus_data:/nexus-data

  sonarqube:
    image: sonarqube:latest
    container_name: ${COMPOSE_PROJECT_NAME}-sonarqube
    environment:
      - SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true
    ports:
      - "${SONARQUBE_PORT}:9000"
    volumes:
      - sonar_data:/opt/sonarqube/data
      - sonar_extensions:/opt/sonarqube/extensions
      - sonar_logs:/opt/sonarqube/logs

volumes:
  nexus_data:
  sonar_data:
  sonar_extensions:
  sonar_logs:


# ============================================================================
# prometheus.yml (scrapes Spring Boot metrics from Petclinic)
# ============================================================================
# Make sure Spring exposes Prometheus at /actuator/prometheus
# (see application-*.properties below)

global:
  scrape_interval: 15s

scrape_configs:
  - job_name: "petclinic"
    metrics_path: /actuator/prometheus
    static_configs:
      - targets: ["petclinic-app-dev:8080", "petclinic-app-prod:8080"]
        labels:
          service: petclinic


# ============================================================================
# Dockerfile (multi-stage build; publishes to Nexus Docker registry)
# ============================================================================
# Build stage
FROM maven:3.9.9-eclipse-temurin-17 AS build
WORKDIR /src
COPY . .
# Run tests; you can skip tests for faster local cycles by adding -DskipTests
RUN mvn -B -DskipTests package

# Runtime stage
FROM eclipse-temurin:17-jre
WORKDIR /app
# copy the fat jar (adjust path/name to actual Petclinic artifact if different)
COPY --from=build /src/target/*.jar /app/app.jar
EXPOSE 8080
# health endpoint provided by Spring Boot Actuator
HEALTHCHECK CMD curl -fsS http://localhost:8080/actuator/health || exit 1
ENTRYPOINT ["java","-jar","/app/app.jar"]


# ============================================================================
# src/main/resources/application-dev.properties (MySQL + Actuator/Micrometer)
# ============================================================================
spring.datasource.url=jdbc:mysql://localhost:${MYSQL_PORT:${MYSQL_PORT}}/${MYSQL_DB:petclinic}?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC
spring.datasource.username=${MYSQL_USER:petclinic}
spring.datasource.password=${MYSQL_PASSWORD:petclinic}
spring.jpa.hibernate.ddl-auto=none
spring.sql.init.mode=always

# Actuator & Prometheus
management.endpoints.web.exposure.include=health,info,prometheus
management.endpoint.health.probes.enabled=true
management.health.livenessstate.enabled=true
management.health.readinessstate.enabled=true


# ============================================================================
# src/main/resources/application-prod.properties (Postgres + Actuator)
# ============================================================================
spring.datasource.url=jdbc:postgresql://localhost:${POSTGRES_PORT:${POSTGRES_PORT}}/${POSTGRES_DB:petclinic}
spring.datasource.username=${POSTGRES_USER:petclinic}
spring.datasource.password=${POSTGRES_PASSWORD:petclinic}
spring.jpa.hibernate.ddl-auto=none
spring.sql.init.mode=always

# Actuator & Prometheus
management.endpoints.web.exposure.include=health,info,prometheus
management.endpoint.health.probes.enabled=true
management.health.livenessstate.enabled=true
management.health.readinessstate.enabled=true
