# Aplicación de Microservicios - Migración a Kubernetes

[![GitHub Codespaces](https://img.shields.io/badge/Codespaces-Ready-blue?logo=github)](https://github.com/codespaces)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-Enabled-326CE5?logo=kubernetes)](https://kubernetes.io/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

## 📋 Descripción del Proyecto

Aplicación de microservicios completa que demuestra patrones modernos de arquitectura Cloud Native, implementando migración a Kubernetes con mejores prácticas de DevOps. El proyecto incluye autenticación, gestión de usuarios, TODOs, y un frontend interactivo, todo desplegable en Kubernetes con un solo comando.

### 🎯 Características Principales

- **Arquitectura de Microservicios**: 3 servicios backend independientes (Auth, Users, TODOs)
- **Frontend Moderno**: Aplicación Vue.js responsiva
- **Kubernetes Native**: Manifiestos completos siguiendo mejores prácticas
- **Seguridad**: NetworkPolicies, Secrets, RBAC
- **Escalabilidad**: HorizontalPodAutoscaler configurado
- **Observabilidad**: Stack completo de Prometheus + Grafana
- **GitHub Codespaces**: Entorno preconfigurado listo para usar

## 🏗️ Arquitectura

### Microservicios

#### 1. **Auth API** (Go)

Servicio de autenticación que genera tokens JWT.

- **Puerto**: 8000
- **Endpoints**:
  - `POST /login` - Autenticación de usuarios
- **Tecnología**: Go 1.18+

#### 2. **Users API** (Java/Spring Boot)

Gestión de datos de usuarios.

- **Puerto**: 8083
- **Endpoints**:
  - `GET /users` - Listar todos los usuarios
  - `GET /users/:username` - Obtener usuario por nombre
- **Tecnología**: Java 8, Spring Boot

#### 3. **TODOs API** (Node.js)

CRUD completo para tareas TODO.

- **Puerto**: 8082
- **Endpoints**:
  - `GET /todos` - Listar TODOs del usuario
  - `POST /todos` - Crear nuevo TODO
  - `DELETE /todos/:taskId` - Eliminar TODO
- **Tecnología**: Node.js 8+, Express
- **Storage**: En memoria + Redis para logging

#### 4. **Frontend** (Vue.js)

Interfaz de usuario interactiva.

- **Puerto**: 8080
- **Tecnología**: Vue.js 2.x, Webpack

### Arquitectura en Kubernetes

```text
┌─────────────────────────────────────────────────────────┐
│                    Ingress Controller                    │
│              (Enrutamiento basado en paths)             │
└──────────────────┬──────────────┬──────────────────────┘
                   │              │
         ┌─────────┴────┐  ┌─────┴──────┐  ┌─────────┐
         │   Client     │  │   Users    │  │  Posts  │
         │   Service    │  │  Service   │  │ Service │
         └──────┬───────┘  └─────┬──────┘  └────┬────┘
                │                 │              │
         ┌──────▼───────┐  ┌─────▼──────┐  ┌───▼─────┐
         │   Client     │  │   Users    │  │  Posts  │
         │  Deployment  │  │ Deployment │  │Deployment│
         │  (1 replica) │  │ (HPA 1-5)  │  │(1 replica)│
         └──────────────┘  └────────────┘  └─────┬────┘
                                                  │
                                           ┌──────▼──────┐
                                           │ Persistent  │
                                           │   Volume    │
                                           │   (1 Gi)    │
                                           └─────────────┘
```

### Componentes de Kubernetes Implementados

- **Namespace**: `microservices-ns` - Aislamiento de recursos
- **ConfigMaps**: Configuración de URLs de servicios
- **Secrets**: Claves JWT codificadas en Base64
- **Deployments**: Gestión del ciclo de vida de pods
- **Services (ClusterIP)**: Descubrimiento de servicios interno
- **Ingress**: Enrutamiento HTTP externo
- **PersistentVolumeClaim**: Almacenamiento persistente (1Gi)
- **HorizontalPodAutoscaler**: Autoescalado basado en CPU (75%)
- **NetworkPolicies**: Seguridad de red (deny-all + allow específicos)

## 🚀 Inicio Rápido con GitHub Codespaces

La forma más rápida de probar este proyecto es usando GitHub Codespaces, que proporciona un entorno completo preconfigurado.

### Paso 1: Crear un Codespace

1. Ve al repositorio en GitHub
2. Haz clic en **Code** → **Codespaces** → **Create codespace on master**
3. Espera 2-3 minutos mientras se configura el entorno

El Codespace incluye automáticamente:

- Docker-in-Docker
- kubectl
- Helm
- Extensiones de VS Code para Kubernetes

### Paso 2: Configurar Kubernetes (kind)

Ejecuta el script de configuración que instalará un clúster Kubernetes local usando **kind**:

```bash
cd microservice-k8s-migration/scripts
bash setup-codespaces.sh
```

Este script realiza las siguientes acciones:

- Instala `kubectl` (si no está disponible)
- Instala `kind` (Kubernetes in Docker)
- Instala `Helm` v3
- Crea un clúster llamado `microservices-cluster`
- Instala NGINX Ingress Controller
- Configura port mappings para acceso externo

⏱️ **Tiempo estimado**: 3-5 minutos

### Paso 3: Desplegar la Aplicación

```bash
bash deploy-app.sh
```

Este script ejecuta:

1. Aplica el namespace
2. Crea ConfigMaps y Secrets
3. Crea PersistentVolumeClaim
4. Despliega los 3 microservicios con sus Services
5. Configura el Ingress
6. Habilita HPA para el servicio de usuarios
7. Aplica NetworkPolicies de seguridad
8. Muestra el estado final de todos los recursos

### Paso 4: Acceder a la Aplicación

En GitHub Codespaces:

1. Ve al panel de **PUERTOS** (parte inferior de VS Code)
2. Busca el puerto **80** (Ingress HTTP)
3. Haz clic en el icono del globo 🌐 para abrir la URL pública
4. ¡La aplicación está lista para usar!

**Usuarios de prueba**:

| Username | Password |
|----------|----------|
| admin    | admin    |
| johnd    | foo      |
| janed    | ddd      |

### Paso 5: (Opcional) Desplegar Monitoreo

Para habilitar Prometheus y Grafana:

```bash
bash deploy-monitoring.sh
```

**Acceder a Grafana**:

```bash
# Port forward a Grafana
kubectl port-forward -n monitoring svc/prometheus-grafana 8080:80

# Obtener contraseña de admin
kubectl get secret -n monitoring prometheus-grafana -o jsonpath='{.data.admin-password}' | base64 --decode
```

- Usuario: `admin`
- Abre el puerto **8080** desde el panel de PUERTOS

### Paso 6: Limpiar Recursos

Cuando termines de probar:

```bash
bash cleanup.sh
```

Este comando elimina:

- Todos los recursos de la aplicación
- El release de Helm de Prometheus
- Los namespaces `microservices-ns` y `monitoring`

## 💻 Desarrollo Local (sin Codespaces)

### Prerrequisitos

- Docker Desktop con Kubernetes habilitado
- kubectl instalado
- Helm 3 instalado
- Mínimo 6GB RAM y 4 CPUs asignados a Docker Desktop

### Configuración de Docker Desktop

1. **Activar Kubernetes**:
   - Settings → Kubernetes → Enable Kubernetes
2. **Aumentar Recursos**:
   - Settings → Resources
   - CPUs: Mínimo 4 (Recomendado 6+)
   - Memoria: Mínimo 6GB (Recomendado 8GB+)

### Despliegue Local

```bash
# Clonar el repositorio
git clone https://github.com/AlexisJ16/microservice-app-example.git
cd microservice-app-example

# Navegar al directorio de Kubernetes
cd microservice-k8s-migration/scripts

# Desplegar la aplicación
./deploy-app.sh

# Verificar el despliegue
kubectl get all -n microservices-ns

# Obtener la URL del Ingress
kubectl get ingress -n microservices-ns
```

## 📁 Estructura del Repositorio

```text
microservice-app-example/
├── .devcontainer/
│   └── devcontainer.json          # Configuración de Codespaces
├── auth-api/                      # Servicio de autenticación (Go)
│   ├── main.go
│   ├── user.go
│   └── README.md
├── users-api/                     # Servicio de usuarios (Java)
│   ├── src/
│   ├── pom.xml
│   └── README.md
├── todos-api/                     # Servicio de TODOs (Node.js)
│   ├── server.js
│   ├── package.json
│   └── README.md
├── frontend/                      # Frontend Vue.js
│   ├── src/
│   ├── package.json
│   └── README.md
├── log-message-processor/         # Procesador de logs (Python)
│   ├── main.py
│   └── requirements.txt
├── microservice-k8s-migration/    # ★ Manifiestos de Kubernetes
│   ├── k8s/
│   │   ├── 00-namespace.yaml
│   │   ├── 01-app-configmap.yaml
│   │   ├── 02-app-secret.yaml
│   │   ├── 03-posts-pvc.yaml
│   │   ├── 04-users-deployment.yaml
│   │   ├── 05-posts-deployment.yaml
│   │   ├── 06-client-deployment.yaml
│   │   ├── 07-ingress.yaml
│   │   ├── 08-hpa.yaml
│   │   └── networking/
│   │       ├── 01-default-deny.yaml
│   │       └── 02-allow-traffic.yaml
│   └── scripts/
│       ├── setup-codespaces.sh    # Configuración automática para Codespaces
│       ├── deploy-app.sh          # Despliegue de la aplicación
│       ├── deploy-monitoring.sh   # Despliegue de Prometheus/Grafana
│       └── cleanup.sh             # Limpieza de recursos
├── LICENSE
└── README.md                      # Este archivo
```

## 🔧 Comandos Útiles de Kubernetes

### Inspección de Recursos

```bash
# Ver todos los recursos en el namespace
kubectl get all -n microservices-ns

# Ver el estado de los pods
kubectl get pods -n microservices-ns

# Ver logs de un pod específico
kubectl logs -n microservices-ns <nombre-del-pod>

# Describir un pod (para troubleshooting)
kubectl describe pod -n microservices-ns <nombre-del-pod>

# Ver el estado del HPA
kubectl get hpa -n microservices-ns

# Ver el Ingress y su dirección
kubectl get ingress -n microservices-ns
```

### Port Forwarding (para acceso directo)

```bash
# Acceder directamente al frontend
kubectl port-forward -n microservices-ns svc/client-service 3000:3000

# Acceder al servicio de usuarios
kubectl port-forward -n microservices-ns svc/users-service 5001:5001

# Acceder a Grafana
kubectl port-forward -n monitoring svc/prometheus-grafana 8080:80
```

### Escalado Manual

```bash
# Escalar el deployment de usuarios
kubectl scale deployment users-deployment -n microservices-ns --replicas=3

# Ver el estado del escalado
kubectl get pods -n microservices-ns -l app=users
```

## 🛡️ Seguridad Implementada

### NetworkPolicies

El proyecto implementa un modelo de **"Zero Trust"**:

1. **Default Deny**: Bloquea todo el tráfico Ingress y Egress por defecto
2. **Allow Specific**: Permite solo las comunicaciones necesarias:
   - Ingress Controller → Servicios
   - Client → Users/Posts
   - Todos los pods → DNS (kube-dns)

### Secrets Management

- JWT keys almacenadas en Kubernetes Secrets
- Valores codificados en Base64
- Inyectados como variables de entorno en los pods

### Best Practices

- Namespaces para aislamiento
- Resource limits y requests definidos
- ReadinessProbe y LivenessProbe (donde aplicable)
- ImagePullPolicy configurado correctamente

## 📊 Monitoreo y Observabilidad

### Stack de Prometheus

Incluye:

- **Prometheus**: Recolección y almacenamiento de métricas
- **Grafana**: Visualización con dashboards predefinidos
- **AlertManager**: Gestión de alertas
- **Node Exporter**: Métricas del nodo
- **Kube State Metrics**: Métricas del estado de Kubernetes

### Dashboards Disponibles

Grafana incluye dashboards preconstruidos para:

- Kubernetes Cluster Monitoring
- Node Exporter Full
- Kubernetes Deployments
- Kubernetes Pods

## 🐛 Solución de Problemas

### Los pods no inician

```bash
# Ver el estado detallado
kubectl describe pod -n microservices-ns <nombre-del-pod>

# Ver logs
kubectl logs -n microservices-ns <nombre-del-pod>

# Verificar eventos
kubectl get events -n microservices-ns --sort-by='.lastTimestamp'
```

### El Ingress no funciona

```bash
# Verificar el Ingress Controller
kubectl get pods -n ingress-nginx

# Ver logs del Ingress Controller
kubectl logs -n ingress-nginx <nombre-del-pod-ingress>

# Verificar la configuración del Ingress
kubectl describe ingress -n microservices-ns
```

### HPA muestra `<unknown>` en la métrica

Esto es normal durante los primeros 1-2 minutos. El `metrics-server` necesita tiempo para recolectar datos.

```bash
# Verificar el metrics-server (en kind ya está incluido)
kubectl get deployment metrics-server -n kube-system
```

### Reiniciar todo

```bash
bash cleanup.sh
kind delete cluster --name microservices-cluster  # Solo en Codespaces
bash setup-codespaces.sh  # Solo en Codespaces
bash deploy-app.sh
```

## 📚 Recursos y Referencias

### Documentación Oficial

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [kind (Kubernetes in Docker)](https://kind.sigs.k8s.io/)
- [Helm Documentation](https://helm.sh/docs/)
- [Prometheus Operator](https://prometheus-operator.dev/)
- [GitHub Codespaces](https://docs.github.com/en/codespaces)

### Conceptos Clave

- [Network Policies](https://kubernetes.io/docs/concepts/services-networking/network-policies/)
- [ConfigMaps](https://kubernetes.io/es/docs/concepts/configuration/configmap/)
- [Secrets](https://kubernetes.io/docs/concepts/configuration/secret/)
- [Persistent Volumes](https://kubernetes.io/es/docs/concepts/storage/persistent-volumes/)
- [Horizontal Pod Autoscaler](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/)
- [Deployments](https://kubernetes.io/es/docs/concepts/workloads/controllers/deployment/)
- [Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/)

## 🤝 Contribuciones

Las contribuciones son bienvenidas. Por favor:

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo [LICENSE](LICENSE) para más detalles.

## 👥 Autores

- **Proyecto Original**: [bortizf](https://github.com/bortizf)
- **Migración a Kubernetes**: AlexisJ16

## 🙏 Agradecimientos

- Comunidad de Kubernetes
- Prometheus Community
- GitHub Codespaces Team
- Todos los contribuidores de las tecnologías utilizadas

---

**⭐ Si este proyecto te fue útil, considera darle una estrella en GitHub!**
