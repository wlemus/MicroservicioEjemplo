# Imagen base para ejecución
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 80

# Imagen para compilación
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copiar todos los archivos del proyecto al contenedor
COPY . .

# Restaurar paquetes NuGet
RUN dotnet restore

# Publicar el proyecto
RUN dotnet publish -c Release -o /out

# Imagen final para ejecutar la app publicada
FROM base AS final
WORKDIR /app
COPY --from=build /out .
ENTRYPOINT ["dotnet", "MicroservicioEjemplo.dll"]