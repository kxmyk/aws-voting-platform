FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/sdk:7.0 AS build

ARG BUILDPLATFORM
ARG TARGETPLATFORM
ARG TARGETARCH

RUN echo "Build platform: ${BUILDPLATFORM}" \
    && echo "Target platform: ${TARGETPLATFORM}" \
    && echo "Docker target architecture: ${TARGETARCH}"

WORKDIR /source

COPY Worker.csproj ./

RUN case "${TARGETARCH}" in \
        amd64) RID="linux-x64" ;; \
        arm64) RID="linux-arm64" ;; \
        *) \
            echo "Unsupported target architecture: ${TARGETARCH}"; \
            exit 1 ;; \
    esac \
    && echo "Restoring project for runtime: ${RID}" \
    && dotnet restore Worker.csproj \
        --runtime "${RID}"

COPY . .

RUN case "${TARGETARCH}" in \
        amd64) RID="linux-x64" ;; \
        arm64) RID="linux-arm64" ;; \
        *) \
            echo "Unsupported target architecture: ${TARGETARCH}"; \
            exit 1 ;; \
    esac \
    && echo "Publishing project for runtime: ${RID}" \
    && dotnet publish Worker.csproj \
        --configuration Release \
        --output /app \
        --runtime "${RID}" \
        --self-contained false \
        --no-restore

FROM mcr.microsoft.com/dotnet/runtime:7.0 AS runtime

WORKDIR /app

COPY --from=build /app ./

ENTRYPOINT ["dotnet", "Worker.dll"]
