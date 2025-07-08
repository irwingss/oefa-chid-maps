library(readr)
library(dplyr)
library(openxlsx)
library(sf)

# 1. Leer la base de emergencias
emergencias <- read.xlsx("00_BD EMERGENCIAS-nuevo-formato.xlsx")

# 2. Seleccionar y transformar
puntos <- emergencias %>%
  select(ZONA, Este, Norte, Unidad.Fiscalizable, Administrado) %>%
  rename(
    UNIDAD_FIS = Unidad.Fiscalizable,
    ADMINISTRA = Administrado
  ) %>%
  mutate(
    UF_nombre = UNIDAD_FIS,
    geometry_wkt = paste0("POINT (", Este, " ", Norte, ")")
  ) %>%
  filter(!is.na(Este), !is.na(Norte))  # filtrar coordenadas válidas

# 3. Convertir a objeto sf
geo_puntos <- st_as_sf(puntos, wkt = "geometry_wkt", crs = 4326)

# 4. Exportar como GeoJSON
st_write(geo_puntos, "Emergencias.geojson", driver = "GeoJSON")
