# Cargar librerías necesarias
library(ggplot2)
library(data.table)

# Directorio donde están los archivos filtrados
filtered_dir <- "./PROJECTE-PT/datasets_filtered/"

# Buscar archivos filtrados
filtered_files <- list.files(path = filtered_dir, pattern = "*_filtered.csv.gz", full.names = TRUE)

# Lista para almacenar los datos
data_list <- list()

# Cargar cada archivo filtrado y añadir a la lista
for (file in filtered_files) {
  data <- fread(file)
  
  # Verificar si la columna BETA existe
  if ("BETA" %in% colnames(data)) {
    # Extraer nombre de cohorte desde el nombre del archivo
    cohort_name <- gsub("_filtered.csv.gz", "", basename(file))
    
    # Agregar columna de cohorte
    data[, Cohort := cohort_name]
    
    # Guardar en la lista
    data_list[[length(data_list) + 1]] <- data[, .(Cohort, BETA)]
  } else {
    warning(paste("La columna BETA no existe en el archivo:", file))
  }
}

# Unir todos los datasets en uno solo
final_data <- rbindlist(data_list)

# Crear el boxplot con ggplot2
p <- ggplot(final_data, aes(x = Cohort, y = BETA, fill = Cohort)) +
  geom_boxplot(outlier.shape = NA, alpha = 0.7) +  # Hace el boxplot más limpio
  geom_jitter(width = 0.2, alpha = 0.3) +  # Agrega puntos individuales con transparencia
  labs(title = "BETA for Cohort",
       x = "Cohort", y = "BETA") +
  theme_classic() +  # Fondo blanco
  theme(axis.text.x = element_text(angle = 45, hjust = 1))  # Rotar etiquetas del eje X

# Guardar el gráfico
ggsave("boxplot_betas_cohortes.png", plot = p, width = 10, height = 6, dpi = 150)

# Mostrar el gráfico
print(p)



