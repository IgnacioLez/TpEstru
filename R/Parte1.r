# Cargar las bibliotecas necesarias
library(rvest)
library(dplyr)

# Definir la URL de Google Scholar
url <- "https://scholar.google.com/scholar?cites=5866269323493626547&as_sdt=2005&sciodt=0,5&hl=es"

# Realizar la función para extraer información
extract_info <- function(url) {
  page <- read_html(url)
  
  # Extraer información de la página actual
  articles <- page %>%
    html_nodes(".gs_ri") %>%
    lapply(function(article) {
      title <- article %>%
        html_node("h3 a") %>%
        html_text()
      author <- article %>%
        html_node(".gs_a") %>%
        html_text()
      journal <- article %>%
        html_node(".gs_a") %>%
        html_text() %>%
        str_match(".*?-(.*?)-.*?\\d{4}") %>%
        .[,2]
      year <- article %>%
        html_node(".gs_a") %>%
        html_text() %>%
        str_match("(\\d{4})") %>%
        .[,2]
      publisher <- article %>%
        html_node(".gs_a") %>%
        html_text() %>%
        str_match("-(.*?)-") %>%
        .[,2]
      url <- article %>%
        html_node("h3 a") %>%
        html_attr("href")
      cited_by <- article %>%
        html_node(".gs_fl a") %>%
        html_text() %>%
        str_match("\\d+") %>%
        .[,1]
      
      data.frame(
        Title = title,
        Author = author,
        Journal = journal,
        Year = year,
        Publisher = publisher,
        URL = url,
        Cited_By = cited_by
      )
    })
  
  return(articles)
}

# Realizar el web scraping y almacenar los datos en un DataFrame
data <- data.frame()
current_url <- url

while (TRUE) {
  articles <- extract_info(current_url)
  data <- rbind(data, do.call(rbind, articles))
  
  next_page <- page %>%
    html_node(".gs_ico_nav_next a") %>%
    html_attr("href")
  
    # Agregar un retraso de 5 segundos
    Sys.sleep(5)

  if (is.na(next_page)) {
    break
  }
  
  current_url <- paste0("https://scholar.google.com", next_page)
}

# Almacenar los datos en un archivo CSV
write.csv(data, "web_scraping_citas.csv", row.names = FALSE)