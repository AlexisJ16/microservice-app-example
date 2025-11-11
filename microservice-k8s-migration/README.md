# Proyecto de Migración de Microservicios a Kubernetes

Este repositorio contiene los manifiestos de Kubernetes y los scripts de automatización para migrar una aplicación de microservicios a un clúster de Kubernetes. El objetivo es seguir las mejores prácticas de DevOps, utilizando una estructura modular y scripts para facilitar el despliegue, monitoreo y limpieza del entorno.

## Arquitectura

La aplicación consta de tres microservicios principales y un frontend:
- **Users Service**: Gestiona la autenticación y los datos de los usuarios.
- **Posts Service**: Gestiona la creación y visualización de posts.
- **Client**: Frontend de la aplicación (Vue.js) que consume los servicios de backend.

En Kubernetes, la arquitectura se compone de:
- **Deployments**: Para cada microservicio, gestionando los pods y las actualizaciones.
- **Services**: Para exponer los microservicios dentro del clúster (`ClusterIP`).
- **Ingress**: Para exponer la aplicación al exterior y enrutar el tráfico basado en paths.
- **ConfigMap y Secret**: Para gestionar la configuración y los datos sensibles.
- **PersistentVolumeClaim**: Para proporcionar almacenamiento persistente al servicio de posts.
- **HorizontalPodAutoscaler**: Para escalar automáticamente el servicio de usuarios según la carga.
- **NetworkPolicies**: Para securizar la comunicación entre los pods.

## Estructura del Repositorio

```
.
├── k8s/                  # Manifiestos de Kubernetes
│   ├── 00-namespace.yaml
│   ├── 01-app-configmap.yaml
│   ├── 02-app-secret.yaml
│   ├── 03-posts-pvc.yaml
│   ├── 04-users-deployment.yaml
│   ├── 05-posts-deployment.yaml
│   ├── 06-client-deployment.yaml
│   ├── 07-ingress.yaml
│   ├── 08-hpa.yaml
│   └── networking/         # Políticas de red
│       ├── 01-default-deny.yaml
│       └── 02-allow-traffic.yaml
├── scripts/              # Scripts de automatización
│   ├── deploy-app.sh
│   ├── deploy-monitoring.sh
│   └── cleanup.sh
└── README.md             # Documentación del proyecto
```

## Prerrequisitos

Antes de empezar, asegúrate de tener las siguientes herramientas instaladas y configuradas:
- **Docker**: Para construir y gestionar imágenes de contenedores.
- **kubectl**: Para interactuar con tu clúster de Kubernetes.
- **Helm**: Para gestionar paquetes de Kubernetes (en este caso, la pila de monitoreo).
- Un clúster de Kubernetes activo (ej. Minikube, Docker Desktop, o un proveedor en la nube como GKE, EKS, AKS).
- Un Ingress Controller (como NGINX) instalado en tu clúster.

## Cómo Usar los Scripts

Todos los scripts deben ejecutarse desde el directorio `scripts/`.

### 1. Desplegar la Aplicación

Este script aplica todos los manifiestos de Kubernetes para desplegar la aplicación completa.

```bash
cd scripts/
./deploy-app.sh
```

Después de la ejecución, el script mostrará el estado de todos los recursos creados. Para acceder a la aplicación, obtén la dirección IP de tu Ingress y ábrela en un navegador.

```bash
kubectl get ingress -n microservices-ns
```

### 2. Desplegar la Pila de Monitoreo

Este script utiliza Helm para instalar `kube-prometheus-stack`, que incluye Prometheus para la recolección de métricas y Grafana para la visualización.

```bash
cd scripts/
./deploy-monitoring.sh
```

Al finalizar, el script te proporcionará los comandos para acceder al dashboard de Grafana y obtener la contraseña de administrador.

### 3. Limpiar el Entorno

Este script elimina todos los recursos creados por los scripts de despliegue, incluyendo la aplicación y la pila de monitoreo, devolviendo el clúster a un estado limpio.

```bash
cd scripts/
./cleanup.sh
```

## Detalles de los Manifiestos

- **`00-namespace.yaml`**: Crea un `Namespace` llamado `microservices-ns` para aislar todos los recursos de la aplicación.
- **`01-app-configmap.yaml`**: Almacena las URLs de los servicios internos, permitiendo que los componentes se descubran entre sí.
- **`02-app-secret.yaml`**: Contiene la clave secreta para firmar tokens JWT, codificada en Base64.
- **`03-posts-pvc.yaml`**: Solicita `1Gi` de almacenamiento persistente para el servicio de posts.
- **`04-users-deployment.yaml` a `06-client-deployment.yaml`**: Definen los `Deployments` y `Services` para cada microservicio, especificando imágenes, puertos, variables de entorno y recursos.
- **`07-ingress.yaml`**: Configura el enrutamiento del tráfico externo a los servicios correspondientes basado en el path de la URL.
- **`08-hpa.yaml`**: Configura el autoescalado horizontal para el `users-deployment` basado en el 75% de utilización de CPU.
- **`networking/`**: Contiene las políticas de red que implementan un modelo de "cero confianza", denegando todo el tráfico por defecto y permitiendo solo las comunicaciones necesarias explícitamente.
