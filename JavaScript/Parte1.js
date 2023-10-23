const puppeteer = require('puppeteer');
const ObjectsToCsv = require('objects-to-csv');

async function scrapeGoogleScholarCitations(url) {
  try {
    // Lanzar Puppeteer con la nueva implementación headless
    const browser = await puppeteer.launch({ headless: "new" });
    const page = await browser.newPage();
    await page.goto(url);

    const articles = [];

    async function scrapeArticleInfo() {
      // Selector para los enlaces a los artículos
      const articlesOnPage = await page.$$('h3 a');

      for (const articleLink of articlesOnPage) {
        const article = {};
        article.Title = await articleLink.evaluate(node => node.innerText);

        // Navegar al enlace del artículo
        const articleUrl = await articleLink.getProperty('href');
        await page.goto(articleUrl);

        // Capturar información del artículo
        await page.waitForSelector('a[href*="/scholar.bib"]');
        const bibLink = await page.$('a[href*="/scholar.bib"]');
        article.BibTeX = await bibLink.evaluate(node => node.getAttribute('href'));

        const infoSections = await page.$$('div.gs_a');
        const infoText = await infoSections[0].evaluate(node => node.innerText);
        const infoParts = infoText.split('-');
        article.Author = infoParts[0].trim();
        article.Year = infoText.match(/\d{4}/)[0];
        article.Journal = infoParts[1].trim();
        article.Publisher = (await infoSections[1].evaluate(node => node.innerText)).replace(' -', '').trim();

        article.URL = articleUrl;

        const citations = await page.$('a[href*="cites="]');
        article['Citado por'] = (await citations.evaluate(node => node.innerText)).replace('Citado por ', '');

        articles.push(article);

        // Regresar a la página anterior
        await page.goBack();
      }
    }

    // Realizar el scraping de la página actual
    await scrapeArticleInfo();

    // Navegar a las siguientes páginas
    while (true) {
      const nextPageButton = await page.$('span.gs_ico + a');
      if (nextPageButton) {
        await nextPageButton.click();
        await page.waitForTimeout(2000); // Esperar a que cargue la página
        await scrapeArticleInfo();
      } else {
        break;
      }
    }

    await browser.close();

    // Guardar los datos en un archivo CSV
    const csv = new ObjectsToCsv(articles);
    await csv.toDisk('web_scraping_citas.csv');

    console.log('Web scraping completado y datos guardados en web_scraping_citas.csv');
  } catch (error) {
    console.error('Error durante el scraping:', error);
  }
}

const url = 'URL de Google Scholar aquí'; // Reemplaza con la URL que desees
scrapeGoogleScholarCitations('https://scholar.google.com/scholar?hl=en&as_sdt=0%2C5&q=cancer&btnG=');