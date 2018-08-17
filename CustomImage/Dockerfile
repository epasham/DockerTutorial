# image oluşturmak için alttaki komutu kullanınız.
# sudo docker container ls komutu çalıştırıldığında taglarin görğnmesi için
# docker build -t username/image_name:tag_name

# çalıştırmak için 
#sudo docker run -i -t  muratcabuk/customimage:customimage


FROM ubuntu

LABEL Description="This is a custom Docker Image"
LABEL vendor="Murat Cabuk"

RUN apt-get update 
RUN apt-get --yes install nginx
RUN apt-get install --yes wget
RUN apt-get install -my wget gnupg

# nano editlemek için lazım olacak
# systemd ise systemctl ile dotnet web app imizi service olarak kaydedip çalıştırmaya yarayacak.
RUN apt-get install -y nano
RUN apt-get install -y systemd


RUN apt-get install -y --no-install-recommends apt-utils

RUN wget https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb

RUN dpkg -i packages-microsoft-prod.deb

RUN apt-get install apt-transport-https 
RUN apt-get update 
RUN apt-get  -y install dotnet-sdk-2.1

RUN dotnet --version && dotnet --info

# mongodb krulumu yapılacak
# tabii ki bu da mantıklı değil normalde DB nin ayrı bir containerda olması lazım. hatta conrainerlarde çünki mongodb distruted bir DB 
# ve microservice yapısına uygun konfigurasyon için herbir node ayrı containerda olmalı
#resource: https://docs.mongodb.com/manual/tutorial/install-mongodb-on-ubuntu/
#-------------------------------mongodb kurulumu yapılıyor

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 9DA31620334BD75D9DCB49F368818C72E52529D4
RUN echo "deb [ arch=amd64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-4.0.list
RUN apt-get update
RUN apt-get install -y mongodb-org
# buraya container restart olduğunda mongodb yi otomatik başlatacak kod lazım


# redis cache kurulumu
# tabbiki buda mantıksız normalde bununda ayrı bir conrainerda olması lazım
# redis.conf ayarları yapılmış conigurasyon dosyası: system restart olduğunda çalışması için alttaki komut conf dosyasına eklendi
# supervised systemd 
# https://www.digitalocean.com/community/tutorials/how-to-install-and-secure-redis-on-ubuntu-18-04
#------------------------------redis cache kurulumu

RUN apt-get install -y redis-server
COPY redis.conf etc/redis/


# kurulumlar bitikten sonra web sitemizi kopyalıyoruz.
# ----------------------------------------------------koylama kodları gelecek
COPY aspnetapp/bin/Debug/netcoreapp2.1/publish /var/www/aspnetapp 


# daha sonra nginx i proramlıyoruz. amacımız bir web siteyi nginx load balancer yardımıyla tek containerde 2 sayıda yaına vermek
# tabii ki bu mantıklı olmayabilir. container ın kopyasını almak daha mantıklı olabilir ama bu sadece bir ders
# burada DNS (host) aylarına girmiyoruz sadece locakhosttan bir siteyi NGINX load balancer ile 
#default config i editleyip kullanıyoruz (nginx)
# ---------------------------------------------nginx configration dosyalarının kopyalanması ve symbolic link ayarları gelecek

# hata logları için dosylar kopyalanıyor
WORKDIR  /usr/local/var/log
RUN mkdir nginx
WORKDIR  /usr/local/var/log/nginx
RUN touch localhost.error.log 
RUN touch localhost.notice.log 
RUN touch localhost.info.log


WORKDIR  /etc/nginx/
COPY default sites-available/
WORKDIR  /etc/nginx/sites-available
#default site olmasaydı elttaki satırıda eklememiz lazımdı
#RUN ln -sf default /etc/nginx/sites-enabled/default

#The server is setup to forward requests made to http://<serveraddress>:80 on to 
#the ASP.NET Core app running on Kestrel at http://127.0.0.1:5000. However, 
#Nginx isn't set up to manage the Kestrel process. systemd can be used to 
#create a service file to start and monitor the underlying web app. 
#systemd is an init system that provides many powerful features for 
#starting, stopping, and managing processes.

WORKDIR /etc/systemd/
COPY aspnetapp.service system/

#bundan once nginx in de çalıştırılmış olmalı
RUN systemctl enable aspnetapp.service


# source: https://docs.microsoft.com/en-us/aspnet/core/host-and-deploy/linux-nginx?view=aspnetcore-2.1&tabs=aspnetcore2x 
# firewall ayarları
RUN apt-get install ufw
RUN ufw allow 22/tcp
RUN ufw allow 80/tcp
RUN ufw allow 443/tcp

RUN ufw enable


WORKDIR  /


