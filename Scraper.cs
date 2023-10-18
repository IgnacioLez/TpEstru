using System;
using System.Collections.Generic;
using System.Net;
using HtmlAgilityPack;

class Program
{
    static void Main(string[] args)
    {
        string url = "https://scholar.google.com/scholar?cites=5866269323493626547&as_sdt=2005&sciodt=0,5&hl=es";
        int maxPaginas = 10; // Número máximo de páginas a explorar

        List<Articulo> articulos = new List<Articulo>();

        for (int pagina = 0; pagina < maxPaginas; pagina++)
        {
            string urlActual = $"{url}&start={pagina * 10}";
            HtmlWeb web = new HtmlWeb();
            HtmlDocument documento = web.Load(urlActual);

            var nodosArticulo = documento.DocumentNode.SelectNodes("//div[@class='gs_ri']");
            if (nodosArticulo == null || nodosArticulo.Count == 0)
            {
                // No se encontraron más resultados.
                break;
            }

            foreach (var nodoArticulo in nodosArticulo)
            {
                Articulo articulo = new Articulo();

                // 1. Extraer información del artículo
                articulo.Titulo = nodoArticulo.SelectSingleNode(".//h3[@class='gs_rt']").InnerText;
                articulo.Autor = nodoArticulo.SelectSingleNode(".//div[@class='gs_a']").InnerText;
                articulo.Revista = nodoArticulo.SelectSingleNode(".//div[@class='gs_a']").InnerText;
                articulo.Año = nodoArticulo.SelectSingleNode(".//div[@class='gs_a']").InnerText;
                articulo.Editorial = nodoArticulo.SelectSingleNode(".//div[@class='gs_a']").InnerText;

                // 2. Extraer la URL
                var nodoEnlace = nodoArticulo.SelectSingleNode(".//h3[@class='gs_rt']//a");
                articulo.URL = nodoEnlace.GetAttributeValue("href", "");

                // 3. Extraer el número de citas
                var nodoCitadoPor = nodoArticulo.SelectSingleNode(".//div[@class='gs_fl']//a[contains(., 'Citado por')]");
                if (nodoCitadoPor != null)
                {
                    string textoCitadoPor = nodoCitadoPor.InnerText;
                    int inicio = textoCitadoPor.IndexOf("por ") + 4;
                    int fin = textoCitadoPor.IndexOf(" ", inicio);
                    string conteoCitadoPor = textoCitadoPor.Substring(inicio, fin - inicio);
                    articulo.CitadoPor = int.Parse(conteoCitadoPor);
                }

                articulos.Add(articulo);
            }
        }

        // 4. Almacenar los datos en un archivo CSV
        // Aquí debes escribir código para guardar los datos en un archivo CSV con el nombre "web_scraping_citas.csv".

        Console.WriteLine("Datos extraídos con éxito.");
    }
}

class Articulo
{
    public string Titulo { get; set; }
    public string Autor { get; set; }
    public string Revista { get; set; }
    public string Año { get; set; }
    public string Editorial { get; set; }
    public string URL { get; set; }
    public int CitadoPor { get; set; }
}