# Cargar las bibliotecas necesarias
library(dplyr)

# Leer los datos obtenidos del web scraping
data <- read.csv("web_scraping_citas.csv")

# 1. Identificar los 10 artículos con más citas
top_10_cited <- data %>%
  arrange(desc(Cited_By)) %>%
  head(10)

write.csv(top_10_cited, "top_10_citados.csv", row.names = FALSE)

# 2. Búsqueda de palabras clave en títulos
keyword <- readline("Ingresa una palabra clave: ")

articles_with_keyword <- data %>%
  filter(grepl(keyword, tolower(Title)))

write.csv(articles_with_keyword, "articles_with_keyword.csv", row.names = FALSE)

# 3. Contar todos los autores
author_counts <- data %>%
  separate_rows(Author, sep = ",") %>%
  trimws() %>%
  count(Author, sort = TRUE)

write.csv(author_counts, "author_counts.csv", row.names = FALSE)

# 4. Visualización gráfica
# 4.1. Gráfico de nube de palabras
library(tm)
library(wordcloud)

# Crear un corpus de los títulos
corpus <- Corpus(VectorSource(data$Title))
corpus <- tm_map(corpus, content_transformer(tolower))
corpus <- tm_map(corpus, removePunctuation)
corpus <- tm_map(corpus, removeNumbers)
corpus <- tm_map(corpus, removeWords, stopwords("spanish"))
corpus <- tm_map(corpus, stripWhitespace)

# Crear una matriz término-documento
dtm <- DocumentTermMatrix(corpus)
word_freqs <- row_sums(as.matrix(dtm))
wordcloud(names(word_freqs), word_freqs, min.freq = 3, colors = brewer.pal(8, "Dark2"))

# 4.2. Gráfico de barras de la cantidad de artículos por año de publicación
data$Year <- as.integer(data$Year)
year_counts <- data %>%
  filter(!is.na(Year)) %>%
  count(Year) %>%
  arrange(Year)

barplot(year_counts$n, names.arg = year_counts$Year, xlab = "Año de Publicación", ylab = "Número de Artículos")