const express = require("express");
const bodyParser = require("body-parser");
const path = require("path");

const app = express();
const port = 3000;

// Middleware
app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json()); // Add JSON parsing middleware
app.set("view engine", "ejs");
app.set("views", path.join(__dirname, "views"));

// Rutas
const vendedoresRoutes = require("./routes/vendedores");
app.use("/vendedores", vendedoresRoutes);

// Ruta principal
app.get("/", (req, res) => {
  res.redirect("/vendedores");
});

// Iniciar servidor
app.listen(port, () => {
  console.log(`Servidor corriendo en http://localhost:${port}`);
});