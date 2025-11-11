# **Microservice Kubernetes Migration**

## **Quick Start - Automated Deployment**

This repository includes automated scripts for rapid deployment and cleanup of the microservices application on Kubernetes.

### **Prerequisites**
- Docker Desktop with Kubernetes enabled (recommended 6+ CPUs, 8+ GB RAM)
- kubectl configured to communicate with your cluster
- Helm 3.x (for monitoring stack)

### **Deployment Scripts**

#### **1. Deploy the Application**
```bash
./scripts/deploy-app.sh
```
This script will:
- Build Docker images for all microservices (users, posts, client)
- Create the `microservices-ns` namespace
- Apply all Kubernetes manifests (ConfigMaps, Secrets, Deployments, Services, Ingress, HPA)
- Configure network policies
- Display the final cluster status

#### **2. Deploy Monitoring Stack (Optional)**
```bash
./scripts/deploy-monitoring.sh
```
This script will:
- Add the Prometheus Helm repository
- Install kube-prometheus-stack (Prometheus + Grafana)
- Provide access instructions for Grafana and Prometheus

#### **3. Cleanup Everything**
```bash
./scripts/cleanup.sh
```
This script will:
- Remove all application resources
- Uninstall the monitoring stack
- Delete the `microservices-ns` and `monitoring` namespaces

### **Accessing the Application**

After deployment, access your services:

**Via Ingress:**
```bash
kubectl get ingress -n microservices-ns
# Access the application at the Ingress IP
```

**Via Port Forward:**
```bash
# Client service
kubectl port-forward svc/client-service 3000:3000 -n microservices-ns

# Users service
kubectl port-forward svc/users-service 5001:5001 -n microservices-ns

# Posts service
kubectl port-forward svc/posts-service 5002:5002 -n microservices-ns
```

**Accessing Monitoring:**
```bash
# Get Grafana password
kubectl get secret prometheus-grafana -n monitoring -o jsonpath="{.data.admin-password}" | base64 --decode && echo

# Port-forward Grafana
kubectl port-forward svc/prometheus-grafana 8080:80 -n monitoring
# Open http://localhost:8080 (username: admin)
```

---

## **Guía de Migración de Microservicios a un Ecosistema Kubernetes Avanzado**

### **Resumen Ejecutivo (Executive Summary)**

Este documento técnico sirve como una guía completa para la migración de una aplicación de microservicios contenerizada a un clúster de Kubernetes gestionado localmente. El objetivo es ir más allá de un despliegue básico, implementando un conjunto de patrones y herramientas estándar de la industria que garantizan seguridad, escalabilidad, configurabilidad y observabilidad.

Se abordará la implementación de **Políticas de Red**, gestión de configuración con **ConfigMaps y Secrets**, persistencia de datos con **Volúmenes Persistentes**, enrutamiento de tráfico con **Ingress**, estrategias de despliegue avanzadas, autoescalado con **HPA** y un stack de monitoreo completo con **Prometheus y Grafana**.

Todo el proceso está encapsulado en scripts de automatización para una ejecución rápida, fiable y repetible, alineándose con las mejores prácticas de DevOps e Infraestructura como Código (IaC).

### **0. Preparación del Entorno Local: Docker Desktop**

Para este laboratorio, se ha elegido **Docker Desktop** como la plataforma de ejecución. Es la opción más rápida y eficiente para un entorno de desarrollo local por las siguientes razones:
*   **Kubernetes Integrado:** Proporciona un clúster de Kubernetes de un solo nodo que se puede activar con un solo clic.
*   **Ingress Controller Pre-configurado:** Incluye un Ingress Controller listo para usar, eliminando la necesidad de instalar uno manualmente.
*   **StorageClass por Defecto:** Viene con una `StorageClass` predeterminada (`docker-desktop`) que provisiona dinámicamente el almacenamiento para los Volúmenes Persistentes.

#### **Pasos de Configuración (Acción Requerida)**

1.  **Instalar Docker Desktop:** Asegúrate de tener la última versión instalada y funcionando.
2.  **Activar Kubernetes:** Ve a `Settings` > `Kubernetes` y marca la casilla `Enable Kubernetes`. Docker Desktop descargará las imágenes necesarias y arrancará el clúster.
3.  **Aumentar Recursos:** En `Settings` > `Resources`, asigna recursos suficientes a Docker Desktop, ya que el stack de monitoreo consume una cantidad considerable.
    *   **CPUs:** Mínimo 4 (Recomendado: 6+)
    *   **Memoria:** Mínimo 6 GB (Recomendado: 8+ GB)
4.  **Verificar el Entorno:** Abre una terminal y confirma que `kubectl` puede comunicarse con el clúster.
    ```bash
    kubectl cluster-info
    kubectl get nodes
    # Deberías ver un solo nodo llamado 'docker-desktop' en estado 'Ready'.
    ```

### **1. Estrategia de Migración y Arquitectura en Kubernetes**

La aplicación consta de tres microservicios principales (`users`, `posts`, `client`) y un reverse proxy. La arquitectura objetivo en Kubernetes será la siguiente:

1.  **Contenerización:** Se utilizarán los Dockerfiles existentes en el repositorio para construir las imágenes de los microservicios.
2.  **Despliegue (`Deployment`):** Cada microservicio se desplegará como un `Deployment` de Kubernetes, lo que nos permite gestionar su ciclo de vida, réplicas y estrategias de actualización.
3.  **Servicio Interno (`Service`):** Cada `Deployment` estará expuesto internamente en el clúster mediante un `Service` de tipo `ClusterIP`. Esto proporciona un punto de acceso estable para la comunicación entre servicios.
4.  **Configuración Externa (`ConfigMap` y `Secret`):** Las configuraciones (puertos, variables de entorno) y los secretos (claves de API, JWT) se externalizarán en `ConfigMaps` y `Secrets`, respectivamente.
5.  **Persistencia de Datos (`PVC` y `PV`):** El servicio `posts` utilizará una `PersistentVolumeClaim` (PVC) para solicitar almacenamiento, que será montado en su pod para que los datos persistan ante reinicios.
6.  **Acceso Externo (`Ingress`):** Un único `Ingress` gestionará todo el tráfico entrante, enrutando las peticiones a los servicios correctos basándose en la ruta (`/users`, `/posts`, `/`).
7.  **Seguridad (`NetworkPolicy`):** Se establecerán políticas de red estrictas para controlar el flujo de tráfico entre los pods, aplicando un modelo de "confianza cero".
8.  **Autoescalado (`HPA`):** El servicio `users` se configurará con un `HorizontalPodAutoscaler` (HPA) que aumentará o disminuirá el número de réplicas en función de la carga de la CPU.
9.  **Monitoreo:** Prometheus se configurará para recolectar métricas del clúster y las aplicaciones, y Grafana se utilizará para visualizar estas métricas en dashboards interactivos.

### **2. Implementación Paso a Paso**

Esta sección detalla los comandos y manifiestos para cada etapa. Todo este proceso será automatizado por los scripts proporcionados en la sección 3.

#### **2.1. Creación de Imágenes Docker y Namespace**

Primero, es necesario construir las imágenes Docker de los microservicios para que Kubernetes pueda utilizarlas. Luego, se creará un `Namespace` para aislar todos nuestros recursos.

```bash
# Navega al repositorio clonado
# cd microservice-app-example

# Construir las imágenes (repetir para posts y client)
docker build -t alexisj16/users-service:latest ./users-service
docker build -t alexisj16/posts-service:latest ./posts-service
docker build -t alexisj16/client:latest ./client

# Crear el Namespace en Kubernetes
kubectl create namespace microservices-ns
```

#### **2.2. Implementación de ConfigMaps y Secrets**

*   **Teoría:**
    *   **ConfigMap:** Almacena datos de configuración no sensibles como pares clave-valor. Permite desacoplar la configuración de la imagen del contenedor.
    *   **Secret:** Diseñado para almacenar datos sensibles como contraseñas, tokens o claves. Los datos se almacenan codificados en Base64 (nota: no es encriptación, es codificación), y ofrecen mecanismos de control más estrictos.

*   **Comandos de creación:**
    ```bash
    # Crear un ConfigMap para la configuración de la aplicación
    kubectl create configmap app-config -n microservices-ns \
      --from-literal=USERS_SERVICE_URL=http://users-service:5001 \
      --from-literal=POSTS_SERVICE_URL=http://posts-service:5002

    # Crear un Secret para datos sensibles (ej. una clave JWT)
    kubectl create secret generic app-secret -n microservices-ns \
      --from-literal=JWT_KEY='unaclavesupersecreta123'
    ```

#### **2.3. Persistencia de Datos con PVC y PV**

*   **Teoría:**
    *   **PersistentVolume (PV):** Es una pieza de almacenamiento en el clúster provisionada por un administrador. Es un recurso del clúster como un nodo.
    *   **PersistentVolumeClaim (PVC):** Es una solicitud de almacenamiento por parte de un usuario. Es similar a cómo un Pod consume recursos de CPU/Memoria de un nodo. Kubernetes buscará un PV que satisfaga los requisitos de la PVC y los "vinculará" (bind).
    *   En Docker Desktop, la `StorageClass` por defecto provisionará dinámicamente un PV cuando se cree una PVC.

*   **Manifiesto de Ejemplo (`posts-pvc.yaml`):**
    ```yaml
    apiVersion: v1
    kind: PersistentVolumeClaim
    metadata:
      name: posts-data-pvc
      namespace: microservices-ns
    spec:
      accessModes:
        - ReadWriteOnce # Puede ser montado como lectura-escritura por un único nodo
      resources:
        requests:
          storage: 1Gi # Solicitar 1 Gibibyte de almacenamiento
    ```*   **Comando de aplicación:**
    ```bash
    kubectl apply -f posts-pvc.yaml
    ```

#### **2.4. Despliegues y Servicios (Deployments & Services)**

Cada microservicio necesitará un `Deployment` y un `Service`.

*   **Teoría (Deployment):** Un `Deployment` describe el estado deseado de una aplicación. El controlador del Deployment cambia el estado actual al estado deseado de forma controlada. Se utilizará la estrategia por defecto **Rolling Update**, que garantiza cero tiempo de inactividad al actualizar las aplicaciones reemplazando gradualmente los pods antiguos por los nuevos.
*   **Manifiesto de Ejemplo (`users-deployment.yaml`):**
    ```yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: users-deployment
      namespace: microservices-ns
    spec:
      replicas: 1
      selector:
        matchLabels:
          app: users-service
      template:
        metadata:
          labels:
            app: users-service
        spec:
          containers:
          - name: users-service
            image: alexisj16/users-service:latest
            imagePullPolicy: IfNotPresent # O 'Never' si las imágenes solo son locales
            ports:
            - containerPort: 5001
            envFrom: # Cargar variables desde ConfigMaps y Secrets
            - configMapRef:
                name: app-config
            - secretRef:
                name: app-secret
            resources: # Esencial para el HPA
              requests:
                cpu: "100m" # Solicita 0.1 de un core de CPU
              limits:
                cpu: "200m"
    ---
    apiVersion: v1
    kind: Service
    metadata:
      name: users-service
      namespace: microservices-ns
    spec:
      selector:
        app: users-service
      ports:
        - protocol: TCP
          port: 5001
          targetPort: 5001
    ```

*   **Comandos de aplicación:** Se aplicarán los manifiestos para `users`, `posts` y `client`.

#### **2.5. Habilitación de Autoescalado (HPA)**

*   **Teoría:** El `HorizontalPodAutoscaler` (HPA) ajusta automáticamente el número de pods en un `Deployment`, `ReplicaSet`, etc., basándose en la utilización observada de CPU u otras métricas personalizadas. Es un pilar fundamental de las arquitecturas elásticas y eficientes en costos.
*   **Requisito previo:** Es necesario que los pods a escalar tengan definidos los `requests` de recursos.

*   **Comando de creación (imperativo):**
    ```bash
    kubectl autoscale deployment users-deployment -n microservices-ns --cpu-percent=50 --min=1 --max=5
    ```
*   **Verificación:**
    ```bash
    kubectl get hpa -n microservices-ns -w # El '-w' es para 'watch'
    ```
    Inicialmente mostrará `<unknown>/50%` mientras el `metrics-server` recolecta los datos. Luego se estabilizará.

#### **2.6. Configuración de Ingress**

*   **Comando de aplicación:** Se aplica un único manifiesto `Ingress` que enruta el tráfico a los tres servicios.

#### **2.7. Implementación de Políticas de Red (Network Policies)**

*   **Teoría:** Las `NetworkPolicies` son como un firewall para los pods. Permiten especificar cómo un pod (o grupo de pods) puede comunicarse con otros pods y puntos de red. Por defecto, en un clúster sin políticas, todo el tráfico está permitido. La estrategia recomendada es:
    1.  Crear una política "default-deny" que bloquee todo el tráfico.
    2.  Crear políticas explícitas que permitan el tráfico necesario (ej: permitir que el Ingress Controller hable con los servicios, o que el servicio `client` hable con el de `users`).

*   **Manifiesto de Ejemplo (`default-deny.yaml`):**
    ```yaml
    apiVersion: networking.k8s.io/v1
    kind: NetworkPolicy
    metadata:
      name: default-deny-all
      namespace: microservices-ns
    spec:
      podSelector: {} # Un selector vacío selecciona todos los pods en el namespace
      policyTypes:
      - Ingress
      - Egress
    ```

*   **Comando de aplicación:** Se aplican las políticas una por una, verificando la conectividad en cada paso.

#### **2.8. Despliegue del Stack de Monitoreo**

*   **Teoría:** Se utilizará el chart de Helm `kube-prometheus-stack`, que es el estándar de la comunidad para desplegar un stack completo de monitoreo. Incluye:
    *   **Prometheus:** Para la recolección y almacenamiento de métricas.
    *   **Grafana:** Para la visualización de métricas y creación de dashboards.
    *   **Alertmanager:** Para la gestión de alertas.
    *   **Exporters:** Como el `node-exporter` (métricas de nodos) y `kube-state-metrics`.

*   **Comandos de instalación con Helm:**
    ```bash
    # Añadir el repositorio de charts de Prometheus
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm repo update

    # Crear namespace para el monitoreo
    kubectl create namespace monitoring

    # Instalar el stack
    helm install prometheus prometheus-community/kube-prometheus-stack --namespace monitoring
    ```

*   **Verificación y Acceso:**
    ```bash
    # Verificar que todos los pods de monitoreo estén corriendo
    kubectl get pods -n monitoring

    # Acceder a Grafana
    kubectl port-forward svc/prometheus-grafana 8080:80 -n monitoring
    # Abrir http://localhost:8080

    # Obtener la contraseña de admin de Grafana
    kubectl get secret prometheus-grafana -n monitoring -o jsonpath="{.data.admin-password}" | base64 --decode
    # Usuario por defecto: admin
    ```

### **3. Scripts de Automatización**

Para cumplir con el requisito de velocidad, todo el proceso se empaqueta en tres scripts.

1.  **`deploy-app.sh`**: Construye las imágenes y despliega toda la aplicación con su configuración (Deployments, Services, HPA, Policies, etc.).
2.  **`deploy-monitoring.sh`**: Despliega el stack de Prometheus y Grafana usando Helm.
3.  **`cleanup.sh`**: Elimina todos los recursos creados para dejar el clúster limpio.

### **5. Bibliografía y Referencias**
1.  Kubernetes Documentation. (s.f.). *Network Policies*. Obtenido de https://kubernetes.io/docs/concepts/services-networking/network-policies/
2.  Kubernetes Documentation. (s.f.). *ConfigMaps*. Obtenido de https://kubernetes.io/es/docs/concepts/configuration/configmap/
3.  Kubernetes Documentation. (s.f.). *Horizontal Pod Autoscale*. Obtenido de https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/
4.  Kubernetes Documentation. (s.f.). *Deployments*. Obtenido de https://kubernetes.io/es/docs/concepts/workloads/controllers/deployment/
5.  Prometheus Community. (s.f.). *Prometheus Helm Charts*. Obtenido de https://github.com/prometheus-community/helm-charts
6.  Grafana Labs. (s.f.). *Grafana Documentation*. Obtenido de https://grafana.com/docs/
7.  Kubernetes Documentation. (s.f.). *Persistent Volumes*. Obtenido de https://kubernetes.io/es/docs/concepts/storage/persistent-volumes/
8.  Kubernetes Documentation. (s.f.). *Secrets*. Obtenido de https://kubernetes.io/docs/concepts/configuration/secret/
