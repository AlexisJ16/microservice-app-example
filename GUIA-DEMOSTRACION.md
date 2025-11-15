# 🎯 Guía de Demostración - Microservicios en Kubernetes

## ✅ Estado del Proyecto

**COMPLETADO Y FUNCIONAL** - Todos los servicios están operativos y comunicándose correctamente.

---

## 🏗️ Arquitectura Implementada

### Microservicios Desplegados

1. **Frontend (Vue.js)** - Puerto 8080
   - SPA servida por Nginx
   - Autenticación JWT
   - Gestión de TODOs

2. **Auth Service (Go)** - Puerto 8000
   - Autenticación de usuarios
   - Generación de tokens JWT
   - Validación de credenciales

3. **Users Service (Java/Spring Boot)** - Puerto 8083 (Service: 5001)
   - Gestión de usuarios
   - Base de datos H2 en memoria
   - Validación de permisos

4. **Posts/TODOs Service (Node.js)** - Puerto 8082 (Service: 5002)
   - CRUD de tareas
   - Persistencia en Redis
   - Almacenamiento persistente (PVC)

### Componentes de Infraestructura

- **Ingress NGINX**: Enrutamiento HTTP externo
- **Network Policies**: Seguridad de red (default deny + allow rules)
- **HPA**: Autoscaling basado en CPU para users-service
- **ConfigMaps & Secrets**: Configuración centralizada
- **PVC**: Almacenamiento persistente para posts-service
- **Prometheus + Grafana**: Monitoreo y observabilidad

---

## 🚀 Guía de Demostración Paso a Paso

### 1️⃣ **Verificar Estado del Clúster**

```bash
# Ver todos los pods
kubectl get pods -n microservices-ns

# Ver servicios
kubectl get svc -n microservices-ns

# Ver ingress
kubectl get ingress -n microservices-ns

# Ver HPA
kubectl get hpa -n microservices-ns
```

**Resultado esperado:** Todos los pods en estado `Running` y `Ready 1/1`

---

### 2️⃣ **Acceder a la Aplicación Frontend**

```bash
# Crear port-forward del Ingress Controller
kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 8080:80
```

**Accede a:** `http://localhost:8080`

#### Credenciales de prueba:

| Usuario | Password | Rol |
|---------|----------|-----|
| `admin` | `admin` | Administrador |
| `johnd` | `foo` | Usuario estándar |
| `janed` | `ddd` | Usuario estándar |

---

### 3️⃣ **Demostrar Funcionalidad de TODOs**

1. **Login** con credenciales `admin/admin`
2. **Crear nuevos TODOs** usando el campo de texto
3. **Ver contador** de TODOs en tiempo real (3)
4. **Eliminar TODOs** usando el botón X
5. **Cerrar sesión** y probar con otro usuario

**Demostración técnica:**
```bash
# Ver logs del servicio de todos
kubectl logs -f -n microservices-ns -l app=posts

# Ver logs del auth service
kubectl logs -f -n microservices-ns -l app=auth
```

---

### 4️⃣ **Demostrar Network Policies (Seguridad)**

```bash
# Ver políticas aplicadas
kubectl get networkpolicies -n microservices-ns

# Describir política de denegación por defecto
kubectl describe networkpolicy default-deny-all -n microservices-ns

# Describir política de tráfico permitido
kubectl describe networkpolicy allow-app-traffic -n microservices-ns
```

**Explicación:**
- Default deny: Bloquea todo el tráfico por defecto
- Allow rules: Solo permite comunicación necesaria entre servicios
- Seguridad por capas: Ingress → Services → Pods

---

### 5️⃣ **Demostrar Horizontal Pod Autoscaler (HPA)**

```bash
# Ver estado del HPA
kubectl get hpa -n microservices-ns

# Ver detalles del HPA
kubectl describe hpa users-hpa -n microservices-ns
```

**Generar carga para probar autoscaling:**
```bash
# Generar tráfico al servicio de usuarios
kubectl run -i --tty load-generator --rm --image=busybox --restart=Never -n microservices-ns -- /bin/sh

# Dentro del pod, ejecutar:
while true; do wget -q -O- http://users-service:5001/users/; done
```

**Observar escalado:**
```bash
# En otra terminal, ver cómo escalan los pods
watch kubectl get hpa -n microservices-ns
watch kubectl get pods -n microservices-ns -l app=users
```

---

### 6️⃣ **Demostrar Monitoreo con Prometheus y Grafana**

#### **Prometheus**

```bash
# Port-forward a Prometheus
kubectl port-forward -n monitoring svc/kube-prometheus-stack-prometheus 9090:9090
```

**Accede a:** `http://localhost:9090`

**Queries de ejemplo:**
```promql
# CPU por namespace
sum(rate(container_cpu_usage_seconds_total{namespace="microservices-ns"}[5m])) by (pod)

# Memoria por pod
container_memory_usage_bytes{namespace="microservices-ns"}

# Tasa de solicitudes HTTP
rate(http_requests_total[5m])
```

#### **Grafana**

```bash
# Port-forward a Grafana
kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 3000:80
```

**Accede a:** `http://localhost:3000`

**Credenciales:**
- Usuario: `admin`
- Password: `admin123`

**Dashboards disponibles:**
- Kubernetes / Compute Resources / Namespace (Pods)
- Kubernetes / Compute Resources / Cluster
- Node Exporter / Nodes

---

### 7️⃣ **Demostrar Persistencia de Datos**

```bash
# Ver PVC
kubectl get pvc -n microservices-ns

# Describir PVC
kubectl describe pvc posts-data-pvc -n microservices-ns

# Ver datos persistidos
kubectl exec -it -n microservices-ns deployment/posts-deployment -- ls -la /app/data
```

**Demostración:**
1. Crear TODOs en la aplicación
2. Eliminar el pod de posts:
   ```bash
   kubectl delete pod -n microservices-ns -l app=posts
   ```
3. Esperar que se recree automáticamente
4. Verificar que los TODOs persisten (gracias al PVC)

---

### 8️⃣ **Demostrar ConfigMaps y Secrets**

```bash
# Ver ConfigMap
kubectl get configmap app-config -n microservices-ns -o yaml

# Ver Secret (valores codificados)
kubectl get secret app-secret -n microservices-ns -o yaml

# Decodificar secret
kubectl get secret app-secret -n microservices-ns -o jsonpath='{.data.JWT_SECRET}' | base64 -d
```

---

## 🔍 Comandos Útiles para Troubleshooting

```bash
# Ver logs de todos los servicios
bash view-logs.sh

# Ver estado en tiempo real de los pods
bash watch-pods.sh

# Mostrar información de acceso
bash show-access-info.sh

# Limpiar todo el proyecto
bash cleanup.sh
```

---

## 📊 Métricas y Observabilidad

### Endpoints de Salud

```bash
# Health check del auth service
curl http://localhost:8080/version

# Listar usuarios (requiere token JWT)
curl http://localhost:8080/users/
```

### Logs Centralizados

```bash
# Ver todos los logs en tiempo real
kubectl logs -f -n microservices-ns --all-containers=true --selector='app in (client,auth,users,posts)'
```

---

## 🎓 Conceptos Kubernetes Demostrados

✅ **Deployments** - Gestión declarativa de aplicaciones
✅ **Services** - Descubrimiento y balanceo de carga
✅ **Ingress** - Enrutamiento HTTP externo
✅ **ConfigMaps** - Configuración externalizada
✅ **Secrets** - Gestión segura de credenciales
✅ **PersistentVolumeClaims** - Almacenamiento persistente
✅ **NetworkPolicies** - Seguridad de red
✅ **HorizontalPodAutoscaler** - Escalado automático
✅ **Namespaces** - Aislamiento de recursos
✅ **Labels & Selectors** - Organización y selección de recursos

---

## 🏆 Resultados Finales

✅ **4 Microservicios** funcionando correctamente
✅ **Autenticación JWT** implementada
✅ **Network Policies** aplicadas (seguridad)
✅ **HPA** configurado (escalado automático)
✅ **Monitoreo** con Prometheus y Grafana
✅ **Persistencia** de datos implementada
✅ **Ingress** con enrutamiento correcto
✅ **Frontend funcional** con login y gestión de TODOs

---

## 📝 Notas Adicionales

- **Kind cluster name:** `microservices-cluster`
- **Namespace principal:** `microservices-ns`
- **Namespace de monitoreo:** `monitoring`
- **Ingress Controller:** NGINX (namespace: `ingress-nginx`)

---

## 🔄 Comandos de Mantenimiento

```bash
# Reiniciar un servicio específico
kubectl rollout restart deployment/client-deployment -n microservices-ns
kubectl rollout restart deployment/auth-deployment -n microservices-ns
kubectl rollout restart deployment/users-deployment -n microservices-ns
kubectl rollout restart deployment/posts-deployment -n microservices-ns

# Ver historial de despliegues
kubectl rollout history deployment/users-deployment -n microservices-ns

# Rollback a versión anterior
kubectl rollout undo deployment/users-deployment -n microservices-ns

# Escalar manualmente un deployment
kubectl scale deployment users-deployment --replicas=3 -n microservices-ns
```

---

## 🎉 ¡Proyecto Completado!

Este proyecto demuestra una arquitectura completa de microservicios en Kubernetes con:
- Múltiples lenguajes (Go, Java, Node.js, Vue.js)
- Mejores prácticas de seguridad
- Observabilidad y monitoreo
- Escalabilidad automática
- Persistencia de datos
- Configuración centralizada

**¡Listo para demostrar en producción o presentar como proyecto académico/profesional!**
