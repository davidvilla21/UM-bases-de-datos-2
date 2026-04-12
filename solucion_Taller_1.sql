
--SUBCONSULTAS
--Obtener los nombres y apellidos de los usuarios que han reservado un libro de la categoría "Fiction".
SELECT FirstName, LastName 
FROM Users 
WHERE UserID IN ( 
SELECT UserID 
FROM Reservations 
WHERE BookID IN ( 
SELECT BookID 
FROM Books 
WHERE CategoryID IN (
 SELECT CategoryID 
FROM BookCategories 
WHERE CategoryName = 'Fiction'
 ) 
) 
);

--Mostrar el título y autor de los libros que están prestados.
SELECT Title, Author
FROM Books
WHERE BookID IN (
    SELECT BookID
    FROM Loans
    WHERE ReturnDate IS NULL
);

--OPERADORES CONJUNTOS
--Encontrar los títulos de los libros que han sido reservados, pero no prestados.
SELECT b.Title
FROM Books b
JOIN Reservations r ON b.BookID = r.BookID
EXCEPT -- (En algunos motores como Oracle se usa MINUS en lugar de EXCEPT)
SELECT b.Title
FROM Books b
JOIN Loans l ON b.BookID = l.BookID;

--Encontrar los títulos de los libros que han sido prestados, pero no reservados.
SELECT b.Title
FROM Books b
JOIN Loans l ON b.BookID = l.BookID
EXCEPT
SELECT b.Title
FROM Books b
JOIN Reservations r ON b.BookID = r.BookID;


--EXPRESIONES CONDICIONALES
--Mostrar un listado de todos los libros con un estado: "Disponible" si AvailableCopies > 0, o "Agotado" si no hay copias disponibles.
SELECT Title, AvailableCopies,
    CASE
        WHEN AvailableCopies > 0 THEN 'Disponible'
        ELSE 'Agotado'
    END AS Estado
FROM Books;

--Mostrar los usuarios y clasifícalos como "Activo" si tienen libros prestados y "Sin actividad" si no.
SELECT FirstName, LastName,
    CASE
        WHEN EXISTS (SELECT 1 FROM Loans l WHERE l.UserID = u.UserID) THEN 'Activo'
        ELSE 'Sin actividad'
    END AS Clasificacion
FROM Users u;

--ANÁLISIS AGREGADO CON GROUP BY Y HAVING
--Encontrar las categorías con más de 3 libros.
SELECT bc.CategoryName, COUNT(b.BookID) AS TotalLibros
FROM BookCategories bc
JOIN Books b ON bc.CategoryID = b.CategoryID
GROUP BY bc.CategoryID, bc.CategoryName
HAVING COUNT(b.BookID) > 3;

#Mostrar los usuarios que tienen más de 2 libros reservados.
SELECT u.FirstName, u.LastName, COUNT(r.ReservationID) AS TotalReservas
FROM Users u
JOIN Reservations r ON u.UserID = r.UserID
GROUP BY u.UserID, u.FirstName, u.LastName
HAVING COUNT(r.ReservationID) > 2;
 
--INNER JOIN
--Mostrar un listado de los nombres de usuarios y los títulos de los libros que han sido prestados.
SELECT u.FirstName, u.LastName, b.Title
FROM Users u
INNER JOIN Loans l ON u.UserID = l.UserID
INNER JOIN Books b ON l.BookID = b.BookID;

--Mostrar los nombres de usuarios y los títulos de los libros que han reservado.
SELECT u.FirstName, u.LastName, b.Title
FROM Users u
INNER JOIN Reservations r ON u.UserID = r.UserID
INNER JOIN Books b ON r.BookID = b.BookID;

--LEFT JOIN
--Listar todos los libros junto con el nombre del usuario que los reservó, si es que existe una reserva.
SELECT b.Title, u.FirstName, u.LastName
FROM Books b
LEFT JOIN Reservations r ON b.BookID = r.BookID
LEFT JOIN Users u ON r.UserID = u.UserID;


--Lista todos los usuarios junto con el título del libro prestado, si existe un préstamo.
SELECT u.FirstName, u.LastName, b.Title
FROM Users u
LEFT JOIN Loans l ON u.UserID = l.UserID
LEFT JOIN Books b ON l.BookID = b.BookID;


--RIGHT JOIN
--Lista todos los libros junto con los nombres de los usuarios que los han reservado, incluyendo los libros que no tienen reservas.
SELECT b.Title, u.FirstName, u.LastName
FROM Users u
JOIN Reservations r ON u.UserID = r.UserID
RIGHT JOIN Books b ON r.BookID = b.BookID;

--Lista todos los usuarios junto con los títulos de los libros prestados, incluyendo los usuarios que no han realizado préstamos.
SELECT u.FirstName, u.LastName, b.Title
FROM Books b
JOIN Loans l ON b.BookID = l.BookID
RIGHT JOIN Users u ON l.UserID = u.UserID;

--FUNCIONES ESPECIALIZADAS
--Mostrar un listado de los títulos de los libros en mayúsculas.
SELECT UPPER(Title) AS TituloMayusculas
FROM Books;

--Mostrar los nombres de los usuarios concatenados en un solo campo (Nombre Completo).
SELECT CONCAT(FirstName, ' ', LastName) AS NombreCompleto
FROM Users;

-- FUNCIONES DE FECHA
--Calcular el número de días que han pasado desde que se reservó cada libro.
SELECT ReservationID, BookID, DATEDIFF(CURRENT_DATE, ReservationDate) AS DiasTranscurridos
FROM Reservations;

--Mostrar los préstamos que están pendientes de devolución (ReturnDate es NULL).
SELECT LoanID, UserID, BookID, LoanDate
FROM Loans
WHERE ReturnDate IS NULL;


--FUNCIONES DE AGREGACIÓN
--Calcular el total de copias disponibles para cada categoría
SELECT bc.CategoryName, SUM(b.AvailableCopies) AS TotalCopiasDisponibles
FROM BookCategories bc
JOIN Books b ON bc.CategoryID = b.CategoryID
GROUP BY bc.CategoryID, bc.CategoryName;

--Encontrar el número total de libros prestados por cada usuario.
SELECT u.FirstName, u.LastName, COUNT(l.LoanID) AS TotalLibrosPrestados
FROM Users u
LEFT JOIN Loans l ON u.UserID = l.UserID
GROUP BY u.UserID, u.FirstName, u.LastName;

