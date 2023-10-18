# Cargar las bibliotecas necesarias
library(rvest)
library(httr)
library(dplyr)

# Función para extraer datos de una página de citas
extraer_datos_citacion <- function(url) {
  pagina <- read_html(url)
  
  # Extraer datos
  titulo <- pagina %>%
    html_nodes("h3 a") %>%
    html_text() %>%
    trimws()
  autor <- pagina %>%
    html_nodes(".gs_a") %>%
    html_text() %>%
    gsub("^[^A-Za-z]*|[0-9]*$|\\(.*?\\)", "", .) %>%
    trimws()
  revista <- pagina %>%
    html_nodes(".gs_a") %>%
    html_text() %>%
    gsub(".*?,\\s*|\\s[0-9].*", "", .) %>%
    trimws()
  año <- pagina %>%
    html_nodes(".gs_a") %>%
    html_text() %>%
    gsub(".*?,\\s*|[^0-9]*", "", .) %>%
    as.integer()
  editorial <- pagina %>%
    html_nodes(".gs_a") %>%
    html_text() %>%
    gsub(".*,|\\s[0-9].*", "", .) %>%
    trimws()
  url <- pagina %>%
    html_nodes(".gs_rt a") %>%
    html_attr("href")
  citado_por <- pagina %>%
    html_nodes(".gs_fl a") %>%
    html_text() %>%
    grep("Citado por", ., value = TRUE) %>%
    gsub("Citado por ", "", .) %>%
    as.integer()
  
  # Crear un marco de datos con los datos
  data <- data.frame(
    Título = titulo,
    Autor = autor,
    Revista = revista,
    Año = año,
    Editorial = editorial,
    URL = url,
    CitadoPor = citado_por
  )
  
  return(data)
}

# URL de la página de "citado por" (cámbiala por la URL que desees)
url_pagina_citacion <- "https://scholar.google.com/scholar?cites=5866269323493626547&as_sdt=2005&sciodt=0,5&hl=es"

# Lista para almacenar los datos de todas las páginas de citas
todos_los_datos <- list()

# Realizar scraping en múltiples páginas
while (!is.null(url_pagina_citacion)) {
  cat("Extrayendo datos de:", url_pagina_citacion, "\n")
  
  datos <- extraer_datos_citacion(url_pagina_citacion)
  todos_los_datos <- c(todos_los_datos, list(datos))
  
  enlace_pagina_siguiente <- read_html(url_pagina_citacion) %>%
    html_node(".gs_ico_nav_next") %>%
    html_attr("href")
  
  url_pagina_citacion <- ifelse(is.na(enlace_pagina_siguiente), NULL, enlace_pagina_siguiente)
}

# Combinar todos los datos en un único marco de datos
datos_finales <- do.call(rbind, todos_los_datos)

# Guardar los datos en un archivo CSV
write.csv(datos_finales, file = "web_scraping_citas.csv", row.names = FALSE)
