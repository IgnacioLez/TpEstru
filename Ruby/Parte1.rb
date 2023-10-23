require 'open-uri'
require 'nokogiri'
require 'csv'

# Definir la URL de la página de "citado por"
url = "https://scholar.google.com/scholar?cites=5866269323493626547&as_sdt=2005&sciodt=0,5&hl=es"

# Realizar solicitud HTTP
response = URI.open(url)
doc = Nokogiri::HTML(response)

# Crear listas para almacenar los datos
titulos = []
autores = []
revistas = []
años = []
editoriales = []
urls = []
citas = []

# Definir una función para extraer los datos de una página
def extraer_datos(doc)
  doc.css('div.gs_ri').each do |item|
    titulo_elemento = item.at('h3')
    autor_elemento = item.at('div.gs_a')
    revista_elemento = item.at('div.gs_pub')
    año_elemento = item.at('span.gs_citi')
    editorial_elemento = item.at('div.gs_a')
    url_elemento = item.at('h3 a')
    cita_elemento = item.at('div.gs_fl a:nth-child(3)')

    titulo = titulo_elemento ? titulo_elemento.text : "Sin título"
    autor = autor_elemento ? autor_elemento.text : "Sin autor"
    revista = revista_elemento ? revista_elemento.text : "Sin revista"
    año = año_elemento ? año_elemento.text : "Sin año"
    editorial = editorial_elemento ? editorial_elemento.text.split('-').last.strip : "Sin editorial"
    url = url_elemento ? url_elemento['href'] : "Sin URL"
    cita = cita_elemento ? cita_elemento.text : "Sin cita"

    titulos << titulo
    autores << autor
    revistas << revista
    años << año
    editoriales << editorial
    urls << url
    citas << cita
  end
end

# Extraer datos de la primera página
extraer_datos(doc)

# Manejar la paginación (navegar a través de las páginas) si hay más páginas
siguiente_pagina = doc.at('button.gs_btnP.gs_in_ib')
while siguiente_pagina
  siguiente_url = "https://scholar.google.com" + siguiente_pagina['onclick'].split("'")[1]
  sleep(5) # Espera 5 segundos
  siguiente_response = URI.open(siguiente_url)
  siguiente_doc = Nokogiri::HTML(siguiente_response)
  extraer_datos(siguiente_doc)
  siguiente_pagina = siguiente_doc.at('button.gs_btnP.gs_in_ib')
end

# Crear un array de hashes para almacenar los datos
datos = []
(0...titulos.length).each do |i|
  datos << {
    'Título' => titulos[i],
    'Autor' => autores[i],
    'Revista' => revistas[i],
    'Año' => años[i],
    'Editorial' => editoriales[i],
    'URL' => urls[i],
    'Citas' => citas[i]
  }
end

# Almacenar los datos en un archivo CSV
CSV.open('web_scraping_citas.csv', 'w') do |csv|
  csv << datos[0].keys
  datos.each do |dato|
    csv << dato.values
  end
end