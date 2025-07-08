library(readr)
library(dplyr)

# 1. Cargar archivos
lotes <- read_csv("Capa_lotes_WKT.csv") # Asegúrate que el archivo tenga columna "geometry_wkt"

emergencias <- openxlsx::read.xlsx("00_BD EMERGENCIAS-nuevo-formato.xlsx")

# 2. Seleccionar columnas necesarias y renombrar
puntos <- emergencias %>%
  select(ZONA, Este, Norte, Unidad.Fiscalizable, Administrado) %>%
  rename(
    UNIDAD_FIS = Unidad.Fiscalizable,
    ADMINISTRA = Administrado
  ) %>%
  mutate(
    UF_nombre = UNIDAD_FIS,
    geometry_wkt = paste0("POINT (", Este, " ", Norte, ")")
  )

# 3. Añadir columnas vacías que existen en el archivo de lotes pero no en puntos
cols_lotes <- colnames(lotes)
cols_puntos <- colnames(puntos)

# Añadir columnas faltantes como NA
for (col in setdiff(cols_lotes, cols_puntos)) {
  puntos[[col]] <- NA
}

# Reordenar columnas
puntos <- puntos %>% select(all_of(cols_lotes))

# 4. Unir ambos datasets
unificado <- bind_rows(lotes, puntos)

# 5. Guardar como CSV
write_csv(unificado, "Capa_Lotes_y_Emergencias_WKT.csv")
