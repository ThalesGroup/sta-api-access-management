

FROM mcr.microsoft.com/dotnet/core/sdk:3.1 AS build
WORKDIR /src
COPY . .

WORKDIR /src/src/Store
RUN dotnet restore "Store.csproj"
RUN dotnet build "Store.csproj" -c Release -o /app/build
RUN dotnet publish "Store.csproj" -c Release -o /app/publish

FROM mcr.microsoft.com/dotnet/core/aspnet:3.1

RUN useradd serviceRunner
USER serviceRunner 

WORKDIR /app

COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "Store.dll"]