#' Actualizar informacion de una fuente raw
#'
#' @description
#' Actualiza 'fecha_descarga' y 'fecha_actualizar' de una fuente en la sheet de fuentes en el drive de Argendata. Hace `drive_upload()` con overwrite = T pisando la version anterior de la fuente en el drive.
#'
#' @details
#' La fecha será actualizada usando `Sys.time()` al momento de su ejecución.
#'
#' @param id_fuente integer id numerico que permite seleccionar la fuente segun aparece en el sheet. Para consultar ids usar  `fuentes_raw()`
#' @param url string Link directo a la fuente si existiera o link a la página web más inmediata a la  fuente.
#' @param nombre string Nombre único que identifica a la fuente
#' @param institucion string Nombre oficial de la institucion
#' @param actualizable logical TRUE o FALSE  sobre si la fuente será actualizada y debe volver a ser descargada en nueva versión en el futuro.
#' @param fecha_descarga date o string o null Fecha de descarga como valor de clase 'date', o 'string' parseable por `as.Date()`. Si es null toma la fecha de `Sys.Date()`
#' @param fecha_actualizar date o string Fecha en que la fuente sera actualizada por la institucion que la gestiona. Poner "Sin informacion" si no hay detalle
#' @param path_raw string Nombre del archivo de la fuente tal cual fue guardado.
#' @param script string  Nombre del archivo del script de descarga de la fuente tal cual se guardó en scripts/descarga_fuentes/ de argendata-etl
#' @param api logical TRUE o FALSE indicando si la fuente es una api o no.
#' @param directorio string Ruta al directorio desde el cual cargar el archivo
#' @param prompt logical Si es TRUE (default) pide confirmacion de los cambios.
#'
#' @export
#'
#'

actualizar_fuente_raw <- function(id_fuente,
                                  url = NULL,
                                  nombre = NULL,
                                  institucion = NULL,
                                  actualizable = NULL,
                                  fecha_descarga = NULL,
                                  fecha_actualizar = NULL,
                                  path_raw = NULL,
                                  script = NULL,
                                  api = NULL,
                                  directorio = NULL,
                                  prompt = TRUE) {


  ## cotrol directorio ----

  if (is.null(directorio)) {
    directorio <- tempdir()
  } else {
    stopifnot("'directorio' debe ser string a una ruta valida" = dir.exists(directorio))
  }


  df_fuentes_raw <- fuentes_raw()

  df_fuentes_raw_copy <- df_fuentes_raw

  df_fuentes_raw_md5 <- tools::md5sum(glue::glue("{RUTA_FUENTES()}/fuentes_raw.csv"))

  ## control id fuente  ----------

  stopifnot("'id_fuente' debe ser id numerico de fuente o character con codigo de fuente" = is.numeric(id_fuente) | is.character(id_fuente))

  if (is.numeric(id_fuente)) {

    stopifnot("'id_fuente' no encontrado en sheet de fuentes. Ver `fuentes_raw()`." = id_fuente %in% df_fuentes_raw$id_fuente )

    irow <- which(df_fuentes_raw$id_fuente == id_fuente)

    stopifnot("Mas de una coincidencia de id_fuente hallada" = length(irow) == 1)



  } else if (is.character(id_fuente)) {

    stopifnot("'id_fuente' no coincide con ningun codigo en sheet de fuentes. Ver `fuentes_raw()`." = id_fuente %in% df_fuentes_raw$codigo )
    id_fuente <- regmatches(id_fuente, m = regexpr("(?<=R)(\\d+)", text = id_fuente, perl = T))

    id_fuente <- as.numeric(id_fuente)

    irow <- which(df_fuentes_raw$id_fuente == id_fuente)

    stopifnot("Mas de una coincidencia de id_fuente hallada" = length(irow) == 1)


  }

  ## fecha descarga default ----------


  if (is.null(fecha_descarga)) {
    fecha_descarga <- Sys.time()

  }

  ## control fecha actualizar ----------


  stopifnot("fecha_actualizar no puede ser NULL" = !is.null(fecha_actualizar))

  if (is.character(fecha_actualizar)) {

    if (fecha_actualizar != "Sin informacion") {
      stopifnot("param 'fecha_actualizar' debe ser fecha valida o string parseable como fecha o 'Sin informacion'" = !is.na(as.Date(fecha_actualizar)) & length(as.Date(fecha_actualizar)) == 1)
      fecha_actualizar <- as.Date(fecha_actualizar)

    } else {
      stopifnot("param 'fecha_actualizar' debe ser fecha valida o string parseable como fecha o 'Sin informacion'" = fecha_actualizar == "Sin informacion")
    } } else if (class(fecha_actualizar) %in% c("Date", "POSIXct", "POSIXt")) {

    stopifnot("param 'fecha_actualizar' debe ser fecha valida o string parseable como fecha o 'Sin informacion'" = !is.na(fecha_actualizar) & length(fecha_actualizar) == 1)

  } else {

    stopifnot("param 'fecha_actualizar' debe ser fecha o character parseable a fecha o 'Sin informacion'" = fecha_actualizar == "Sin informacion" & length(fecha_actualizar) == 1)

  }

  ## control script ----------



 if (!is.null(script)) {
    if (!file.exists(paste0("scripts/descarga_fuentes/", script)) &
        !file.exists(script)) {
      stop("No se encontro el archivo script en scripts/descarga_fuentes/. Guardarlo en la ubicacion antes de continuar")
    }
 }


  ## control url ----------

  if (!is.null(url)) {

    if(! url %in% df_fuentes_raw$url) {

      warning("La URL ingresada ya esta regsitrada en fuentes_raw()")

      print(utils::capture.output(df_fuentes_raw[df_fuentes_raw$url == url,]))

      ok <- readline("Desea continuar con la actualizacion de la URL de la fuente? Y/N \n")

      stopifnot("Actualizacion cancelada por el usuario" = tolower(ok) == "y")
    }
  }

  ## control archivos x cambio de path ----------

  cambio_path_raw <- FALSE

  if (!is.null(path_raw)) {
    cambio_path_raw <- path_raw != df_fuentes_raw[[irow, "path_raw"]]
  }

  if (isTRUE(cambio_path_raw)) {
    old_path <- df_fuentes_raw[[irow, "path_raw"]]
    print(glue::glue("Path anterior: {old_path}"))
    print(glue::glue("Path nuevo: {path_raw}"))

  }

  ## armado lista input  ---------

  inputs <- list(
    # "id_fuente" = id_fuente,
    "url" = url ,
    "nombre" = nombre ,
    "institucion" = institucion,
    "actualizable" = actualizable ,
    "fecha_descarga" = as.Date(fecha_descarga),
    "fecha_actualizar" =  fecha_actualizar ,
    "path_raw" = path_raw,
    "script" = script,
    "api" = api
  )

  inputs <- inputs[sapply(inputs, function(x) !is.null(x))]


  ## actualizacion en tabla ----

  for (i in names(inputs)) {

    inputs[[i]] <- coerce_to(inputs[[i]], df_fuentes_raw[[irow, i]])

    df_fuentes_raw[[irow, i]] <-  inputs[[i]]

  }


  ## control path raw ----------

  if (!file.exists(normalize_path(glue::glue("{directorio}/{df_fuentes_raw$path_raw[[irow]]}")))) {
    warning("No existe el archivo fuente en la ruta especificada")
    warning(normalize_path(glue::glue("{directorio}/{df_fuentes_raw$path_raw[[irow]]}")))
    stop()

  }

  ## warning cambios ----------

  log <- comparar_archivos(x = glue::glue("{RUTA_FUENTES()}/raw/{df_fuentes_raw_copy[[irow, 'path_raw']]}"),
                           y = glue::glue("{directorio}/{df_fuentes_raw[[irow, 'path_raw']]}"))

  print(log)



  if (!isFALSE(prompt) & length(inputs) > 1) {

    message("Va a sobreescribir datos de registro de la fuente.")
    print(utils::capture.output(df_fuentes_raw_copy[irow,]))
    ok <- readline(prompt = "Continuar con la actualizacion de la fuente raw? Y/N")

    stopifnot("Actualizacion cancelada." = tolower(ok) == "y")
    print(utils::capture.output(df_fuentes_raw[irow,]))

  }

  stopifnot("El registro de fuentes cambio antes de finalizar la actualizacion. Vuelva a intentarlo" = df_fuentes_raw_md5 == tools::md5sum(glue::glue("{RUTA_FUENTES()}/fuentes_raw.csv")))


  df_fuentes_raw %>%
    readr::write_csv(file = glue::glue("{RUTA_FUENTES()}/fuentes_raw.csv"), eol = "\n", progress = F)

  message("Registro actualizado en fuentes raw")



  file.copy(from = glue::glue("{RUTA_FUENTES()}/raw/{df_fuentes_raw[[irow, 'path_raw']]}"),
            to = glue::glue("{RUTA_FUENTES()}/raw/_tmp_{df_fuentes_raw[[irow, 'path_raw']]}"), overwrite = T)

  check_copy <- file.copy(from = glue::glue("{directorio}/{df_fuentes_raw[[irow, 'path_raw']]}"),
                          to = glue::glue("{RUTA_FUENTES()}/raw/{df_fuentes_raw[[irow, 'path_raw']]}"),
                          overwrite = T)

  warning(check_copy)

  if (!isTRUE(check_copy)) {

    warning("Error al copiar el archivo a carpeta /raw")

    file.remove(glue::glue("{RUTA_FUENTES()}/raw/_tmp_{df_fuentes_raw[[irow, 'path_raw']]}"))

    warning("Se restaura el registro de df_fuentes_raw previo")
    print(utils::capture.output(df_fuentes_raw_copy[irow,]))
    df_fuentes_raw_copy %>%
      readr::write_csv(file = glue::glue("{RUTA_FUENTES()}/fuentes_raw.csv"), eol = "\n", progress = F)
    stop("Actualizacion cancelada por error al copiar el archivo")

  }

  message("Fuente copiada a carpeta raw")

  ## control cambio df fuentes ----------

  file.remove(glue::glue("{RUTA_FUENTES()}/raw/_tmp_{df_fuentes_raw[[irow, 'path_raw']]}"))

  if (isTRUE(cambio_path_raw)) {

    file.remove(glue::glue("{RUTA_FUENTES()}/raw/{old_path}"))
    message(glue::glue("Copia con path anterior eliminada: {old_path}"))
  }

  jsonlite::write_json(log, path = glue::glue("{RUTA_FUENTES()}/raw/log/log_{df_fuentes_raw$codigo[irow]}_{format(Sys.time(), '%Y%m%d%z%S')}.json"))

}




