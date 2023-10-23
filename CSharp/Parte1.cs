using System;
using System.Collections.Generic;
using System.IO;
using HtmlAgilityPack;

class Parte1
{
    static void Main()
    {
        string url = "https://scholar.google.com/scholar?cites=5866269323493626547&as_sdt=2005&sciodt=0,5&hl=es";
        HtmlWeb web = new HtmlWeb();
        HtmlDocument doc = web.Load(url);

        List<string> titulos = new List<string>();
        List<string> autores = new List<string>();
        List<string> revistas = new List<string>();
        List<string> años = new List<string>();
        List<string> editoriales = new List<string>();
        List<string> urls = new List<string>();
        List<string> citas = new List<string>();

        ExtractData(doc, titulos, autores, revistas, años, editoriales, urls, citas);

        var nextPageButton = doc.DocumentNode.SelectSingleNode("//button[@class='gs_btnP gs_in_ib']");
        while (nextPageButton != null)
        {
            string nextPageUrl = "https://scholar.google.com" + nextPageButton.GetAttributeValue("onclick", "").Split('\'')[1];
            doc = web.Load(nextPageUrl);
            ExtractData(doc, titulos, autores, revistas, años, editoriales, urls, citas);
            nextPageButton = doc.DocumentNode.SelectSingleNode("//button[@class='gs_btnP gs_in_ib']");
        }

        // Create a CSV file to store the data
        using (StreamWriter writer = new StreamWriter("web_scraping_citas.csv"))
        {
            writer.WriteLine("Título,Autor,Revista,Año,Editorial,URL,Citas");
            for (int i = 0; i < titulos.Count; i++)
            {
                string line = $"{EscapeCSVField(titulos[i])},{EscapeCSVField(autores[i])},{EscapeCSVField(revistas[i])},{EscapeCSVField(años[i])},{EscapeCSVField(editoriales[i])},{EscapeCSVField(urls[i])},{EscapeCSVField(citas[i])}";
                writer.WriteLine(line);
            }
        }
    }

    static void ExtractData(HtmlDocument doc, List<string> titulos, List<string> autores, List<string> revistas, List<string> años, List<string> editoriales, List<string> urls, List<string> citas)
    {
        var items = doc.DocumentNode.SelectNodes("//div[@class='gs_ri']");
        if (items != null)
        {
            foreach (var item in items)
            {
                var tituloElement = item.SelectSingleNode("h3");
                var autorElement = item.SelectSingleNode("div[@class='gs_a']");
                var revistaElement = item.SelectSingleNode("div[@class='gs_pub']");
                var añoElement = item.SelectSingleNode("span[@class='gs_citi']");
                var editorialElement = item.SelectSingleNode("div[@class='gs_a']");
                var urlElement = item.SelectSingleNode("h3/a");
                var citaElement = item.SelectSingleNode("div[@class='gs_fl']/a[3]");

                string titulo = tituloElement != null ? tituloElement.InnerText.Trim() : "Sin título";
                string autor = autorElement != null ? autorElement.InnerText.Trim() : "Sin autor";
                string revista = revistaElement != null ? revistaElement.InnerText.Trim() : "Sin revista";
                string año = añoElement != null ? añoElement.InnerText.Trim() : "Sin año";
                string editorial = editorialElement != null ? editorialElement.InnerText.Trim().Split('-')[^1].Trim() : "Sin editorial";
                string url = urlElement != null ? urlElement.GetAttributeValue("href", "Sin URL") : "Sin URL";
                string cita = citaElement != null ? citaElement.InnerText.Trim() : "Sin cita";

                titulos.Add(titulo);
                autores.Add(autor);
                revistas.Add(revista);
                años.Add(año);
                editoriales.Add(editorial);
                urls.Add(url);
                citas.Add(cita);
            }
        }
    }

    static string EscapeCSVField(string field)
    {
        // If the field contains a comma, wrap it in double quotes
        if (field.Contains(","))
        {
            return $"\"{field.Replace("\"", "\"\"")}\"";
        }
        return field;
    }
}