# Guía Rápida para GitHub Codespaces

Esta guía te ayudará a ejecutar el proyecto de migración de microservicios a Kubernetes en GitHub Codespaces.

## 🚀 Inicio Rápido

### Paso 1: Crear el Codespace

1. Ve al repositorio: `https://github.com/AlexisJ16/microservice-app-example`
2. Haz clic en **Code** → **Codespaces** → **Create codespace on master**
3. Espera 2-3 minutos mientras se configura el entorno

### Paso 2: Configurar Kubernetes

```bash
cd microservice-k8s-migration/scripts
bash setup-codespaces.sh
```

⏱️ Este proceso toma aproximadamente 3-5 minutos.

### Paso 3: Desplegar la Aplicación

```bash
bash deploy-app.sh
```

### Paso 4: Acceder a la Aplicación

1. Ve al panel de **PUERTOS** en la parte inferior de VS Code
2. Busca el puerto **80** (Ingress HTTP)
3. Haz clic en el icono del globo 🌐 para abrir la URL pública
4. ¡La aplicación está lista!

## 📊 Monitoreo con Grafana

Para desplegar Prometheus y Grafana:

```bash
bash deploy-monitoring.sh
```

Acceder a Grafana:
1. Ejecuta: `kubectl port-forward -n monitoring svc/prometheus-grafana 8080:80`
2. Ve al panel de PUERTOS y abre el puerto **8080**
3. Usuario: `admin`
4. Contraseña: Ejecuta `kubectl get secret -n monitoring prometheus-grafana -o jsonpath='{.data.admin-password}' | base64 --decode`

## 🧹 Limpiar Todo

Cuando termines de probar:

```bash
bash cleanup.sh
```

## 🔍 Comandos Útiles

### Ver el estado de los pods
```bash
kubectl get pods -n microservices-ns
```

### Ver los logs de un pod
```bash
kubectl logs -n microservices-ns <nombre-del-pod>
```

### Ver todos los recursos
```bash
kubectl get all -n microservices-ns
```

### Verificar el Ingress
```bash
kubectl get ingress -n microservices-ns
```

## ⚠️ Notas Importantes

- **kind** ejecuta Kubernetes dentro de Docker, ideal para desarrollo y pruebas
- Los puertos se reenvían automáticamente en Codespaces
- El clúster se llama `microservices-cluster`
- Para eliminar el clúster: `kind delete cluster --name microservices-cluster`

## 🐛 Solución de Problemas

### El Ingress no funciona
```bash
kubectl get pods -n ingress-nginx
kubectl logs -n ingress-nginx <nombre-del-pod-ingress>
```

### Los pods no inician
```bash
kubectl describe pod -n microservices-ns <nombre-del-pod>
kubectl logs -n microservices-ns <nombre-del-pod>
```

### Reiniciar todo
```bash
bash cleanup.sh
kind delete cluster --name microservices-cluster
bash setup-codespaces.sh
bash deploy-app.sh
```

## 📚 Recursos Adicionales

- [Documentación de kind](https://kind.sigs.k8s.io/)
- [Documentación de Kubernetes](https://kubernetes.io/docs/)
- [GitHub Codespaces Docs](https://docs.github.com/en/codespaces)
