# Dockerfile para frontend (Vue.js)
# Build de producción con Nginx
FROM node:8-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# Servidor Nginx para producción
FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html

# Configuración de nginx para SPA
# El Ingress maneja el enrutamiento a los servicios backend,
# el frontend solo sirve los archivos estáticos
RUN echo 'server { \
	listen 8080; \
	server_name localhost; \
	root /usr/share/nginx/html; \
	index index.html; \
	location / { \
		try_files $uri $uri/ /index.html; \
	} \
}' > /etc/nginx/conf.d/default.conf

EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]
