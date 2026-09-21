# 🏫 Escuela DB — Base de datos MySQL

Base de datos del área **escuela**: alumnos, maestros, materias, grupos, inscripciones y calificaciones.

## Importar (Laragon / MySQL)
```powershell
Get-Content escuela_db.sql -Raw | mysql -u root
```

## Tablas
| Tabla | Descripción |
|---|---|
| `alumnos` | Datos del alumno + grado |
| `maestros` | Datos del maestro + especialidad |
| `materias` | Catálogo con código único |
| `grupos` | Materia + maestro + ciclo |
| `inscripciones` | Alumno ↔ grupo (única) |
| `calificaciones` | 3 parciales (0–10) por inscripción |
| `vista_promedios` | Promedio por alumno y materia |

## Consultas útiles
```sql
USE escuela_db;
SELECT * FROM vista_promedios;
SELECT * FROM vista_promedios WHERE promedio < 6; -- reprobados
```
