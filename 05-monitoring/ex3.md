# Ejercicio 3: Explicación de la carpeta `01-start-up-loki`

La carpeta `01-start-up-loki` contiene un entorno completo de observabilidad basado en Loki utilizando contenedores Docker.

El objetivo principal de esta configuración es:

- Generar logs automáticamente
- Recolectarlos mediante Alloy
- Almacenarlos en Loki
- Visualizarlos desde Grafana

La arquitectura está distribuida en varios servicios definidos mediante Docker Compose.

La carpeta contiene tres archivos:

```txt
alloy-local-config.yaml
docker-compose.yaml
loki-config.yaml
```

Cada uno tiene una función concreta dentro de la arquitectura.


## 1. alloy-local-config.yaml

Este archivo configura Grafana Alloy.

Alloy es un agente de observabilidad desarrollado por Grafana que permite:

- Descubrir servicios automáticamente
- Recolectar logs
- Reenviar métricas y logs a otros sistemas

En este caso Alloy se utiliza para detectar contenedores Docker y enviar sus logs a Loki.

### Descubrimiento de contenedores Docker

```hcl
discovery.docker "flog_scrape" {
	host             = "unix:///var/run/docker.sock"
	refresh_interval = "5s"
}
```

Esta sección permite que Alloy consulte el socket Docker local para detectar contenedores activos.

El refresco se realiza cada 5 segundos.

### Relabeling

```hcl
discovery.relabel "flog_scrape"
```

Aquí se transforman etiquetas obtenidas desde Docker.

Concretamente:

```hcl
source_labels = ["__meta_docker_container_name"]
```

obtiene el nombre del contenedor y lo almacena como:

```hcl
target_label = "container"
```

Esto facilita posteriormente el filtrado de logs en Grafana.

### Recolección de logs Docker

```hcl
loki.source.docker "flog_scrape"
```

Esta sección indica a Alloy que:

- Lea logs de Docker
- Utilice los contenedores descubiertos automáticamente
- Aplique reglas de relabeling
- Envíe los logs a Loki

### Envío de logs a Loki

```hcl
loki.write "default"
```

Define el endpoint de Loki:

```hcl
url = "http://gateway:3100/loki/api/v1/push"
```

Alloy enviará todos los logs recolectados al gateway de Loki.

También se define:

```hcl
tenant_id = "tenant1"
```

lo que habilita soporte multi-tenant.

## 2. docker-compose.yaml

Este archivo define toda la infraestructura del stack Loki mediante Docker Compose.

Incluye varios servicios conectados entre sí mediante la red:

```yaml
networks:
  loki:
```

### Servicios principales

#### Read

```yaml
read:
```

Instancia Loki encargada de:

- Consultas
- Lectura de logs
- Operaciones de búsqueda

Expone el puerto:

```txt
3101
```

#### Write

```yaml
write:
```

Instancia Loki dedicada a:

- Ingestión de logs
- Escritura de datos
- Almacenamiento

Expone:

```txt
3102
```

#### Backend

```yaml
backend:
```

Servicio encargado de:

- Compaction
- Coordinación interna
- Almacenamiento distribuido
- Tareas internas del clúster Loki

#### Gateway

```yaml
gateway:
```

Se implementa mediante NGINX.

Actúa como punto de entrada único para Loki.

Su función principal es distribuir tráfico:

- Peticiones de escritura --> servicio write
- Peticiones de lectura --> servicio read

Ejemplo:

```nginx
location = /loki/api/v1/push {
  proxy_pass http://write:3100$request_uri;
}
```

Esto separa lectura y escritura, arquitectura habitual en despliegues escalables.

#### Grafana

```yaml
grafana:
```

Permite visualizar logs almacenados en Loki.

Se configura automáticamente un datasource Loki mediante provisioning:

```yaml
- name: Loki
  type: loki
  url: http://gateway:3100
```

Grafana queda disponible en:

```txt
http://localhost:3000
```

#### Alloy

```yaml
alloy:
```

Ejecuta el agente configurado en `alloy-local-config.yaml`.

Monta:

```yaml
/var/run/docker.sock
```

para acceder a la API Docker y descubrir contenedores.

#### MinIO

```yaml
minio:
```

Se utiliza como almacenamiento compatible con S3.

Loki almacena:

- Índices
- Chunks
- Reglas

sobre MinIO simulando un almacenamiento cloud tipo Amazon S3.

#### Flog

```yaml
flog:
```

Contenedor utilizado para generar logs falsos continuamente.

Permite probar el pipeline completo:

```txt
Flog --> Alloy --> Loki --> Grafana
```

## 3. loki-config.yaml

Este archivo contiene la configuración principal de Loki.

### Configuración del servidor

```yaml
server:
  http_listen_port: 3100
```

Loki escucha peticiones HTTP en el puerto 3100.

### Memberlist

```yaml
memberlist:
```

Configura comunicación interna entre nodos Loki.

Permite:

- Descubrimiento de nodos
- Clustering
- Replicación
- Gossip protocol

Los nodos definidos son:

```yaml
join_members: ["read", "write", "backend"]
```

### Schema Config

```yaml
schema_config:
```

Define cómo Loki organiza y almacena los datos.

En este caso:

- Almacenamiento TSDB
- Schema v13
- Índices diarios

### Storage

```yaml
storage:
  s3:
```

Loki utiliza MinIO como backend S3.

Configuración importante:

```yaml
endpoint: minio:9000
bucketnames: loki-data
```

### Replication

```yaml
replication_factor: 1
```

Solo existe una réplica de los datos.

En producción normalmente se usarían varias réplicas.

### Compactor

```yaml
compactor:
```

Servicio encargado de:

- Compactar índices
- Optimizar almacenamiento
- Reducir fragmentación