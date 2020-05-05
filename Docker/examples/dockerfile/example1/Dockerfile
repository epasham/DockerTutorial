ARG REPO=mcr.microsoft.com/dotnet/core/aspnet
FROM $REPO:3.1-bionic

EXPOSE 5005

COPY publish /home/publish

CMD dotnet /home/publish/example1.dll
