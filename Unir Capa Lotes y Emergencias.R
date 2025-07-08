library(readr)
library(dplyr)
library(openxlsx)
library(sf)

# 1. Leer los datos
lotes <- read_csv("Capa_lotes_WKT.csv")
emergencias <- read.xlsx("00_BD EMERGENCIAS-nuevo-formato.xlsx")

# 2. Unificar emergencias en formato WKT tipo POINT
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

# 3. Añadir columnas faltantes
cols_lotes <- colnames(lotes)
for (col in setdiff(cols_lotes, colnames(puntos))) {
  puntos[[col]] <- NA
}
puntos <- puntos %>% select(all_of(cols_lotes))

# 4. Unir ambos datasets
unificado <- bind_rows(lotes, puntos)

# 5. Limpiar geometrías inválidas (las que tienen NA, espacios vacíos o errores)
unificado <- unificado %>%
  filter(!is.na(geometry_wkt), !grepl("NA", geometry_wkt))

# 6. Convertir a objeto sf
geo <- st_as_sf(unificado, wkt = "geometry_wkt", crs = 4326)

# 7. Exportar a GeoJSON
st_write(geo, "Capa_Lotes_y_Emergencias.geojson", driver = "GeoJSON")

# Exportar CSV
write.csv(geo, "Capa_Lotes_y_Emergencias.csv", row.names = FALSE, 
          sep = ";", dec = ".")
