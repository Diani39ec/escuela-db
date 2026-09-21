-- =====================================================
-- Escuela · Base de datos MySQL 8+
-- Base: escuela_db (utf8mb4)
-- Tablas: alumnos, maestros, materias,
--         grupos, inscripciones, calificaciones
-- =====================================================
CREATE DATABASE IF NOT EXISTS escuela_db
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE escuela_db;

-- ---------- 1. Alumnos ----------
CREATE TABLE IF NOT EXISTS alumnos (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(80) NOT NULL,
  apellido VARCHAR(80) NOT NULL,
  email VARCHAR(150) NOT NULL UNIQUE,
  fecha_nac DATE NULL,
  grado VARCHAR(20) NOT NULL DEFAULT '1ro',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ---------- 2. Maestros ----------
CREATE TABLE IF NOT EXISTS maestros (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(80) NOT NULL,
  apellido VARCHAR(80) NOT NULL,
  email VARCHAR(150) NOT NULL UNIQUE,
  especialidad VARCHAR(100) NOT NULL
) ENGINE=InnoDB;

-- ---------- 3. Materias ----------
CREATE TABLE IF NOT EXISTS materias (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  codigo VARCHAR(20) NOT NULL UNIQUE,
  creditos INT NOT NULL DEFAULT 5
) ENGINE=InnoDB;

-- ---------- 4. Grupos (materia + maestro + ciclo) ----------
CREATE TABLE IF NOT EXISTS grupos (
  id INT AUTO_INCREMENT PRIMARY KEY,
  materia_id INT NOT NULL,
  maestro_id INT NOT NULL,
  ciclo VARCHAR(20) NOT NULL DEFAULT '2026-1',
  horario VARCHAR(50) NULL,
  CONSTRAINT fk_grupo_materia FOREIGN KEY (materia_id)
    REFERENCES materias(id) ON DELETE CASCADE,
  CONSTRAINT fk_grupo_maestro FOREIGN KEY (maestro_id)
    REFERENCES maestros(id) ON DELETE CASCADE,
  INDEX idx_grupo_ciclo (ciclo)
) ENGINE=InnoDB;

-- ---------- 5. Inscripciones ----------
CREATE TABLE IF NOT EXISTS inscripciones (
  id INT AUTO_INCREMENT PRIMARY KEY,
  alumno_id INT NOT NULL,
  grupo_id INT NOT NULL,
  fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_alumno_grupo (alumno_id, grupo_id),
  CONSTRAINT fk_ins_alumno FOREIGN KEY (alumno_id)
    REFERENCES alumnos(id) ON DELETE CASCADE,
  CONSTRAINT fk_ins_grupo FOREIGN KEY (grupo_id)
    REFERENCES grupos(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ---------- 6. Calificaciones (3 parciales por inscripción) ----------
CREATE TABLE IF NOT EXISTS calificaciones (
  id INT AUTO_INCREMENT PRIMARY KEY,
  inscripcion_id INT NOT NULL,
  parcial TINYINT NOT NULL CHECK (parcial BETWEEN 1 AND 3),
  calificacion DECIMAL(4,2) NOT NULL CHECK (calificacion BETWEEN 0 AND 10),
  fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_ins_parcial (inscripcion_id, parcial),
  CONSTRAINT fk_cal_ins FOREIGN KEY (inscripcion_id)
    REFERENCES inscripciones(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ---------- Vista: promedio por alumno y grupo ----------
CREATE OR REPLACE VIEW vista_promedios AS
SELECT a.id AS alumno_id, CONCAT(a.nombre,' ',a.apellido) AS alumno,
       m.nombre AS materia, g.ciclo,
       ROUND(AVG(c.calificacion),2) AS promedio,
       COUNT(c.id) AS parciales
FROM alumnos a
JOIN inscripciones i ON i.alumno_id = a.id
JOIN grupos g ON g.id = i.grupo_id
JOIN materias m ON m.id = g.materia_id
LEFT JOIN calificaciones c ON c.inscripcion_id = i.id
GROUP BY a.id, m.nombre, g.ciclo;

-- =====================================================
-- Datos de ejemplo
-- =====================================================
INSERT INTO alumnos (nombre, apellido, email, fecha_nac, grado) VALUES
('Ana','Garcia','ana@escuela.mx','2012-03-10','5to'),
('Luis','Perez','luis@escuela.mx','2011-07-22','6to'),
('Sofia','Ruiz','sofia@escuela.mx','2012-11-05','5to')
ON DUPLICATE KEY UPDATE nombre = VALUES(nombre);

INSERT INTO maestros (nombre, apellido, email, especialidad) VALUES
('Carlos','Mendoza','carlos@escuela.mx','Matematicas'),
('Laura','Torres','laura@escuela.mx','Espanol')
ON DUPLICATE KEY UPDATE nombre = VALUES(nombre);

INSERT INTO materias (nombre, codigo, creditos) VALUES
('Matematicas','MAT-101',6),
('Espanol','ESP-101',5),
('Ciencias','CIE-101',5)
ON DUPLICATE KEY UPDATE nombre = VALUES(nombre);

INSERT INTO grupos (materia_id, maestro_id, ciclo, horario) VALUES
((SELECT id FROM materias WHERE codigo='MAT-101'),(SELECT id FROM maestros WHERE email='carlos@escuela.mx'),'2026-1','Lun-Mie 9:00'),
((SELECT id FROM materias WHERE codigo='ESP-101'),(SELECT id FROM maestros WHERE email='laura@escuela.mx'),'2026-1','Mar-Jue 10:00');

INSERT IGNORE INTO inscripciones (alumno_id, grupo_id) VALUES
((SELECT id FROM alumnos WHERE email='ana@escuela.mx'), 1),
((SELECT id FROM alumnos WHERE email='luis@escuela.mx'), 1),
((SELECT id FROM alumnos WHERE email='sofia@escuela.mx'), 2),
((SELECT id FROM alumnos WHERE email='ana@escuela.mx'), 2);

INSERT INTO calificaciones (inscripcion_id, parcial, calificacion) VALUES
(1,1,9.5),(1,2,8.0),(1,3,9.0),
(2,1,7.0),(2,2,7.5),(2,3,8.0),
(3,1,10.0),(3,2,9.5),(4,1,8.5)
ON DUPLICATE KEY UPDATE calificacion = VALUES(calificacion);
