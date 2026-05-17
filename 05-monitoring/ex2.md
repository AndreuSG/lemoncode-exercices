# Ejercicio 2: Exporters, Recording Rules y Alert Rules en Prometheus

## Exporters en Prometheus

Los *exporters* son aplicaciones o servicios que exponen métricas en un formato que Prometheus puede entender.

Prometheus funciona mediante un modelo *pull*, es decir, consulta periódicamente un endpoint HTTP para obtener métricas. Muchos sistemas no exponen métricas de forma nativa, por lo que se utilizan exporters como intermediarios.

### Función principal

Traducir información de sistemas externos a métricas compatibles con Prometheus.

### Ejemplos habituales

* Node Exporter --> métricas del sistema Linux (CPU, RAM, disco, red)
* MySQL Exporter --> métricas de MySQL
* Blackbox Exporter --> monitorización de endpoints HTTP, DNS o TCP

### Ejemplo práctico

Un Node Exporter puede exponer métricas como:

```txt
node_memory_MemAvailable_bytes
node_cpu_seconds_total
```

y Prometheus las recogería mediante scraping.

## Recording Rules en Prometheus

Las *recording rules* permiten guardar el resultado de consultas PromQL como nuevas métricas.

Se utilizan principalmente para:

- optimizar consultas complejas
- reducir carga de procesamiento
- reutilizar métricas calculadas frecuentemente

## Funcionamiento

Prometheus ejecuta la consulta periódicamente y almacena el resultado como una nueva serie temporal.

## Ejemplo

```yaml
groups:
  - name: cpu_rules
    rules:
      - record: job:cpu_usage:avg
        expr: avg(rate(process_cpu_seconds_total[5m]))
```

## Resultado

Ahora se puede consultar directamente:

```promql
job:cpu_usage:avg
```

en lugar de recalcular continuamente la expresión original.

## Alert Rules en Prometheus

Las *alert rules* permiten generar alertas automáticas cuando una métrica cumple determinadas condiciones.

Son fundamentales para observabilidad y monitorización proactiva.

## Funcionamiento

Prometheus evalúa reglas periódicamente y, si la condición se mantiene durante cierto tiempo, dispara una alerta.

Normalmente las alertas se envían a:

- email
- Slack
- Microsoft Teams
- PagerDuty
- Alertmanager

## Ejemplo

```yaml
groups:
  - name: alert_rules
    rules:
      - alert: HighMemoryUsage
        expr: process_resident_memory_bytes > 200000000
        for: 1m
        labels:
          severity: warning
        annotations:
          summary: "Uso elevado de memoria"
```

## Qué hace esta alerta

Si Prometheus supera aproximadamente 200 MB de RAM durante más de 1 minuto:

```txt
HighMemoryUsage
```

pasará al estado de alerta.