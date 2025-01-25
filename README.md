**Repositorio para challenge técnico de FUDO para la posición de Desarrollador de Backed Developer (Ruby) Ssr.**

## Consignas
1. Explicar en un archivo llamado fudo.md qué es lo que es Fudo, en sólo 2 o 3 párrafos, en no más de 100 palabras.
2. Explicar brevemente en un archivo llamado tcp.md qué es TCP, en español, en no más de 50 palabras.
3. Explicar brevemente en un archivo llamado http.md qué es HTTP, en español, en no más de 50 palabras.
4. Implementar una aplicación rack en Ruby, sin usar Rails, que exponga una API en json.

**La API debe exponer**:
  - Endpoint de autenticación, que reciba usuario y contraseña.
  - Endpoint para creación de productos. Este endpoint debe ser asíncrono, es decir que la respuesta a esta llamada no debe indicar que el producto ya fue creado, sino que se creará de forma asíncrona. El producto creado debe estar disponible luego de 5 segundos.
  - Endpoint para consulta de productos.
  - Además de estos endpoints, se puede tener cualquier otro endpoint adicional que facilite el comportamiento asíncrono de la creación de productos.

**Tener en cuenta**:
- Los endpoints relacionados a la creación y consulta de productos deben validar que se haya
autenticado antes.
- La respuesta de la api debe ser comprimida con gzip (siempre que el cliente lo solicite).
- La API debe estar especificada en un archivo llamado openapi.yaml que siga especificación de OpenAPI. Este archivo debe ser expuesto como un archivo estático en raíz y nunca debe ser cacheado por los clientes.
- Se debe exponer también en la raíz un archivo llamado AUTHORS, que indique tu nombre y apellido. Este archivo también debe ser estático y la respuesta debe indicar que se cachee por 24 hs.
- No hace falta tener acceso a una base de datos. La persistencia de los productos puede ser en memoria.
- Los atributos de los productos es suficiente que sean sólo id y nombr
- Opcionalmente, poder levantar el proyecto en Docker.
- Agregar en el README la forma de levantar el proyecto.
- El proyecto debe estar hosteado en GitHub/GitLab o cualquier repo git, incluyendo los archivos .md de los 3 primeros puntos.
- Para cualquier cosa no indicada en los puntos anteriores, hay libertad en la decisión.

## Directorios
- **consignas1-3**: respuestas a las 3 primeras consignas.
- **api** Aplicación pedida en la consigna 4.

## Cómo levantar la aplicación
- Es posible levantar la aplicación de forma nativa o mediante Docker.
- Todo lo especificado en esta sección deberá realizarse en el directorio **/api**/.
- Antes de levantar la aplicación, es necesario crear un archivo **.env** en **/api**, Esto puede hacerse renombrando **.env.dist**

### Nativo
**Requisitos**:
- Ruby 3.2.2
- Bundler

**pasos**:
1. Instalar las gemas requeridas ejecutando **bundle install**.
2. Levantar la aplicación ejecutando **rackup**

### Docker
**Requisitos**:
- Docker
- docker-compose

**pasos**:
1. Construir la imagen de Docker (solo si ya no se encuentra construida) y levantar la aplicación ejecutando **docker-compose up**.

**Nota**: Dado que las gemas son instaladas en un volumen dedicado, no es necesario reconstruir la imagen cada vez que se modifican estas.