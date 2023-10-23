require 'csv'
require 'wordcloud'
require 'chartkick'

# Leer los datos del archivo CSV
data = CSV.read('web_scraping_citas.csv', headers: true)

# Ordenar por número de citas y guardar los 10 artículos principales
top_articles = data.sort_by { |row| row['Citado por'].to_i }.reverse[0..9]

# Guardar los 10 artículos principales en un archivo CSV
CSV.open('top_10_articles.csv', 'w') do |csv|
  csv << ["Número de Citas", "Año de Publicación", "Título del Artículo", "Revista"]
  top_articles.each do |article|
    csv << [article['Citado por'], article['Year'], article['Title'], article['Journal']]
  end
end

# Búsqueda de palabras clave en los títulos
print "Ingresa una palabra clave: "


keyword = gets.chomp

# Filtrar títulos que contienen la palabra clave
titles_with_keyword = data.select { |row| row['Title'].downcase.include?(keyword.downcase) }

# Guardar los resultados en un archivo CSV
CSV.open('titles_with_keyword.csv', 'w') do |csv|
  csv << ["Título", "URL"]
  titles_with_keyword.each do |article|
    csv << [article['Title'], article['URL']]
  end
end

# Contar todos los autores
author_counts = Hash.new(0)

data.each do |row|
  authors = row['Autor'].split('-')
  authors.each do |author|
    author_counts[author.strip] += 1
  end
end

# Ordenar por el número de apariciones y guardar en un archivo CSV
sorted_authors = author_counts.sort_by { |_author, count| -count }

CSV.open('author_counts.csv', 'w') do |csv|
  csv << ["Autor", "Número de Apariciones"]
  sorted_authors.each do |author, count|
    csv << [author, count]
  end
end

# Crear una nube de palabras
word_cloud_data = sorted_authors.to_h
word_cloud = WordCloud.new(word_cloud_data)
word_cloud.to_file('word_cloud.png')

# Contar la cantidad de artículos por año y crear un gráfico de barras
articles_by_year = data.group_by { |row| row['Year'] }.transform_values(&:count)

bar_chart = Chartkick::BarChart.new(articles_by_year, xtitle: 'Año', ytitle: 'Número de Artículos', library: { animation: { startup: true, duration: 1000 } })
bar_chart.save('articles_by_year.html')