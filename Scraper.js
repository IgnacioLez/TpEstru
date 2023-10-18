const puppeteer = require('puppeteer');
const cheerio = require('cheerio');
const fs = require('fs');

(async () => {
  const navegador = await puppeteer.launch();
  const pagina = await navegador.newPage();

  // Ingresa la URL de Google Scholar de "citado por"
  const url = 'https://scholar.google.com/scholar?cites=5866269323493626547&as_sdt=2005&sciodt=0,5&hl=es';
  await pagina.goto(url);

  // Función para extraer los datos de cada artículo
  const extraerDatosArticulo = async (articulo) => {
    const titulo = articulo.find('.gs_rt').text().trim();
    const autores = articulo.find('.gs_a').text().trim();
    const revista = articulo.find('.gs_pub').text().trim();
    const anio = articulo.find('.gs_a').text().match(/\d{4}/);
    const editorial = articulo.find('.gs_pub').text().replace(revista, '').trim();
    const url = articulo.find('h3 a').attr('href');
    const citadoPor = articulo.find('.gs_ri a').text().match(/\d+/);

    return {
      Título: titulo,
      Autor: autores,
      Revista: revista,
      Año: anio ? anio[0] : '',
      Editorial: editorial,
      URL: url,
      'Citado por': citadoPor ? citadoPor[0] : '',
    };
  };

  const articulos = [];

  // Recorre las páginas y extrae la información de los artículos
  let haySiguientePagina = true;
  while (haySiguientePagina) {
    const contenidoPagina = await pagina.content();
    const $ = cheerio.load(contenidoPagina);

    // Extrae los datos de cada artículo en la página actual
    $('.gs_r').each((_, el) => {
      const datosArticulo = extraerDatosArticulo($(el));
      articulos.push(datosArticulo);
    });

    // Verifica si hay una página siguiente
    const botonSiguiente = $('.gs_ico_nav_next');
    if (botonSiguiente.length > 0) {
      await botonSiguiente.click();
      await pagina.waitForTimeout(2000); // Espera un poco para evitar la detección de bots
    } else {
      haySiguientePagina = false;
    }
  }

  // Cierra el navegador
  await navegador.close();

  // Almacena los datos extraídos en un archivo CSV
  const datosCSV = articulos.map((articulo) => Object.values(articulo).join(','));
  const encabezadoCSV = Object.keys(articulos[0]).join(',');

  fs.writeFileSync('web_scraping_citas.csv', `${encabezadoCSV}\n${datosCSV.join('\n')}`);
})();
