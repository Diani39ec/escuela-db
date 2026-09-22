# 🏫 Escuela DB — Base de datos MySQL · Por Diana Trujillo

Base de datos del área **escuela**: alumnos, maestros, materias, grupos, inscripciones y calificaciones (3 parciales de 0–10), con vista de promedios.

## Estructura
```
escuela-db/
├── escuela_db.sql  · Esquema + vista + datos de ejemplo
└── README.md
```

## Tablas `escuela_db`
| Tabla | Guarda | Reglas |
|---|---|---|
| `alumnos` | nombre, email único, fecha de nacimiento, grado | — |
| `maestros` | nombre, email único, especialidad | — |
| `materias` | nombre, código único, créditos | — |
| `grupos` | materia + maestro + ciclo + horario | FK → materias, maestros |
| `inscripciones` | alumno + grupo | Única (un alumno, un grupo) · FK cascade |
| `calificaciones` | inscripción + parcial (1–3) + nota 0–10 | Única por parcial · FK cascade |
| `vista_promedios` | promedio y nº de parciales por alumno y materia | vista |

## Instalación y consultas
```powershell
Get-Content escuela_db.sql -Raw | mysql -u root
```
```sql
USE escuela_db;
SELECT * FROM vista_promedios;
SELECT * FROM vista_promedios WHERE promedio < 6; -- reprobados
```

Hecho por **Diana Trujillo** ✨
