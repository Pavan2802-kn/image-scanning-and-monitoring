# Docker Container Vulnerability Monitoring & Security Dashboard

A DevSecOps project that integrates **Trivy, Docker, Prometheus, Pushgateway, and Grafana** to scan container images, identify security vulnerabilities, and visualize security findings through a centralized monitoring dashboard.

## 1. Project Overview

This project implements automated Docker image vulnerability scanning and monitoring for a Python FastAPI application.

Trivy scans Docker images for known vulnerabilities in operating system packages and application dependencies. The scan results are stored as JSON reports, while vulnerability metrics are exported to Prometheus through Pushgateway and visualized using Grafana.

### Key Objectives

* Identify security vulnerabilities in Docker images.
* Detect Critical, High, Medium, and Low severity vulnerabilities.
* Implement container security best practices.
* Monitor vulnerability counts using Prometheus.
* Build Grafana dashboards for security visibility.
* Maintain historical scan reports for auditing.
* Reduce vulnerabilities through package updates and image hardening.

## 2. Architecture

```text
           FastAPI Application
                   |
                   v
             Docker Image
                   |
                   v
             Trivy Scanner
                   |
          +--------+---------+
          |                  |
          v                  v
      JSON Reports     Python Exporter
                             |
                             v
                       Pushgateway
                             |
                             v
                        Prometheus
                             |
                             v
                          Grafana
                             |
                             v
                  Security Monitoring
                       Dashboard
```

## 3. Technology Stack

| Technology     | Purpose                          |
| -------------- | -------------------------------- |
| Ubuntu Linux   | Host operating system            |
| AWS EC2        | Cloud infrastructure             |
| Docker         | Containerization                 |
| Python 3.12    | Application runtime              |
| FastAPI        | Web application framework        |
| Trivy          | Container vulnerability scanner  |
| Prometheus     | Metrics collection and storage   |
| Pushgateway    | Receives scan metrics            |
| Grafana        | Security monitoring dashboard    |
| Docker Compose | Monitoring service orchestration |

## 4. Project Structure

```text
docker-security-monitoring/
│
├── Dockerfile
├── requirements.txt
├── main.py
├── .dockerignore
│
└── trivy-monitoring/
    ├── docker-compose.yml
    ├── prometheus.yml
    ├── scan.sh
    ├── exporter.py
    │
    └── reports/
        ├── trivy-scan-1.json
        ├── trivy-scan-2.json
        └── trivy-scan-3.json
```

## 5. Dockerfile Security Implementation

The Dockerfile incorporates security best practices:

* Uses a lightweight Python 3.12 slim base image.
* Creates a dedicated non-root user.
* Uses `COPY --chown` to configure file ownership.
* Installs Python dependencies without retaining pip cache.
* Implements Docker HEALTHCHECK.
* Exposes application port 8000.
* Runs FastAPI using Uvicorn.

### Build Docker Image

```bash
docker build -t fastapi-app:v2 .
```

### Run Container

```bash
docker run -d \
  -p 8000:8000 \
  --name fastapi-container \
  fastapi-app:v2
```

## 6. Trivy Vulnerability Scanning

Trivy is used to identify known vulnerabilities in container images.

### Install Trivy on Ubuntu

```bash
sudo apt-get update
sudo apt-get install trivy -y
```

### Verify Installation

```bash
trivy --version
```

### Scan Docker Image

```bash
trivy image fastapi-app:v2
```

### Scan High and Critical Vulnerabilities

```bash
trivy image \
  --severity HIGH,CRITICAL \
  fastapi-app:v2
```

### Generate JSON Security Report

```bash
trivy image \
  --format json \
  --output trivy-report.json \
  fastapi-app:v2
```

### Scan Project Files

```bash
trivy fs \
  --scanners vuln,secret,misconfig \
  .
```

## 7. Prometheus and Grafana Monitoring

Docker Compose is used to deploy the monitoring infrastructure.

Services:

* Prometheus: Collects vulnerability metrics.
* Pushgateway: Receives metrics from the Python exporter.
* Grafana: Displays security metrics and scan trends.

### Start Monitoring Services

```bash
docker compose up -d
```

### Access Monitoring Interfaces

| Service     | URL                   |
| ----------- | --------------------- |
| Grafana     | http://65.2.130.21:3000 |
| Prometheus  | http://65.2.130.21:9090 |
| Pushgateway | http://65.2.130.21:9091 |

Configure Prometheus as a Grafana data source using:

```text
http://prometheus:9090
```

## 8. Grafana Dashboard Visualizations

The dashboard provides centralized visibility into container image security.

### Dashboard Panels

| Visualization | Monitoring Purpose         |
| ------------- | -------------------------- |
| Stat          | Critical vulnerabilities   |
| Stat          | High vulnerabilities       |
| Stat          | Medium vulnerabilities     |
| Stat          | Low vulnerabilities        |
| Pie Chart     | Vulnerability distribution |
| Time Series   | Vulnerability trends       |
| Stat          | Total vulnerabilities      |
| Stat          | Last scan status           |

### Prometheus Queries

Critical vulnerabilities:

```promql
trivy_vulnerabilities{severity="CRITICAL"}
```

High vulnerabilities:

```promql
trivy_vulnerabilities{severity="HIGH"}
```

Total vulnerabilities:

```promql
trivy_total_vulnerabilities
```

Vulnerability distribution:

```promql
sum by (severity) (trivy_vulnerabilities)
```

Scan status:

```promql
trivy_scan_success
```

## 9. Container Security Hardening

Additional runtime security restrictions are implemented:

```bash
docker run -d \
  --name fastapi-secure \
  -p 8000:8000 \
  --read-only \
  --tmpfs /tmp \
  --cap-drop ALL \
  --security-opt no-new-privileges:true \
  fastapi-app:v2
```

Security controls:

* Non-root container execution.
* Read-only root filesystem.
* Dropped unnecessary Linux capabilities.
* Prevention of privilege escalation.
* Restricted writable temporary storage.

## 10. Vulnerability Remediation Workflow

The following workflow is used to reduce vulnerabilities:

1. Scan Docker images using Trivy.
2. Identify vulnerable OS and Python packages.
3. Review CVE information and available fixed versions.
4. Update affected dependencies.
5. Rebuild the Docker image.
6. Perform another Trivy scan.
7. Compare vulnerability counts.
8. Publish updated metrics to Prometheus.
9. Monitor remediation progress in Grafana.

## 11. Key Outcomes

* Implemented container vulnerability scanning using Trivy.
* Established centralized vulnerability monitoring with Prometheus and Grafana.
* Created JSON reports for security auditing.
* Implemented non-root container execution.
* Added container health checks.
* Applied runtime security restrictions.
* Established a repeatable vulnerability remediation workflow.

## 12. Future Enhancements

* Integrate Trivy into Jenkins CI/CD pipelines.
* Implement automated image security gates.
* Push approved images to Amazon ECR.
* Configure Grafana alerts for Critical vulnerabilities.
* Implement automated scheduled vulnerability scans.
* Extend monitoring to multiple Docker images and environments.

## 13. Conclusion

This project demonstrates a practical DevSecOps implementation combining container security, vulnerability assessment, monitoring, and remediation.

It provides visibility into Docker image security and establishes a foundation for integrating vulnerability scanning into automated CI/CD workflows.

**Technologies:** Docker | Trivy | Prometheus | Grafana | Python | FastAPI | AWS EC2 | Ubuntu Linux
