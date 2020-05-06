ARG REPO=mcr.microsoft.com/dotnet/core/aspnet
FROM $REPO:3.1-bionic

ENV REDIS_PASSWORD: password123
ENV ASPNETCORE_ENVIRONMENT: Development

EXPOSE 5005

COPY publish /home/publish

CMD dotnet /home/publish/example1.dll
