-- Create distrito table
CREATE TABLE distrito (
  id_dis INT(11) NOT NULL AUTO_INCREMENT,
  nom_dis VARCHAR(50) NOT NULL,
  PRIMARY KEY (id_dis)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Insert some sample districts
INSERT INTO distrito (nom_dis) VALUES
('San Isidro'),
('Miraflores'),
('San Borja'),
('Surco'),
('La Molina');

-- Modify vendedor table to add id_dis foreign key
ALTER TABLE vendedor ADD COLUMN id_dis INT(11) NOT NULL DEFAULT 1;
ALTER TABLE vendedor ADD CONSTRAINT fk_vendedor_distrito 
FOREIGN KEY (id_dis) REFERENCES distrito(id_dis);

-- Update existing records with default district
UPDATE vendedor SET id_dis = 1;

-- Update the stored procedures

-- Modify sp_busven to include district info
DROP PROCEDURE IF EXISTS sp_busven;
DELIMITER $$
CREATE PROCEDURE sp_busven (IN p_id_ven INT)
BEGIN
  SELECT v.*, d.nom_dis 
  FROM vendedor v
  JOIN distrito d ON v.id_dis = d.id_dis
  WHERE v.id_ven = p_id_ven;
  
  IF ROW_COUNT() = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Vendedor no encontrado';
  END IF;
END$$
DELIMITER ;

-- Modify sp_ingven to include district
DROP PROCEDURE IF EXISTS sp_ingven;
DELIMITER $$
CREATE PROCEDURE sp_ingven (
  IN p_nom_ven VARCHAR(25), 
  IN p_apel_ven VARCHAR(25),
  IN p_id_dis INT,
  IN p_cel_ven CHAR(9)
)
BEGIN
  IF p_nom_ven IS NULL OR p_nom_ven = '' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El nombre del vendedor no puede estar vacío';
  END IF;
  IF p_apel_ven IS NULL OR p_apel_ven = '' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El apellido del vendedor no puede estar vacío';
  END IF;
  IF p_id_dis IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El distrito no puede estar vacío';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM distrito WHERE id_dis = p_id_dis) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El distrito seleccionado no existe';
  END IF;
  IF p_cel_ven IS NULL OR p_cel_ven = '' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El número de celular no puede estar vacío';
  END IF;
  IF LENGTH(p_cel_ven) != 9 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El número de celular debe tener 9 dígitos';
  END IF;
  
  INSERT INTO vendedor (nom_ven, apel_ven, id_dis, cel_ven)
  VALUES (p_nom_ven, p_apel_ven, p_id_dis, p_cel_ven);
  
  SELECT LAST_INSERT_ID() AS nuevo_id_vendedor;
END$$
DELIMITER ;

-- Modify sp_modven to include district
DROP PROCEDURE IF EXISTS sp_modven;
DELIMITER $$
CREATE PROCEDURE sp_modven (
  IN p_id_ven INT, 
  IN p_nom_ven VARCHAR(25), 
  IN p_apel_ven VARCHAR(25),
  IN p_id_dis INT,
  IN p_cel_ven CHAR(9)
)
BEGIN
  IF NOT EXISTS (SELECT 1 FROM vendedor WHERE id_ven = p_id_ven) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El vendedor no existe';
  END IF;
  IF p_nom_ven IS NULL OR p_nom_ven = '' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El nombre no puede estar vacío';
  END IF;
  IF p_apel_ven IS NULL OR p_apel_ven = '' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El apellido no puede estar vacío';
  END IF;
  IF p_id_dis IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El distrito no puede estar vacío';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM distrito WHERE id_dis = p_id_dis) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El distrito seleccionado no existe';
  END IF;
  IF p_cel_ven IS NULL OR p_cel_ven = '' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El celular no puede estar vacío';
  END IF;
  IF LENGTH(p_cel_ven) != 9 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El celular debe tener 9 dígitos';
  END IF;
  
  UPDATE vendedor
  SET nom_ven = p_nom_ven,
      apel_ven = p_apel_ven,
      id_dis = p_id_dis,
      cel_ven = p_cel_ven
  WHERE id_ven = p_id_ven;
  
  SELECT ROW_COUNT() AS filas_actualizadas;
END$$
DELIMITER ;

-- Modify sp_selven to include district info
DROP PROCEDURE IF EXISTS sp_selven;
DELIMITER $$
CREATE PROCEDURE sp_selven (
  IN p_filtro VARCHAR(50),
  IN p_tipo_filtro VARCHAR(20)
)
BEGIN
  IF p_tipo_filtro = 'id' THEN
    SELECT v.*, d.nom_dis 
    FROM vendedor v
    JOIN distrito d ON v.id_dis = d.id_dis
    WHERE v.id_ven = CAST(p_filtro AS UNSIGNED);
  ELSEIF p_tipo_filtro = 'nombre' THEN
    SELECT v.*, d.nom_dis 
    FROM vendedor v
    JOIN distrito d ON v.id_dis = d.id_dis
    WHERE v.nom_ven LIKE CONCAT('%', p_filtro, '%');
  ELSEIF p_tipo_filtro = 'apellido' THEN
    SELECT v.*, d.nom_dis 
    FROM vendedor v
    JOIN distrito d ON v.id_dis = d.id_dis
    WHERE v.apel_ven LIKE CONCAT('%', p_filtro, '%');
  ELSEIF p_tipo_filtro = 'distrito' THEN
    SELECT v.*, d.nom_dis 
    FROM vendedor v
    JOIN distrito d ON v.id_dis = d.id_dis
    WHERE d.nom_dis LIKE CONCAT('%', p_filtro, '%');
  ELSEIF p_tipo_filtro = 'todos' THEN
    SELECT v.*, d.nom_dis 
    FROM vendedor v
    JOIN distrito d ON v.id_dis = d.id_dis;
  ELSE
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Tipo de filtro no válido';
  END IF;
END$$
DELIMITER ;

-- Add a new stored procedure to get all districts
DELIMITER $$
CREATE PROCEDURE sp_distritos ()
BEGIN
  SELECT * FROM distrito ORDER BY nom_dis;
END$$
DELIMITER ;