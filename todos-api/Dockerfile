# Dockerfile para todos-api (Node.js)
FROM node:14-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install --production
COPY . .
EXPOSE 8082
CMD ["node", "server.js"]
