#!/usr/bin/env bash
#
# Generated by: https://github.com/swagger-api/swagger-codegen.git
#

dotnet restore src/Store/ && \
    dotnet build src/Store/ && \
    echo "Now, run the following to start the project: dotnet run -p src/Store/Store.csproj --launch-profile web"
