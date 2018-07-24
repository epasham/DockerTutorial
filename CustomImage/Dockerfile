FROM ubuntu

LABEL Description="This is a custom Docker Image"

RUN apt-get update && apt-get --yes install nginx && apt-get install --yes wget

RUN apt-get install -y --no-install-recommends apt-utils

RUN apt-get wget -y https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb

RUN dpkg -i packages-microsoft-prod.deb

RUN apt-get install apt-transport-https && apt-get update && apt-get install dotnet-sdk-2.1

RUN dotnet --version && dotnet --info