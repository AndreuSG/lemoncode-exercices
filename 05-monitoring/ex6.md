# Ejercicio 6: Take OpenTracing for a HotROD ride

## Objetivo del ejercicio

El objetivo principal es:

- Desplegar Jaeger
- Ejecutar la aplicación HotROD
- Generar tráfico entre microservicios
- Visualizar trazas distribuidas
- Analizar spans y tiempos de respuesta

## Instalación de Jaeger

Se levanta Jaeger utilizando la imagen oficial all-in-one:

```bash
docker run -d \
  --name jaeger \
  -p 6831:6831/udp \
  -p 16686:16686 \
  jaegertracing/all-in-one:latest
```

Esto expone:

- El agente Jaeger
- El collector
- La interfaz web

La interfaz queda disponible en:

```txt
http://localhost:16686
```

## Ejecución de HotROD

Siguiendo el tutorial original, se ejecuta HotROD desde código fuente utilizando Go.

### Clonado del repositorio

```bash
git clone git@github.com:jaegertracing/jaeger.git jaeger
```

### Acceso al proyecto

```bash
cd jaeger
```

### Ejecución de HotROD

```bash
go run ./examples/hotrod/main.go all
```

### Funcionamiento de HotROD

HotROD es una aplicación de demostración que simula un sistema de reservas de vehículos.

La aplicación genera trazas distribuidas entre distintos microservicios:

```txt
frontend
customer
driver
route
```

Cada interacción del usuario genera una nueva trace distribuida.

## Generación de trazas

Se interactúa con la aplicación realizando distintas acciones:

- Solicitar rutas
- Buscar conductores
- Simular viajes
- Cambiar usuarios

Cada acción genera múltiples spans asociados a una misma trace.

## Visualización de trazas

Desde la interfaz de Jaeger se selecciona el servicio:

```txt
frontend
```

Posteriormente se utiliza:

```txt
Find Traces
```

para visualizar las trazas generadas.

## Observaciones realizadas

Las trazas permiten visualizar:

- Recorrido completo de una petición
- Relación entre microservicios
- Duración de cada operación
- Jerarquía padre-hijo entre spans
- Tiempos de respuesta

También se puede identificar qué operaciones presentan mayor latencia.

## Problemas encontrados

Durante las pruebas se observaron diferencias entre el tutorial original y las versiones modernas de Jaeger y HotROD.

Algunas configuraciones actuales utilizan OpenTelemetry (OTLP) en lugar del modelo clásico basado en Jaeger Agent.

Esto provocó problemas iniciales relacionados con la exportación de trazas y compatibilidad entre versiones.


## Aprendizajes obtenidos

El ejercicio permitió comprender:

- Funcionamiento del distributed tracing
- Relación entre traces y spans
- Propagación de contexto entre servicios
- Análisis de latencias
- Monitorización de arquitecturas distribuidas

También permitió observar cómo Jaeger facilita enormemente el troubleshooting en sistemas basados en microservicios.