# Aplicación de Microservicios en Kubernetes

[![Kubernetes](https://img.shields.io/badge/Kubernetes-Enabled-326CE5?logo=kubernetes)](https://kubernetes.io/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

## 📋 Descripción del Proyecto

Este proyecto implementa una **aplicación completa de microservicios** desplegada en **Kubernetes**, demostrando las mejores prácticas de arquitectura distribuida, orquestación de contenedores, seguridad, escalabilidad y observabilidad.

La aplicación consiste en un **sistema de gestión de tareas (TODOs)** con autenticación de usuarios, construida con múltiples tecnologías y lenguajes de programación, simulando un entorno de producción real.

### 🎯 Características Principales

- **Arquitectura de Microservicios**: 4 servicios independientes (Frontend, Auth, Users, Posts)
- **Múltiples Tecnologías**: Go, Java, Node.js, Vue.js
- **Kubernetes Native**: Manifiestos completos con mejores prácticas
- **Seguridad Avanzada**: Network Policies, Secrets, JWT
- **Escalabilidad Automática**: Horizontal Pod Autoscaler (HPA)
- **Observabilidad Completa**: Prometheus + Grafana preconfigurados
- **Despliegue Automatizado**: Scripts simples y documentación completa

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

## 🚀 Guía de Instalación y Despliegue

### Prerequisitos

Asegúrate de tener instalado:

- **Docker** (v20.10+)
- **kubectl** (v1.25+)
- **kind** (v0.17+)
- **Helm** (v3.10+)

### Paso 1: Clonar el Repositorio

```bash
git clone <repository-url>
cd microservice-app-example
```

### Paso 2: Crear el Clúster Kubernetes

Si aún no tienes un clúster kind:

```bash
cd microservice-k8s-migration/scripts
chmod +x setup-codespaces.sh
./setup-codespaces.sh
cd ../..
```

Este script:
- Crea el clúster `microservices-cluster`
- Instala Ingress Controller NGINX
- Instala Prometheus + Grafana

⏱️ **Tiempo**: 3-5 minutos

### Paso 3: Desplegar la Aplicación

```bash
chmod +x scripts/*.sh
./scripts/deploy.sh
```

⏱️ **Tiempo**: 2-3 minutos

### Paso 4: Verificar el Despliegue

```bash
./scripts/status.sh
```

Deberías ver todos los pods en estado `Running`.

---

## 🌐 Acceso a la Aplicación

### Importante: Uso de Port-Forward

**Cada port-forward requiere una terminal separada que debe mantenerse abierta.**

### Terminal 1: Acceso al Frontend

```bash
./scripts/port-forward.sh
```

Abre tu navegador en: **http://localhost:8080**

#### Credenciales de Acceso

| Usuario | Contraseña | Rol |
|---------|-----------|-----|
| `admin` | `admin` | Administrador |
| `johnd` | `foo` | Usuario |
| `janed` | `ddd` | Usuario |

**Funcionalidades**:
- ✅ Login con JWT
- ✅ Crear TODOs
- ✅ Listar TODOs
- ✅ Eliminar TODOs
- ✅ Logout

### Terminal 2: Acceso a Grafana (Opcional)

**Abre una NUEVA terminal:**

```bash
./scripts/grafana.sh
```

Accede a: **http://localhost:3000**
- Usuario: `admin`
- Contraseña: `admin123`

### Terminal 3: Acceso a Prometheus (Opcional)

**Abre otra NUEVA terminal:**

```bash
./scripts/prometheus.sh
```

Accede a: **http://localhost:9090**

---

## 🎬 Guía para Demostración en Video

Esta sección está diseñada para ayudarte a grabar un video profesional demostrando el proyecto.

### Preparación Antes de Grabar

1. **Limpia el entorno**:
   ```bash
   ./scripts/cleanup.sh
   ```

2. **Valida desde cero**:
   ```bash
   ./scripts/validate.sh
   ```

3. **Configura tu terminal**:
   - Aumenta el tamaño de fuente (16-18pt)
   - Usa tema con buen contraste
   - Maximiza la ventana del terminal

### Estructura Sugerida del Video (15-20 min)

#### Parte 1: Introducción (2 min)

**Qué mostrar:**
- Arquitectura general del proyecto
- Explicar los 4 microservicios
- Tecnologías utilizadas (Go, Java, Node.js, Vue.js)
- Mencionar características: seguridad, escalabilidad, monitoreo

**Script sugerido:**
> "Este proyecto implementa una arquitectura completa de microservicios en Kubernetes. Tenemos 4 servicios: un frontend en Vue.js, un servicio de autenticación en Go, gestión de usuarios en Java Spring Boot, y un servicio de tareas en Node.js. Además incluye NetworkPolicies para seguridad, HPA para escalabilidad automática, y monitoreo con Prometheus y Grafana."

#### Parte 2: Despliegue (3-4 min)

**Qué hacer:**

1. Mostrar el directorio del proyecto:
   ```bash
   ls -la
   ```

2. Explicar la carpeta scripts:
   ```bash
   ls -la scripts/
   ```

3. Ejecutar el despliegue:
   ```bash
   ./scripts/deploy.sh
   ```

**Mientras se ejecuta, explicar:**
- Se están construyendo 4 imágenes Docker
- Se cargan en el clúster kind
- Se aplican manifiestos de Kubernetes
- Se espera a que los pods estén ready

4. Verificar el estado:
   ```bash
   ./scripts/status.sh
   ```

**Explicar cada sección:**
- Pods (4 servicios corriendo)
- Services (ClusterIP para comunicación interna)
- Ingress (punto de entrada HTTP)
- HPA (escalado automático)
- NetworkPolicies (seguridad)
- PVC (persistencia)

#### Parte 3: Demostración de la Aplicación (5-6 min)

**Paso 1: Abrir port-forward (Terminal 1)**

```bash
./scripts/port-forward.sh
```

**Explicar:**
> "Es fundamental abrir una nueva terminal para cada port-forward y mantenerla abierta. Este comando crea un túnel entre nuestro localhost:8080 y el Ingress Controller dentro del clúster Kubernetes. Sin este túnel activo, no podríamos acceder a la aplicación."

**Paso 2: Abrir navegador**

- Acceder a `http://localhost:8080`
- Mostrar la pantalla de login

**Paso 3: Login**

- Usuario: `admin`
- Contraseña: `admin`

**Explicar el flujo:**
> "Al hacer login, el navegador envía las credenciales al Ingress, este las enruta al servicio de autenticación desarrollado en Go, que valida las credenciales consultando el servicio de usuarios en Java, y finalmente retorna un token JWT que se almacena en el navegador."

**Paso 4: Crear TODOs**

- Crear 2-3 tareas de ejemplo
- Mostrar el contador actualizándose

**Explicar:**
> "Las peticiones al crear un TODO pasan por: Navegador → Ingress (ruta /todos) → Posts Service (Node.js) → Redis → PVC para persistencia."

**Paso 5: Eliminar un TODO**

- Eliminar una tarea
- Mostrar que se actualiza la lista

**Paso 6: Demostrar persistencia**

En otra terminal:
```bash
kubectl delete pod -n microservices-ns -l app=posts
kubectl get pods -n microservices-ns -w
```

**Explicar:**
> "Voy a eliminar el pod de posts para simular un fallo. Kubernetes lo recreará automáticamente gracias al Deployment."

- Esperar a que el nuevo pod esté Running
- Recargar la página del navegador
- Mostrar que los TODOs persisten

**Explicar:**
> "Gracias al PersistentVolumeClaim, los datos sobreviven al ciclo de vida de los pods."

#### Parte 4: Monitoreo (4-5 min)

**Paso 1: Abrir Grafana (Terminal 2 NUEVA)**

**Explicar:**
> "Ahora voy a abrir una segunda terminal nueva para no cerrar el port-forward de la aplicación. Cada servicio que queramos acceder desde fuera del clúster necesita su propio port-forward en una terminal separada."

```bash
./scripts/grafana.sh
```

**Paso 2: Acceder a Grafana**

- Abrir `http://localhost:3000`
- Login: admin / admin123
- Navegar a Dashboards → Browse
- Abrir "Kubernetes / Compute Resources / Namespace (Pods)"
- Filtrar por namespace: `microservices-ns`

**Mostrar:**
- CPU usage por pod
- Memoria usage por pod
- Network I/O

**Paso 3: Prometheus (Terminal 3 NUEVA - Opcional)**

```bash
./scripts/prometheus.sh
```

- Abrir `http://localhost:9090`
- Ejecutar queries:

```promql
# CPU por pod
sum(rate(container_cpu_usage_seconds_total{namespace="microservices-ns"}[5m])) by (pod)

# Memoria por pod
container_memory_usage_bytes{namespace="microservices-ns"}
```

#### Parte 5: Seguridad y Escalabilidad (3-4 min)

**Network Policies:**

```bash
kubectl get networkpolicies -n microservices-ns
kubectl describe networkpolicy default-deny-all -n microservices-ns
```

**Explicar:**
> "Implementamos un modelo de seguridad Zero Trust. Por defecto, todo el tráfico está denegado, y luego definimos reglas específicas para permitir solo las comunicaciones necesarias entre servicios."

**Horizontal Pod Autoscaler:**

```bash
kubectl get hpa -n microservices-ns
kubectl describe hpa users-hpa -n microservices-ns
```

**Explicar:**
> "El HPA monitorea el uso de CPU del users-service. Cuando supera el 70%, automáticamente escala de 2 a 5 réplicas. Cuando baja, reduce las réplicas para optimizar recursos."

**Ver logs en tiempo real:**

```bash
./scripts/view-logs.sh
```

**Monitoreo de pods:**

```bash
./scripts/watch-pods.sh
```

(Presionar Ctrl+C para salir)

#### Parte 6: Cierre (1-2 min)

**Resumen de lo demostrado:**

✅ Despliegue automatizado con un solo comando  
✅ 4 microservicios funcionando (Go, Java, Node.js, Vue.js)  
✅ Autenticación JWT funcionando  
✅ Persistencia de datos verificada  
✅ Monitoreo con Prometheus y Grafana  
✅ Network Policies para seguridad  
✅ HPA para escalado automático  

**Mostrar estructura del proyecto:**

```bash
tree -L 2 -I 'node_modules|target|dist'
```

**Limpiar recursos:**

```bash
./scripts/cleanup.sh
```

**Mensaje final:**
> "Este proyecto demuestra una implementación completa de microservicios en Kubernetes siguiendo las mejores prácticas de la industria. Todo el código y documentación están disponibles en el repositorio."

### Tips para una Mejor Grabación

1. **Resolución**: Graba en 1920x1080 mínimo
2. **Fuente**: Usa fuente grande (16-18pt) y legible
3. **Tema**: Usa tema de terminal con buen contraste
4. **Pausa**: Explica ANTES de ejecutar cada comando
5. **Etiquetas**: Identifica claramente Terminal 1, 2, 3
6. **Errores**: Si algo falla, explica por qué y cómo solucionarlo
7. **Ritmo**: No te apresures, deja tiempo para que se vea cada resultado

---

## 🚀 Inicio Rápido con GitHub Codespaces (Alternativo)

Si prefieres usar GitHub Codespaces:

1. Click en **Code** → **Codespaces** → **Create codespace**
2. Espera 2-3 minutos
3. El entorno viene con Docker, kubectl, kind y helm preinstalados
4. Sigue los pasos de despliegue normales

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
git clone <repository-url>
cd microservice-app-example

# Crear el clúster kind (si aún no existe)
cd microservice-k8s-migration/scripts
chmod +x setup-codespaces.sh
./setup-codespaces.sh
cd ../..

# Desplegar la aplicación
chmod +x scripts/*.sh
./scripts/deploy.sh

# Verificar el despliegue
./scripts/status.sh
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
- **Desarrollo y Arquitectura**: Equipo de desarrollo

## 🙏 Agradecimientos

- Comunidad de Kubernetes
- Prometheus Community
- GitHub Codespaces Team
- Todos los contribuidores de las tecnologías utilizadas

---

**⭐ Si este proyecto te fue útil, considera darle una estrella en GitHub!**
