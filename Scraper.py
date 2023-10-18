import requests
from bs4 import BeautifulSoup
import pandas as pd

def extraer_datos(url):
    try:
        headers = {'User-Agent': 'Mozilla/5.0'}
        page = requests.get(url, headers=headers)
        soup = BeautifulSoup(page.content, 'html.parser')

        # Extraer información del artículo
        title = soup.find('div', class_='gs_rt').a.text
        authors_journal = soup.find('div', class_='gs_a').text
        cited_by = soup.find('div', class_='gs_fl').a.text.split()[-1]

        # Extraer información de BibTeX
        import_link = soup.find('div', class_='gs_fl').find_all('a')[3]['href']
        bibtex_page = requests.get(import_link, headers=headers)
        bibtex_soup = BeautifulSoup(bibtex_page.content, 'html.parser')
        bibtex_text = bibtex_soup.pre.text

        # Extraer información de BibTeX
        bibtex_lines = bibtex_text.split('\n')
        title = authors = journal = year = publisher = ''
        for line in bibtex_lines:
            if 'title' in line:
                title = line.split('{')[-1].replace('},', '')
            elif 'author' in line:
                authors = line.split('{')[-1].replace('},', '')
            elif 'journal' in line:
                journal = line.split('{')[-1].replace('},', '')
            elif 'year' in line:
                year = line.split('{')[-1].replace('},', '')
            elif 'publisher' in line:
                publisher = line.split('{')[-1].replace('},', '')

    except Exception as e:
        print(f"Error al extraer información del artículo: {url}. Error: {e}")
        return None

    return [title, authors, journal, year, publisher, url, cited_by]

def scrape_google_scholar(url):
    headers = {'User-Agent': 'Mozilla/5.0'}
    page = requests.get(url, headers=headers)
    soup = BeautifulSoup(page.content, 'html.parser')

    Info_articulos = []
    while True:
        # Extraer información de cada artículo en la página actual
        for link in soup.find_all('h3', class_='gs_rt'):
            url_articulo = link.a['href']
            info_articulo =extraer_datos(url_articulo)
            if info_articulo is not None:
                Info_articulos.append(info_articulo)

        # Ir a la siguiente página si existe
        next_button = soup.find('button', class_='gs_btnPR')
        if next_button is None or next_button['aria-disabled'] == 'true':
            break
        else:
            next_url = 'https://scholar.google.com' + next_button['onclick'].split('\\')[2]
            page = requests.get(next_url, headers=headers)
            soup = BeautifulSoup(page.content, 'html.parser')

    # Crear DataFrame y guardar en CSV
    df = pd.DataFrame(Info_articulos, columns=['Titulo', 'Autor', 'Journal', 'Anio', 'Publicador', 'URL', 'Citado por'])
    df.to_csv('web_scraping_citas.csv')

# Ejemplo de uso
scrape_google_scholar('https://scholar.google.com/scholar?cites=5866269323493626547&as_sdt=2005&sciodt=0,5&hl=es')