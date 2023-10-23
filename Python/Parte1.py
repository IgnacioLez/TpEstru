import requests
from bs4 import BeautifulSoup
import pandas as pd
import bibtexparser

# Definir la URL de la página de "citado por"
url = "https://scholar.google.com/scholar?cites=5866269323493626547&as_sdt=2005&sciodt=0,5&hl=es"

# Realizar solicitud HTTP
response = requests.get(url)
soup = BeautifulSoup(response.text, 'html.parser')

# Crear listas para almacenar los datos
titulos = []
autores = []
revistas = []
años = []
editoriales = []
urls = []
citas = []

# Definir una función para extraer los datos de una página
def extraer_datos(soup):
    for item in soup.find_all('div', class_='gs_ri'):
    #    titulo_elemento = item.find('h3')
    #    autor_elemento = item.find('div', class_='gs_a')
    #    revista_elemento = item.find('div', class_='gs_pub')
    #    año_elemento = item.find('span', class_='gs_citi')
    #    editorial_elemento = item.find('div', class_='gs_a')
        url_elemento = item.find('h3').find('a')
        cita_elemento = item.find('div', class_='gs_fl').find_all('a')[2]
        
    #   if titulo_elemento:
    #        titulo = titulo_elemento.get_text()
    #    else:
    #        titulo = "Sin título"
    #    
    #    if autor_elemento:
    #        autor = autor_elemento.get_text()
    #    else:
    #        autor = "Sin autor"
        
    #    if revista_elemento:
    #        revista = revista_elemento.get_text()
    #    else:
    #        revista = "Sin revista"
        
    #    if año_elemento:
    #        año = año_elemento.get_text()
    #    else:
    #        año = "Sin año"
        
    #    if editorial_elemento:
    #        editorial = editorial_elemento.get_text().split('-')[-1].strip()
    #    else:
    #        editorial = "Sin editorial"
        
        if url_elemento:
            url = url_elemento['href']
        else:
            url = "Sin URL"
        
        if cita_elemento:
            cita = cita_elemento.get_text()
        else:
            cita = "Sin cita"
        
        titulos.append(titulo)
        autores.append(autor)
        revistas.append(revista)
        años.append(año)
        editoriales.append(editorial)
        urls.append(url)
        citas.append(cita)

# Extraer datos de la primera página
extraer_datos(soup)

# Manejar la paginación (navegar a través de las páginas) si hay más páginas
siguiente_pagina = soup.find('button', class_='gs_btnP gs_in_ib')
while siguiente_pagina:
    siguiente_url = "https://scholar.google.com" + siguiente_pagina['onclick'].split('\'')[1]
    siguiente_respuesta = requests.get(siguiente_url)
    siguiente_soup = BeautifulSoup(siguiente_respuesta.text, 'html.parser')
    extraer_datos(siguiente_soup)
    siguiente_pagina = siguiente_soup.find('button', class_='gs_btnP gs_in_ib')

# Crear un DataFrame para almacenar los datos
datos = pd.DataFrame({
    'Título': titulos,
    'Autor': autores,
    'Revista': revistas,
    'Año': años,
    'Editorial': editoriales,
    'URL': urls,
    'Citas': citas
})

# Almacenar los datos en un archivo CSV
datos.to_csv('web_scraping_citas.csv', index=False)