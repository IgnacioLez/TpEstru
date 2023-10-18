require 'nokogiri'
require 'httparty'
require 'csv'

# Definir la URL de Google Scholar
url = 'https://scholar.google.com/scholar?cites=5866269323493626547&as_sdt=2005&sciodt=0,5&hl=es'

# Función para extraer los datos de una página de citas
def extraer_datos_citacion(url)
  respuesta = HTTParty.get(url)
  pagina = Nokogiri::HTML(respuesta)

  datos_citacion = []

  pagina.css('.gs_r').each do |articulo|
    titulo = articulo.css('.gs_rt a').text
    autores = articulo.css('.gs_a').text
    revista = articulo.css('.gs_a').text
    año = articulo.css('.gs_a').text
    editorial = articulo.css('.gs_a').text
    url_fuente = articulo.css('.gs_rt a').attr('href')
    citado_por = articulo.css('.gs_ri a').text.to_i

    datos_citacion << [titulo, autores, revista, año, editorial, url_fuente, citado_por]
  end

  datos_citacion
end

# Función para guardar los datos en un archivo CSV
def guardar_en_csv(datos)
  CSV.open('web_scraping_citas.csv', 'w') do |csv|
    csv << ['Título', 'Autores', 'Revista', 'Año', 'Editorial', 'URL Fuente', 'Citado Por']
    datos.each do |fila|
      csv << fila
    end
  end
end

# Iniciar el proceso de extracción y paginación
todos_los_datos_citacion = []
numero_pagina = 1

loop do
  url_pagina_actual = "#{url}&start=#{(numero_pagina - 1) * 10}"
  datos_pagina_citacion = extraer_datos_citacion(url_pagina_actual)

  if datos_pagina_citacion.empty?
    break  # No hay más páginas de citas
  end

  todos_los_datos_citacion.concat(datos_pagina_citacion)
  numero_pagina += 1
end

# Guardar los datos en un archivo CSV
guardar_en_csv(todos_los_datos_citacion)