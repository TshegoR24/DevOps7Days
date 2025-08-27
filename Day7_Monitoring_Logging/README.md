# Day 7: Monitoring & Logging

## Overview
This day focuses on setting up comprehensive monitoring and logging for our Kubernetes applications using:
- **Prometheus** for metrics collection
- **Grafana** for visualization and dashboards
- **Loki** for log aggregation (lighter alternative to ELK Stack)

## Architecture
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Application   │    │   Prometheus    │    │     Grafana     │
│   (K8s Pods)    │───▶│   (Metrics)     │───▶│   (Dashboards)  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Application   │    │     Loki        │    │   AlertManager  │
│   (Logs)        │───▶│   (Log Agg)     │───▶│   (Alerts)      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## Prerequisites
- Kubernetes cluster (Minikube, Docker Desktop, or cloud)
- Helm installed
- kubectl configured

## Quick Start

### 1. Install Prometheus & Grafana Stack
```bash
# Add Helm repositories
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# Install Prometheus Stack (includes Grafana)
helm install monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  --set grafana.enabled=true \
  --set prometheus.enabled=true
```

### 2. Install Loki for Logging
```bash
# Install Loki
helm install loki grafana/loki \
  --namespace monitoring \
  --set loki.auth_enabled=false
```

### 3. Access Grafana
```bash
# Port forward Grafana service
kubectl port-forward svc/monitoring-grafana 3000:80 -n monitoring

# Access at: http://localhost:3000
# Default credentials: admin / prom-operator
```

### 4. Deploy Sample Application
```bash
# Deploy the sample app with monitoring enabled
kubectl apply -f sample-app.yaml
kubectl apply -f service.yaml
```

### 5. Generate Traffic & Test
```bash
# Port forward the application
kubectl port-forward svc/sample-app-service 8080:80

# Generate traffic
curl http://localhost:8080/health
curl http://localhost:8080/metrics
```

## Components

### Prometheus
- **Purpose**: Metrics collection and storage
- **Port**: 9090
- **Features**: 
  - Kubernetes metrics
  - Application metrics
  - Node metrics
  - Custom metrics

### Grafana
- **Purpose**: Visualization and dashboards
- **Port**: 3000
- **Features**:
  - Pre-built dashboards
  - Custom dashboards
  - Alerting
  - Log visualization

### Loki
- **Purpose**: Log aggregation
- **Features**:
  - Lightweight log storage
  - LogQL query language
  - Integration with Grafana

## Dashboards

### 1. Kubernetes Cluster Overview
- Node CPU/Memory usage
- Pod status and health
- Namespace resource usage

### 2. Application Metrics
- Request rate and latency
- Error rates
- Custom business metrics

### 3. Infrastructure Monitoring
- Container resource usage
- Network metrics
- Storage metrics

## Alerts

### Default Alerts
- High CPU usage (>80%)
- High memory usage (>80%)
- Pod restart frequency
- Node not ready

### Custom Alerts
- Application error rate > 5%
- Response time > 2 seconds
- Custom business metrics

## Logging Configuration

### Application Logs
```yaml
# Example log configuration for Python app
logging:
  level: INFO
  format: json
  output: stdout
```

### Kubernetes Logs
- Container logs automatically collected
- Node logs via node-exporter
- Audit logs (if enabled)

## Troubleshooting

### Common Issues
1. **Grafana not accessible**
   - Check if port-forward is running
   - Verify service exists: `kubectl get svc -n monitoring`

2. **No metrics showing**
   - Check Prometheus targets: `kubectl port-forward svc/monitoring-kube-prometheus-prometheus 9090:9090`
   - Verify service monitors are configured

3. **Logs not appearing**
   - Check Loki is running: `kubectl get pods -n monitoring -l app=loki`
   - Verify log shipping configuration

### Useful Commands
```bash
# Check all monitoring pods
kubectl get pods -n monitoring

# View Prometheus targets
kubectl port-forward svc/monitoring-kube-prometheus-prometheus 9090:9090

# Check Loki logs
kubectl logs -n monitoring -l app=loki

# View Grafana logs
kubectl logs -n monitoring -l app=grafana
```

## Next Steps
1. Create custom dashboards for your applications
2. Set up alerting rules
3. Configure log retention policies
4. Add custom metrics to applications
5. Set up log parsing and filtering

## Resources
- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)
- [Loki Documentation](https://grafana.com/docs/loki/)
- [Kubernetes Monitoring Best Practices](https://kubernetes.io/docs/tasks/debug-application-cluster/resource-usage-monitoring/)
