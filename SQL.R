library(RSQLite)
library(DBI)

##Criando uma conexão
con <- dbConnect(RSQLite::SQLite() ,'chinook.db')

##Listando tabelas do banco de dados
dbListTables(con)

##Usando SQL no R
#SELECT

resultado <- dbGetQuery(con, "SELECT * FROM mtcars")
resultado

#WHERE
resultado <- dbGetQuery(con, "SELECT row_names, cyl FROM mtcars WHERE cyl = 8")
resultado

#ORDER BY
resultado <- dbGetQuery(con, "SELECT * FROM mtcars ORDER BY hp DESC")
resultado

#GROUP BY
resultado <- dbGetQuery(con, "SELECT cyl, COUNT(*) AS n_por_cyl FROM mtcars GROUP BY cyl")
resultado

#INNER JOIN
resultado <- dbGetQuery(con, "SELECT t.TrackId, t.Name, a.ArtistId FROM tracks AS t
                        INNER JOIN albums AS a ON t.AlbumId = a.AlbumId ")
resultado

#LEFT JOIN
resultado <- dbGetQuery(con, "SELECT t.TrackId, t.Name, a.ArtistId FROM tracks AS t
                        LEFT JOIN albums AS a ON t.AlbumId = a.AlbumId ")
resultado

#RIGHT JOIN
resultado <- dbGetQuery(con, "SELECT t.TrackId, t.Name, a.ArtistId FROM tracks AS t
                        RIGHT JOIN albums AS a ON t.AlbumId = a.AlbumId ")
resultado

#FULL JOIN
resultado <- dbGetQuery(con, "SELECT t.TrackId, t.Name, a.ArtistId FROM tracks AS t
                        FULL JOIN albums AS a ON t.AlbumId = a.AlbumId ")
resultado

##SUBCONSULTAS
#WHERE
resultado <- dbGetQuery(con, "SELECT Name FROM tracks WHERE AlbumId IN (
                        SELECT AlbumId FROM albums WHERE ArtistId = 1)")
resultado

#SELECT
resultado <- dbGetQuery(con, "SELECT Name, (
                        SELECT AVG (UnitPrice) FROM invoice_items WHERE tracks.TrackId = invoice_items.TrackId) 
                        FROM tracks LIMIT 10")
resultado

##OPERACOES DE AGREGACAO
resultado <- dbGetQuery(con, "SELECT g.Name AS Genre, COUNT(t.TrackId) AS TrackCount, AVG(UnitPrice) AS AveragePrice
                        FROM tracks AS t 
                        JOIN genres AS g ON t.GenreId = g.GenreId
                        GROUP BY g.Name")
resultado

##CONSULTA COMPLEXA [CASE e IF-ELSE]
resultado <- dbGetQuery(con, "SELECT AlbumId, Title,
                                  CASE
                                      WHEN (
                                          SELECT COUNT(*)
                                          FROM tracks
                                          WHERE tracks.AlbumId = albums.AlbumId
                                      ) > 10 THEN 'Mais de 10 faixas'
                                      ELSE 'Menos de 10 faixas'
                                  END AS Track_Count_Category
                              FROM albums")
resultado

#GROUP BY e HAVING
resultado <- dbGetQuery(con, "SELECT BillingCountry, SUM(Total) AS TotalSales
                        FROM invoices
                        GROUP BY BillingCountry")
resultado

resultado <- dbGetQuery(con, "SELECT GenreId, COUNT(*) AS TrackCount
                        FROM tracks
                        GROUP BY GenreId
                        HAVING TrackCount > 100")
resultado

##FUNCOES DE AGREGACAO GROUP_CONCAT, STDDEV, VARIANCE
comando <- "
SELECT artists.Name AS Artist, GROUP_CONCAT(DISTINCT genres.Name) AS Genres
FROM artists
JOIN albums ON artists.ArtistId = albums.ArtistId
JOIN tracks ON albums.AlbumId = tracks.AlbumId
JOIN genres ON tracks.GenreId = genres.GenreId
GROUP BY artists.ArtistId
"
resultado <- dbGetQuery(con, comando)
resultado

##CONNECT BY
comando <- "
SELECT PlaylistId, Name, PlaylistId AS ParentId, 0 AS Level
FROM playlists
WHERE PlaylistId = 1
UNION ALL
SELECT p.PlaylistId, p.Name, t.PlaylistId AS ParentId, t.Level +1 AS Level
FROM playlists p
JOIN playlist_track t ON p.PlaylistId = t.TrackId
"
resultado <- dbGetQuery(con, comando)
resultado
