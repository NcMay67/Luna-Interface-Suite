# NC HUB

Repositorio principal de scripts de **NC HUB**, basado en la biblioteca Luna UI.

## Loader oficial

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/NcMay67/Luna-Interface-Suite/master/main.lua"))()
```

El loader detecta el `PlaceId` actual. Cuando existe un módulo específico, lo carga; en cualquier otro juego utiliza `Universal.lua`.

## Módulos activos

| Juego | PlaceId | Archivo |
|---|---:|---|
| Factory Tycoon | `15197136141` | `FactoryTycoon.lua` |
| Cualquier otro juego | — | `Universal.lua` |

## Estructura

```text
/
├── main.lua
├── Universal.lua
├── FactoryTycoon.lua
├── source.lua
├── README.md
├── LICENSE
├── assets/
├── docs/
└── dev/
```

Los módulos listos para cargar se guardan en la raíz. Los borradores y pruebas se guardan en `dev/` y no se añaden al loader hasta que estén comprobados.

## Biblioteca

`source.lua` contiene la biblioteca Luna UI adaptada para NC HUB. Su licencia BSD-3-Clause se conserva en `LICENSE`.

## Nuevo juego

1. Crea y prueba el borrador dentro de `dev/`.
2. Cuando funcione, muévelo a la raíz con un nombre claro.
3. Añade su `PlaceId` a la tabla `Games` de `main.lua`.
