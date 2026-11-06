const express = require("express");
const app = express();
const port = 3000;


const pool = require('./mysql');


app.get("/", async (req, res) => {
    const { category, author, format } = req.query;

    let sqlQuery;
    let params;

    if (category) {
        sqlQuery = "SELECT * FROM books WHERE category = ?";
        params = [category];
    } else if (author) {
        sqlQuery = "SELECT * FROM books WHERE author = ?";
        params = [author];
    } else {
        return res.status(400).send("error: Please provide a 'category' or 'author' parameter.");
    }

    try {
        const [results] = await pool.execute(sqlQuery, params);

        if (format === "text") {
            // HTML
            let html = "";
            results.forEach(function (book) {
                html += `${book.bookid}: ${book.title} by ${book.author} (${book.category}) - $${book.price}<br>`;
            });
            res.send(html);
        } else {
            // JSON
            res.json(results);
        }
    } catch (err) {
        console.error("Database error:", err.message);
        res.status(500).send("A database error occurred.");
    }
});

app.listen(port, function () {
    console.log(`Server running on http://localhost:${port}`);
});
