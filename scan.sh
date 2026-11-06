#!/bin/bash

IMAGE="fastapi-app:v2"

mkdir -p reports

STAMP=$(date +%Y%m%d-%H%M%S)
REPORT="reports/trivy-${STAMP}.json"

echo "Starting Trivy scan for $IMAGE"

trivy image --format json --output "$REPORT" "$IMAGE"

if [ $? -ne 0 ]; then
    echo "Trivy scan failed"
    exit 1
fi

python3 - "$REPORT" <<'PY'
import json
import time
import urllib.request
import sys

report_file = sys.argv[1]

with open(report_file) as f:
    data = json.load(f)

severities = ["CRITICAL", "HIGH", "MEDIUM", "LOW", "UNKNOWN"]
counts = {severity: 0 for severity in severities}

for result in data.get("Results") or []:
    for vuln in result.get("Vulnerabilities") or []:
        severity = vuln.get("Severity", "UNKNOWN").upper()
        if severity not in counts:
            severity = "UNKNOWN"
        counts[severity] += 1

total = sum(counts.values())

metrics = []

for severity, count in counts.items():
    metrics.append(
        f'trivy_vulnerabilities{{image="fastapi-app:v2",severity="{severity}"}} {count}'
    )

metrics.append(f'trivy_total_vulnerabilities{{image="fastapi-app:v2"}} {total}')
metrics.append(f'trivy_scan_timestamp_seconds{{image="fastapi-app:v2"}} {time.time()}')
metrics.append(f'trivy_scan_success{{image="fastapi-app:v2"}} 1')

payload = "\n".join(metrics) + "\n"

request = urllib.request.Request(
    "http://localhost:9091/metrics/job/trivy_scan",
    data=payload.encode(),
    method="PUT",
    headers={"Content-Type": "text/plain"}
)

with urllib.request.urlopen(request) as response:
    print("Metrics uploaded:", response.status)

print("Vulnerability summary:", counts)
print("Total vulnerabilities:", total)
PY
echo "Scan report saved at: $REPORT"
