# Basic Installation
### Create a Dockerfile for an ASP.NET Core application

1. Create a Dockerfile in your project folder.

this file includes also build task.

```
FROM microsoft/dotnet:sdk AS build-env
WORKDIR /app

# Copy csproj and restore as distinct layers
COPY *.csproj ./
RUN dotnet restore

# Copy everything else and build
COPY . ./
RUN dotnet publish -c Release -o out

# Build runtime image
FROM microsoft/dotnet:aspnetcore-runtime
WORKDIR /app
COPY --from=build-env /app/out .
ENTRYPOINT ["dotnet", "aspnetapp.dll"]
```

2. Create a .dockerignore file and add following lines into it

```
bin\
obj\
```

### Build and run the Docker image

```
$ docker build -t aspnetapp .
$ docker run -d -p 8080:80 --name myapp aspnetapp
```

### View the web page running from a container
```
Run docker inspect -f "{{ .NetworkSettings.Networks.nat.IPAddress }}" myapp

```

Copy the container ip address and paste into your browser. (For example, 127.0.0.1)








