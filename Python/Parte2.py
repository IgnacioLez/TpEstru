import pandas as pd
from wordcloud import WordCloud
import matplotlib.pyplot as plt

# Cargar los datos desde el archivo CSV
datos = pd.read_csv('web_scraping_citas.csv')

# 1. Identificar los 10 artículos con más citas
top_10_articulos = datos.sort_values(by='Citas', ascending=False).head(10)
top_10_articulos.to_csv('top_10_articulos_citados.csv', index=False)

# 2. Búsqueda de palabras clave en títulos
palabra_clave = input("Ingresa una palabra clave: ")
resultados_palabra_clave = datos[datos['Título'].str.contains(palabra_clave, case=False)]
resultados_palabra_clave.to_csv('resultados_palabra_clave.csv', index=False)

# 3. Contar todos los autores
todos_autores = datos['Autor'].str.split(' - ', expand=True).stack().value_counts().reset_index()
todos_autores.columns = ['Autor', 'Conteo']
todos_autores.to_csv('todos_autores.csv', index=False)

# 4.1. Visualización de nube de palabras
titulos = " ".join(datos['Título'])
nube_palabras = WordCloud(width=800, height=400, background_color='white').generate(titulos)
plt.figure(figsize=(10, 5))
plt.imshow(nube_palabras, interpolation='bilinear')
plt.axis('off')
plt.title('Nube de Palabras en Títulos')
plt.show()

# 4.2. Contar la cantidad de artículos por año y hacer un gráfico de barras
conteo_articulos_por_año = datos['Año'].value_counts().sort_index()
conteo_articulos_por_año.plot(kind='bar')
plt.xlabel('Año de Publicación')
plt.ylabel('Número de Artículos')
plt.title('Cantidad de Artículos por Año de Publicación')
plt.show()