# Reto 2: Dockerizar el Backend

## Crear un dockerignore para el backend:

Creamos un fichero .dockerignore en la raíz del proyecto backend para evitar copiar archivos innecesarios a la imagen Docker:

```yaml
# Node
node_modules

# Git
.git
.gitignore

# Docker
Dockerfile
.dockerignore
.devcontainer

# Documentación
README.md

# Cliente HTTP de pruebas
client.http
```

## Crear un Dockerfile para el backend:

```dockerfile
#### Stage 1: Build
FROM node:20-alpine AS build

WORKDIR /app

COPY package*.json ./

RUN npm ci

#### Stage 2: Production
FROM node:20-alpine AS production

USER node

WORKDIR /app

COPY --from=build --chown=node:node /app/node_modules ./node_modules
COPY --chown=node:node . .

ENV NODE_ENV=production

EXPOSE 5000

CMD ["npm", "start"]
```

## Comprobamos que la imagen se ha creado correctamente:

![docker-build-check](./img/docker-build-check.png) 

![docker-ls](./img/docker-ls.png)

## Ejecutar el contenedor del backend:

```bash
docker run -d \
  --name backend \
  --network lemoncode-network \
  -p 5000:5000 \
  -e DATABASE_URL="mongodb://mongo-container:27017" \
  -e DATABASE_NAME=LemoncodeCourseDb \
  lemoncode-backend:1.0
```

## Verificar que el contenedor del backend está corriendo correctamente:

![backend-docker-ps](./img/backend-docker-ps.png)

## Verificar que el backend se conecta correctamente a MongoDB con los logs del contenedor:

![backend-logs](./img/backend-logs.png)