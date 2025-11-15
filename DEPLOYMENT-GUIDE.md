# 🚀 Guía Rápida de Despliegue

## Scripts Disponibles

El proyecto incluye scripts organizados para facilitar el despliegue:

### 📦 Scripts Principales

| Script | Descripción | Tiempo |
|--------|-------------|--------|
| `deploy.sh` | **Script principal** - Construye y despliega todo | 12-15 min |
| `verify-environment.sh` | Verifica que el entorno esté configurado | 5 seg |
| `cleanup.sh` | Limpia todo el despliegue | 10 seg |

### 🔧 Scripts Auxiliares

| Script | Descripción |
|--------|-------------|
| `watch-pods.sh` | Monitorea el estado de los pods en tiempo real |
| `view-logs.sh` | Muestra los logs de todos los servicios |
| `access-app.sh` | Inicia port-forward para acceder a la app |

---

## 🏃 Inicio Rápido

### 1. Verificar el entorno (opcional)
```bash
chmod +x verify-environment.sh
bash verify-environment.sh
```

### 2. Desplegar la aplicación
```bash
chmod +x deploy.sh
bash deploy.sh
```

Este script hará:
- ✅ Verificar el entorno
- ✅ Limpiar recursos anteriores
- ✅ Construir 4 imágenes Docker (auth, users, posts, client)
- ✅ Cargar imágenes en kind
- ✅ Desplegar en Kubernetes

**⏱️ Tiempo total: 12-15 minutos** (principalmente por la compilación de Java)

### 3. Monitorear los pods
```bash
chmod +x watch-pods.sh
bash watch-pods.sh
```

Espera hasta que todos los pods muestren estado `Running` y `1/1` en Ready.
Presiona `Ctrl+C` cuando estén listos.

### 4. Acceder a la aplicación
```bash
chmod +x access-app.sh
bash access-app.sh
```

Abre tu navegador en: **http://localhost:8080**

---

## 📊 Comandos Útiles

### Ver estado de los recursos
```bash
kubectl get all -n microservices-ns
```

### Ver logs de un servicio específico
```bash
# Ver logs en tiempo real
kubectl logs -f -n microservices-ns -l app=auth

# Ver últimas 50 líneas
kubectl logs -n microservices-ns -l app=users --tail=50
```

### Describir un pod con problemas
```bash
kubectl describe pod -n microservices-ns <nombre-del-pod>
```

### Ver todos los logs de una vez
```bash
chmod +x view-logs.sh
bash view-logs.sh
```

---

## 🧹 Limpieza

Para eliminar todo el despliegue:
```bash
chmod +x cleanup.sh
bash cleanup.sh
```

---

## 🏗️ Arquitectura Desplegada

```
┌─────────────────────────────────────────┐
│      Ingress Controller (puerto 80)     │
└────────────┬────────────────────────────┘
             │
    ┌────────┼────────┬─────────┐
    │        │        │         │
┌───▼───┐ ┌─▼──┐ ┌───▼───┐ ┌──▼───┐
│Client │ │Auth│ │ Users │ │Posts │
│:8080  │ │:8000│ │:8083 │ │:8082 │
└───────┘ └────┘ └───────┘ └──┬───┘
                               │
                          ┌────▼────┐
                          │   PVC   │
                          │  (1GB)  │
                          └─────────┘
```

### Servicios desplegados:
- **auth-service**: Autenticación JWT (Go)
- **users-service**: Gestión de usuarios (Java/Spring Boot)
- **posts-service**: CRUD de posts (Node.js)
- **client**: Frontend web (Vue.js)

---

## ❗ Troubleshooting

### Los pods no inician
```bash
# Ver detalles del pod
kubectl describe pod -n microservices-ns <nombre-pod>

# Ver logs
kubectl logs -n microservices-ns <nombre-pod>
```

### Error al construir imágenes
Los logs de construcción se guardan en:
- `/tmp/build-auth.log`
- `/tmp/build-posts.log`
- `/tmp/build-client.log`

### Reiniciar un servicio específico
```bash
kubectl rollout restart deployment/<nombre-deployment> -n microservices-ns
```

### Limpiar y volver a desplegar
```bash
bash cleanup.sh
bash deploy.sh
```

---

## 📝 Notas Importantes

1. **Tiempo de construcción**: La imagen de `users-service` (Java/Maven) toma 8-10 minutos en compilar. Es normal.

2. **Estado de pods**: Después del despliegue, los pods pueden tardar 1-2 minutos adicionales en estar completamente listos.

3. **Port forwarding**: El comando `access-app.sh` debe mantenerse ejecutándose mientras uses la aplicación.

4. **Datos persistentes**: Los datos de posts se guardan en un PersistentVolumeClaim de 1GB.

---

## 🎯 Endpoints de la Aplicación

Una vez que la aplicación esté corriendo:

- **Frontend**: http://localhost:8080/
- **Login**: http://localhost:8080/login
- **API Users**: http://localhost:8080/users
- **API Posts**: http://localhost:8080/posts

---

¡Listo para probar! 🎉
