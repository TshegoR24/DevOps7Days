# Day 7: Monitoring & Logging - Quick Start Guide

## 🚀 Quick Setup (5 minutes)

### Prerequisites
- Kubernetes cluster (Minikube, Docker Desktop, or cloud)
- Helm installed
- kubectl configured
- Docker installed

### Option 1: Automated Setup (Recommended)

#### For Linux/Mac:
```bash
cd Day7_Monitoring_Logging
chmod +x deploy.sh load-test.sh
./deploy.sh
```

#### For Windows PowerShell:
```powershell
cd Day7_Monitoring_Logging
.\deploy.ps1
```

### Option 2: Manual Setup

#### 1. Build and Deploy Application
```bash
# Build the application
docker build -t sample-app:latest .

# Deploy to Kubernetes
kubectl apply -f sample-app.yaml
kubectl apply -f servicemonitor.yaml
```

#### 2. Install Monitoring Stack
```bash
# Add Helm repositories
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# Install Prometheus & Grafana
helm install monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  --set grafana.enabled=true \
  --set prometheus.enabled=true

# Install Loki for logging
helm install loki grafana/loki \
  --namespace monitoring \
  --set loki.auth_enabled=false
```

#### 3. Deploy Dashboard
```bash
kubectl apply -f grafana-dashboard.yaml
```

## 🎯 Access Your Monitoring

### 1. Grafana Dashboard
```bash
kubectl port-forward svc/monitoring-grafana 3000:80 -n monitoring
```
- **URL**: http://localhost:3000
- **Username**: admin
- **Password**: prom-operator

### 2. Prometheus
```bash
kubectl port-forward svc/monitoring-kube-prometheus-prometheus 9090:9090 -n monitoring
```
- **URL**: http://localhost:9090

### 3. Sample Application
```bash
kubectl port-forward svc/sample-app-service 8080:80
```
- **URL**: http://localhost:8080
- **Health**: http://localhost:8080/health
- **Metrics**: http://localhost:8080/metrics

## 🧪 Generate Traffic

### Load Testing
```bash
# Linux/Mac
./load-test.sh

# Windows PowerShell
.\load-test.ps1
```

### Manual Testing
```bash
# Generate some traffic
for i in {1..50}; do
  curl http://localhost:8080/api/data
  curl http://localhost:8080/api/slow
  sleep 0.1
done
```

## 📊 What You'll See

### Grafana Dashboards
1. **Sample Application Dashboard** - Custom dashboard showing:
   - Request rate and latency
   - Error rates
   - Active requests
   - Pod resource usage

2. **Kubernetes Cluster Overview** - Built-in dashboard showing:
   - Node metrics
   - Pod status
   - Resource usage

### Prometheus Metrics
- `app_request_total` - Total requests by endpoint
- `app_request_latency_seconds` - Request latency
- `app_active_requests` - Currently active requests
- `app_error_total` - Error counts

### Logs in Grafana
- Application logs via Loki
- Kubernetes pod logs
- Structured logging with JSON format

## 🔧 Troubleshooting

### Common Issues

#### 1. Grafana not accessible
```bash
# Check if pods are running
kubectl get pods -n monitoring

# Check service
kubectl get svc -n monitoring
```

#### 2. No metrics showing
```bash
# Check Prometheus targets
kubectl port-forward svc/monitoring-kube-prometheus-prometheus 9090:9090 -n monitoring
# Then visit http://localhost:9090/targets
```

#### 3. Application not responding
```bash
# Check application pods
kubectl get pods -l app=sample-app

# Check logs
kubectl logs -l app=sample-app
```

### Useful Commands
```bash
# Check all monitoring components
kubectl get all -n monitoring

# View application logs
kubectl logs -l app=sample-app -f

# Check ServiceMonitor
kubectl get servicemonitor

# Check Prometheus rules
kubectl get prometheusrule -n monitoring
```

## 🎯 Next Steps

1. **Explore Dashboards**: Navigate through Grafana and discover the built-in dashboards
2. **Create Custom Dashboards**: Build dashboards specific to your applications
3. **Set Up Alerts**: Configure alerting rules for critical metrics
4. **Add More Applications**: Deploy additional applications and monitor them
5. **Log Analysis**: Use Loki to analyze application logs and troubleshoot issues

## 📚 Learning Resources

- [Prometheus Query Language (PromQL)](https://prometheus.io/docs/prometheus/latest/querying/)
- [Grafana Dashboard Creation](https://grafana.com/docs/grafana/latest/dashboards/)
- [Loki LogQL](https://grafana.com/docs/loki/latest/logql/)
- [Kubernetes Monitoring Best Practices](https://kubernetes.io/docs/tasks/debug-application-cluster/resource-usage-monitoring/)

## 🎉 Congratulations!

You now have a complete monitoring and logging stack running in Kubernetes! This setup provides:

- ✅ **Metrics Collection** with Prometheus
- ✅ **Visualization** with Grafana
- ✅ **Log Aggregation** with Loki
- ✅ **Application Monitoring** with custom metrics
- ✅ **Load Testing** capabilities
- ✅ **Health Checks** and alerts

Happy monitoring! 🚀
