FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/sdk:10.0 AS build

ARG BUILDPLATFORM
ARG TARGETPLATFORM
ARG TARGETARCH

RUN echo "Build platform: ${BUILDPLATFORM}" \
    && echo "Target platform: ${TARGETPLATFORM}" \
    && echo "Docker architecture: ${TARGETARCH}"

WORKDIR /source

COPY Worker.csproj ./

RUN case "${TARGETARCH}" in \
        amd64) echo "linux-x64" > /tmp/runtime-id ;; \
        arm64) echo "linux-arm64" > /tmp/runtime-id ;; \
        *) \
            echo "Unsupported architecture: ${TARGETARCH}"; \
            exit 1 ;; \
    esac \
    && echo "Selected runtime: $(cat /tmp/runtime-id)"

RUN dotnet restore Worker.csproj \
    --runtime "$(cat /tmp/runtime-id)"

COPY . .

RUN dotnet publish Worker.csproj \
    --configuration Release \
    --output /app \
    --runtime "$(cat /tmp/runtime-id)" \
    --self-contained false \
    --no-restore

FROM mcr.microsoft.com/dotnet/runtime:10.0 AS runtime

WORKDIR /app

COPY --from=build /app ./

ENTRYPOINT ["dotnet", "Worker.dll"]
