const express = require("express");
const router = express.Router();
const db = require("../db");

// Listar vendedores con opción de búsqueda
router.get("/", async (req, res) => {
  const { busqueda, tipo } = req.query;
  
  console.log("Parámetros de búsqueda:", { busqueda, tipo });

  try {
    let result;
    if (busqueda && tipo && tipo !== "todos") {
      // Realizar búsqueda específica
      switch (tipo) {
        case "id":
          result = await db.query("CALL sp_busven(?)", [busqueda]);
          console.log("Búsqueda por ID:", busqueda);
          break;
        case "nombre":
          result = await db.query('CALL sp_selven(?, "nombre")', [busqueda]);
          console.log("Búsqueda por nombre:", busqueda);
          break;
        case "apellido":
          result = await db.query('CALL sp_selven(?, "apellido")', [busqueda]);
          console.log("Búsqueda por apellido:", busqueda);
          break;
        case "distrito":
          result = await db.query('CALL sp_selven(?, "distrito")', [busqueda]);
          console.log("Búsqueda por distrito:", busqueda);
          break;
        default:
          result = await db.query('CALL sp_selven("", "todos")');
          console.log("Búsqueda predeterminada");
      }
    } else {
      // Listar todos los vendedores
      result = await db.query('CALL sp_selven("", "todos")');
      console.log("Listado completo de vendedores");
    }

    // Inspeccionar estructura del resultado
    console.log("Estructura de resultado:", typeof result);
    console.log("¿Es array?", Array.isArray(result));
    console.log("Longitud del resultado:", result.length);
    
    // Extraer datos de vendedores - los resultados de procedimientos almacenados
    // suelen venir en formato: [[datos], [metadatos]]
    const vendedores = result[0][0];
    console.log("Vendedores encontrados:", vendedores.length);

    // Obtener distritos para el filtro de búsqueda
    const distritosResult = await db.query("CALL sp_distritos()");
    const distritos = distritosResult[0];

    res.render("index", {
      vendedores: vendedores,
      distritos: distritos,
      busqueda: busqueda || "",
      tipo: tipo || "todos",
    });
  } catch (error) {
    console.error("Error al listar vendedores:", error);
    res.status(500).render("index", {
      vendedores: [],
      distritos: [],
      error: `Error al recuperar vendedores: ${error.message}`,
      busqueda: busqueda || "",
      tipo: tipo || "todos",
    });
  }
});

// Formulario de nuevo vendedor
router.get("/nuevo", async (req, res) => {
  try {
    // Obtener la lista de distritos para el formulario
    const [distritos] = await db.query("CALL sp_distritos()");
    res.render("nuevo", { distritos: distritos[0] });
  } catch (error) {
    console.error("Error al obtener distritos:", error);
    res.status(500).send("Error al cargar el formulario");
  }
});

// Crear nuevo vendedor
router.post("/nuevo", async (req, res) => {
  const { nom_ven, apel_ven, id_dis, cel_ven } = req.body;
  try {
    const [result] = await db.query("CALL sp_ingven(?, ?, ?, ?)", [
      nom_ven,
      apel_ven,
      id_dis,
      cel_ven,
    ]);
    res.json({ success: true, message: "Vendedor creado exitosamente" });
  } catch (error) {
    console.error("Error al crear vendedor:", error);
    res.status(500).json({ 
      success: false, 
      message: `Error al crear vendedor: ${error.message}` 
    });
  }
});

// Formulario de edición
router.get("/editar/:id", async (req, res) => {
  try {
    const [vendedorData] = await db.query("CALL sp_busven(?)", [req.params.id]);
    const [distritos] = await db.query("CALL sp_distritos()");
    
    res.render("editar", { 
      vendedor: vendedorData[0][0], 
      distritos: distritos[0] 
    });
  } catch (error) {
    console.error("Error al buscar vendedor:", error);
    res.status(500).send("Error al recuperar vendedor");
  }
});

// Actualizar vendedor
router.post("/editar/:id", async (req, res) => {
  const { nom_ven, apel_ven, id_dis, cel_ven } = req.body;
  const id_ven = req.params.id;
  try {
    await db.query("CALL sp_modven(?, ?, ?, ?, ?)", [
      id_ven,
      nom_ven,
      apel_ven,
      id_dis,
      cel_ven,
    ]);
    res.json({ success: true, message: "Vendedor actualizado exitosamente" });
  } catch (error) {
    console.error("Error al modificar vendedor:", error);
    res.status(500).json({ 
      success: false, 
      message: `Error al modificar vendedor: ${error.message}` 
    });
  }
});

// Eliminar vendedor
router.get("/eliminar/:id", async (req, res) => {
  try {
    await db.query("CALL sp_delven(?)", [req.params.id]);
    res.json({ success: true, message: "Vendedor eliminado exitosamente" });
  } catch (error) {
    console.error("Error al eliminar vendedor:", error);
    res.status(500).json({ 
      success: false, 
      message: `Error al eliminar vendedor: ${error.message}` 
    });
  }
});

// Ruta de prueba para diagnosticar la estructura de resultados
router.get("/test-query", async (req, res) => {
  try {
    // Probar una consulta simple
    const result = await db.query('CALL sp_selven("", "todos")');
    
    // Inspeccionar la estructura completa
    console.log("Tipo de resultado:", typeof result);
    console.log("¿Es array?", Array.isArray(result));
    console.log("Longitud del resultado:", result.length);
    
    // Examinar el primer nivel
    if (result.length > 0) {
      console.log("Tipo del primer elemento:", typeof result[0]);
      console.log("¿Primer elemento es array?", Array.isArray(result[0]));
      
      // Examinar el segundo nivel
      if (Array.isArray(result[0]) && result[0].length > 0) {
        console.log("Tipo del primer elemento del primer array:", typeof result[0][0]);
        console.log("¿Es array?", Array.isArray(result[0][0]));
        
        // Si es un array de objetos, mostrar un ejemplo
        if (Array.isArray(result[0][0]) && result[0][0].length > 0) {
          console.log("Ejemplo de un registro:", result[0][0][0]);
        } else if (typeof result[0][0] === 'object') {
          console.log("Ejemplo de registro:", result[0][0]);
        }
      }
    }
    
    // Intentar diferentes formas de acceder a los datos
    const test1 = result[0];
    const test2 = result[0][0];
    
    res.json({
      message: "Prueba completada, revisa la consola",
      resultLength: result.length,
      test1Length: Array.isArray(test1) ? test1.length : "no es array",
      test2Length: Array.isArray(test2) ? test2.length : "no es array",
      sample1: Array.isArray(test1) && test1.length > 0 ? test1[0] : null,
      sample2: Array.isArray(test2) && test2.length > 0 ? test2[0] : null
    });
  } catch (error) {
    console.error("Error en prueba:", error);
    res.status(500).json({
      error: error.message
    });
  }
});
// Agrega esta ruta para verificar los datos en formato JSON
router.get("/json", async (req, res) => {
  try {
    const result = await db.query('CALL sp_selven("", "todos")');
    res.json({
      result: result,
      level1: result[0],
      level2: result[0][0]
    });
  } catch (error) {
    res.json({ error: error.message });
  }
});
module.exports = router;
