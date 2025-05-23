#' Descarga fuente version raw
#'
#' @param id_fuente numeric id numerico de la fuente tal cual aparece en la sheet de fuentes. Ver `fuentes_raw()`
#' @param dir string directorio donde se descarga la fuente
#' @param limpiar_cache  Logical Si es TRUE borra el cache de consultas al drive de argendata. Si es FALSE reutiliza el cache existente.
#'
#' @return file la fuente seleccionada de Fuentes/raw descargada en el directorio especificado
#' @export
#'

descargar_fuente_raw <- function(id_fuente, dir = NULL, limpiar_cache = F) {


  if (is.null(dir)) {
    dir <- tempdir()
  }

  dir <- gsub("/$", "", dir)

  stopifnot("dir debe ser string de un directorio existente" = dir.exists(dir))

  df_fuentes <- fuentes_raw()

  stopifnot("'id_fuente' debe ser numeric con id_fuente o character con codigo de fuente" = is.character(id_fuente) | is.numeric(id_fuente))

  if (is.numeric(id_fuente)) {

    stopifnot("'id_fuente' no coincide con ningun 'id_fuente' en sheet fuentes_raw" = id_fuente %in% df_fuentes$id_fuente)

    codigo <- sprintf("R%dC0", id_fuente)

  } else if (is.character(id_fuente)) {

    stopifnot("'id_fuente' no coincide con ningun 'codigo' en sheet de fuentes. Ver `fuentes_raw()`." = id_fuente %in% df_fuentes$codigo )

    codigo <- id_fuente

  }


  path_raw <- df_fuentes[df_fuentes$codigo == codigo,][[ "path_raw"]]

  path_raw_body <- gsub("\\.[^\\.]*$", "", path_raw)

  ext <- regmatches(path_raw, m = regexpr("\\.[^\\.]*$", text = path_raw, perl = T))


  ext <- gsub("^.*\\.","",path_raw)

  download.file(url = glue::glue("{IP_FUENTES()}/raw/{path_raw}"),
                destfile = glue::glue("{dir}/{path_raw_body}_{codigo}{ext}"),
                mode = "wb")

  }
