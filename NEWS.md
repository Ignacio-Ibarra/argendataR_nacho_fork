# Version: 0.0.9057

Agregado:

Corregido:
- `get_output_repo()` consume body de la rpta directamente con rawtochar

# Version: 0.0.9056

Agregado:
- funcion `get_output_repo()` para leer json o csv de output de repo data

Corregido:
- funcion `descargar_output()` usa `get_output_repo()`

Eliminado:

# Version: 0.0.9055

Agregado:
- funcion `get_ids_graficos()` para scrapear ids de graficos de urls de argendata

Corregido:

Eliminado:

# Version: 0.0.9054

Agregado:

Corregido:
- get_nomenclador_geografico_front(): fix nombre de la funcion en su script

Eliminado:


# Version: 0.0.9053

Agregado:

Corregido:
- get_nomenclador_geografico_front(): utiliza geonomenclador publico 
- get_nomenclador_geografico(): utiliza geonomenclador privado 

Eliminado:

# Version: 0.0.9052

Agregado:

Corregido:

Eliminado:


# Version: 0.0.9051

Agregado:

Corregido:
- get_nomenclador_geografico(): utiliza geonomenclador publico
- write_output(): mejora mensaje de error de etiquetas

Eliminado:

# Version: 0.0.9050

Agregado:
- funcion `obtener_fila_max_tiempo()`

Corregido:

Eliminado:

# Version: 0.0.9049

Agregado:
- funcion `check_iso3()`

Corregido:
- funcion `descargar_output()`: el parametro `branch` por defecto es "main"

Eliminado:

# Version: 0.0.9048

Agregado:

Corregido:
- funcion `subir_o_actualizar()`: el path local apunta a tempdir() ahora en vez de /tmp

Eliminado:

# Version: 0.0.9047

Agregado:
- funcion `mandar_data()`

Corregido:

Eliminado:

# Version: 0.0.9046

Agregado:
- funcion `subir_archivo()`, `actualizar_archivo()`, `subir_o_actualizar()`

Corregido:

Eliminado:

# Version: 0.0.9045

Agregado:
- funcion `get_mapping()` 

Corregido:

Eliminado:

# Version: 0.0.9024

* Se agrega parametro para versión sintética de metadata para trabajo con fuentes. `metadata(subtopico = "CAMCLI", fuentes = TRUE)`
