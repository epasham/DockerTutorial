ARG REPO=mcr.microsoft.com/dotnet/core/runtime
FROM $REPO:3.1-bionic

COPY publish /home/publish

CMD dotnet run /home/publish/
