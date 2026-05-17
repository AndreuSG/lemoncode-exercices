# Ejercicio 4: Estructura de una traza en Jaeger

Jaeger es una herramienta de *distributed tracing* utilizada para monitorizar y analizar el recorrido de peticiones dentro de arquitecturas distribuidas y microservicios.

El objetivo principal de Jaeger es permitir visualizar cómo una petición atraviesa diferentes servicios, detectar cuellos de botella y facilitar el troubleshooting.

## Trace

Una *trace* representa el recorrido completo de una petición dentro de un sistema distribuido.

Cada vez que un usuario realiza una acción, por ejemplo:

```txt
Login
Compra online
Consulta API
Carga de página web
```

se genera una traza única.

La trace agrupa todos los eventos y operaciones relacionados con esa petición.

### Características principales

- Tiene un identificador único llamado `Trace ID`
- Agrupa múltiples spans
- Representa el flujo completo de una petición
- Puede involucrar varios microservicios

### Ejemplo conceptual

```txt
Usuario --> Frontend --> API Gateway --> Servicio de autenticación --> Base de datos
```

Todo este recorrido pertenecería a una única trace.

## Span

Un *span* representa una operación individual dentro de una traza.

Es la unidad básica de trabajo en Jaeger.

Cada span mide:

- Inicio
- Duración
- Operación realizada
- Servicio implicado
- Metadatos adicionales

### Características principales

- Tiene un `Span ID`
- Puede tener un span padre
- Puede contener spans hijos
- Permite medir tiempos de ejecución

### Relaciones padre-hijo

Los spans se organizan jerárquicamente.

Ejemplo:

```txt
HTTP Request
  - Auth Service
  - User Service
  - Database Query
```

Esto permite visualizar dependencias entre servicios.

## Scope

El concepto de *scope* hace referencia al contexto activo de ejecución de un span.

Cuando una operación comienza, el span asociado pasa a ser el span activo dentro del contexto de ejecución.

El scope permite:

- Mantener el contexto de tracing
- Propagar información entre servicios
- Asociar correctamente spans hijos

### Función principal

Garantizar que las operaciones ejecutadas dentro de un contexto concreto pertenezcan a la traza correcta.

## Tags

Los *tags* son pares clave-valor utilizados para añadir información adicional a spans o trazas.

Permiten enriquecer la observabilidad y facilitar búsquedas y filtrados.

### Función principal

Los tags permiten:

- Identificar errores
- Filtrar trazas
- Clasificar operaciones
- Añadir contexto técnico

### Ejemplo práctico

Un span HTTP podría contener:

```txt
operation: GET /api/users

tags:
- http.method = GET
- http.status_code = 200
- user.id = 145
```