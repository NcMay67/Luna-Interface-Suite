# Sitio de NC HUB

Sitio estático, adaptable a móvil y escritorio. No necesita dependencias ni proceso de compilación.

## Ver en local

Desde la raíz del repositorio, ejecuta:

```sh
python3 -m http.server 8000 --directory website
```

Abre `http://localhost:8000`. Para detener el servidor, pulsa `Ctrl+C`.

El botón **Copiar loader** utiliza la API de portapapeles en contextos HTTPS; dispone de una alternativa con `execCommand` y ofrece instrucciones manuales si el navegador no concede el acceso. En móvil, abre y cierra el menú de navegación.

## Contenido

- `index.html`: contenido, metadatos y rutas de los recursos.
- `styles.css`: tema de NC HUB y ajustes responsive.
- `app.js`: menú móvil y copia del loader oficial.
- `assets/`: portada original optimizada y favicon de la luna.
- `manus-routes.json`: declaración de rutas de página.
