# MicroservicioEjemplo

Este proyecto implementa un microservicio en .NET 8 con arquitectura basada en contenedores, gestionado mediante Kubernetes y desplegado automáticamente con Helm y ArgoCD. El pipeline de integración y despliegue continuo (CI/CD) está construido con GitHub Actions.

---

## 🚀 Tecnologías Utilizadas

- ✅ [.NET 8 Web API](https://dotnet.microsoft.com)
- ✅ [Docker](https://www.docker.com/)
- ✅ [Kubernetes (local con Docker Desktop)](https://www.docker.com/products/docker-desktop/)
- ✅ [Helm](https://helm.sh/)
- ✅ [ArgoCD](https://argo-cd.readthedocs.io/)
- ✅ [GitHub Actions](https://github.com/features/actions)
- ✅ [GitHub Container Registry (GHCR)](https://ghcr.io)

---

## 📦 Estructura del proyecto


---

## 🧩 FASE 1 – Microservicio Básico

- Proyecto base generado con:
  ```
  dotnet new webapi -n MicroservicioEjemplo --framework net8.0
   ```
  
  Exposición del endpoint:  `/weatherforecast `

## 📦 FASE 2 – Contenedores Docker
Dockerfile basado en .NET 8:
  ```
# Imagen base para ejecuci�n
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 80

# Imagen para compilaci�n
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
  ```

## 🎯 FASE 3 – Helm Chart
Se creó un  `Chart ` de Helm en  `microservicio-chart/ ` que define el  `Deployment `.

- El  `values.yaml ` permite personalizar:

- Nombre de la imagen ( `ghcr.io/wlemus/microservicio-ejemplo `)

- Número de réplicas

- Recursos y etiquetas

## 🚀 FASE 4 – Despliegue con ArgoCD
ArgoCD desplegado en el clúster local (Docker Desktop)

- Se agregó el repositorio Git como fuente de ArgoCD

- Se creó una  `Application ` apuntando al  `Chart ` de Helm

- El despliegue se actualiza automáticamente con cada commit

## 🔄 FASE 5 – CI/CD con GitHub Actions
Pipeline  ` .github/workflows/deploy.yaml  `configurado con:

Build de imagen Docker

Push a  `ghcr.io/wlemus/microservicio-ejemplo:latest `

Login automático con  `GITHUB_TOKEN `
```
name: CI/CD Microservicio

on:
  push:
    branches:
      - master

env:
  IMAGE_NAME: ghcr.io/wlemus/microservicio-ejemplo

jobs:
  build-and-push:
    runs-on: ubuntu-latest

    permissions:
      contents: read
      packages: write

    steps:
      - name: Checkout repo
        uses: actions/checkout@v4

      - name: Log in to GitHub Container Registry
        uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Build Docker image
        run: docker build -t $IMAGE_NAME:latest .

      - name: Push Docker image
        run: docker push $IMAGE_NAME:latest
```
