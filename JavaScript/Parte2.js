const fs = require('fs');
const csv = require('csv-parser');
const ObjectsToCsv = require('objects-to-csv');
const readline = require('readline');

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

function loadAndProcessData() {
  const articles = [];
  fs.createReadStream('web_scraping_citas.csv')
    .pipe(csv())
    .on('data', (row) => {
      articles.push(row);
    })
    .on('end', () => {
      console.log('Datos cargados correctamente.');
      console.log('Elija una opción:');
      console.log('1. Identificar los 10 artículos con más citas.');
      console.log('2. Búsqueda de palabras clave en títulos.');
      console.log('3. Contar todos los autores.');
      console.log('4. Visualización gráfica.');
      rl.question('Opción: ', (option) => {
        switch (option) {
          case '1':
            top10CitedArticles(articles);
            break;
          case '2':
            searchByKeyword(articles);
            break;
          case '3':
            countAuthors(articles);
            break;
          case '4':
            visualizeData(articles);
            break;
          default:
            console.log('Opción no válida.');
        }
        rl.close();
      });
    });
}

function top10CitedArticles(articles) {
  articles.sort((a, b) => b['Citado por'] - a['Citado por']);
  const top10 = articles.slice(0, 10);
  const csv = new ObjectsToCsv(top10);
  csv.toDisk('top_10_cited_articles.csv').then(() => {
    console.log('Top 10 artículos con más citas guardados en top_10_cited_articles.csv');
  });
}

function searchByKeyword(articles) {
  rl.question('Ingrese una palabra clave: ', (keyword) => {
    const filteredArticles = articles.filter(article => article.Title.toLowerCase().includes(keyword.toLowerCase()));
    const csv = new ObjectsToCsv(filteredArticles);
    csv.toDisk('articles_with_keyword.csv').then(() => {
      console.log(`Artículos con la palabra clave "${keyword}" guardados en articles_with_keyword.csv`);
    });
  });
}

function countAuthors(articles) {
  const authorsCount = {};
  articles.forEach(article => {
    const authors = article.Author.split(', ');
    authors.forEach(author => {
      authorsCount[author] = (authorsCount[author] || 0) + 1;
    });
  });
  const authorsArray = Object.keys(authorsCount).map(author => ({ Author: author, Count: authorsCount[author] }));
  authorsArray.sort((a, b) => b.Count - a.Count);
  const csv = new ObjectsToCsv(authorsArray);
  csv.toDisk('authors_count.csv').then(() => {
    console.log('Conteo de autores guardado en authors_count.csv');
  });
}

function visualizeData(articles) {
  // Aquí puedes realizar la visualización gráfica, como generar un gráfico de nube de palabras y un gráfico de barras.
  // Puedes usar bibliotecas como D3.js, Chart.js, o cualquier otra de tu elección para crear las visualizaciones.
  console.log('Visualización gráfica no implementada en este ejemplo.');
}

loadAndProcessData();