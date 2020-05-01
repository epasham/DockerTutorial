# build aşaması için ARG kulanmak, build bitti runtime geçtiğimizde ise ENV çalışıyor.
# Alttaki örneklerde bu şekilde

# The scope of this ARG instruction comes into picture only after it is declared in the Dockerfile. 
# it goes out of scope once the build is complete. 
#So the scope of the ARG instruction is limited to build stage.
ARG CHECK_VERSION=Latest
ARG UBUNTU_VERSION=16.04

# $UBUNTU_VERSION Dockerfile build edilirken girilecek. boş geçilirse default değer yani 16.04 geçilmiş olacak.
# Yukarıdaki ARG veriesi alında okunmuş oluyor
FROM ubuntu:18.04




# ENV instruction sets the environment variable and this sets the environment for the subsequent build instructions.
# burası klasik anlmada asp.net de kod yazarken envrionment verilerini okurken kullandığımız bölüm.
# asp.net core dosyamızda PORT adında bir environment verisini okuyorsak alttaki Port verisi alınmış olacak.
# burada $PORT ARG verisi olarka comut satısından alınmış oldu
# ilk ENV yani HOST_ENV ise direkt girilmiş oldu.

# build the image (env dosyasıyla veriyi aktarıyoruz)
#docker build -t nodejs-server-env -f Dockerfile.env .

#run the container
#docker run -d --name node-server-env -p 3000:3000 nodejs-server-env

# yada  --env PORT=3070 parametresiyle veriyi geçirebiliriz.
# yada ARG olarak alıp ENV e parametre olarka geçebiliriz. yukarrıda mesela 
# docker run -d --name node-server-env1 --env PORT=3070 -p 3070:3070 nodejs-server-env

# eğer export PORT="3000"  gibi bir şekilde runtime da veri girildiyse rapametre olarka terminalden vermeye gerek yok. 


# örneğin HOST_ENV i test ortamı için terminalden ya da env dosyasınden test olarka girebiliriz. Ancak default u production dır. 
# yada HOST_ENV bosta bıraklabilir. runtime de Windows ya da linuz envronment veisi girildiyse okur. test oraı için ENV doldurulur.
ENV HOST_ENV=production
# POST eğer terminalde girilirse orada yazn port atanacak
ENV PORT_ENV=3000

WORKDIR /home

# unutma her bir RUN bir layer oluşturuyor gerekli değilse tek komut yapılmalı
# RUN kısmı sade build aşamaında çalıştığı için ARG lar çalışcaktır. Amcak CMD kısımlarında ENV ler çalışabilir.
RUN echo "Girilen veriyon check versiyonundan daha büyük $UBUNTU_VERSION > $CHECK_VERSION"
RUN echo "Girilen HOST_ENV $HOST_ENV"
RUN echo "Girilen PORT $PORT_ENV"
RUN mkdir project
RUN mkdir temp
RUN mkdir myvolume



WORKDIR /home/project
COPY entrypoint.sh entrypoint.sh
RUN chmod +x entrypoint.sh


# WORKDIR temp olara ayarlandığı için orada gidecek. 
# ancak biz isteseydik örneğin /temp/copyfile.txt gibi açıkçada belirtebilirdik.
COPY copyfile.txt copyfile.txt

ENV VOLUME_PATH_ENV=/home/temp

#eğer ENV boş gelirse hostun tmp klasörünü contaier altındaki tmp e bağlamış olacak.
# burada pek tavsiye edilmesede bind mount yapmış olduk
VOLUME $VOLUME_PATH:/home/myvolume

# env dosyasında ataması yapılıyor aslında ancak hiçbirşey atanmadıysa default değer atamk için myvolume2 yazıldı
ENV VOLUME_NAME_ENV=myvolume2
VOLUME $VOLUME_NAME_ENV:/home/myvolume



# Aynı dosyayı bu sefer diğer containerla paylaşmak için volume a koyuyoruz.
COPY copyfile.txt /home/myvolume/copyfile.txt




# executable shell de bırakıldığı için CMD kısmında echo ile devam edebildik
ENTRYPOINT [ "/home/project/entrypoint.sh" ]



# Bir dockerfile sadece tek bir CMD olabilir. sadece ENV burada okunabilir. ARG okunamaz
# Entrypoint kullanılmaycaksa aşağıdaki gibide yazlabilir
# CMD ["bin/bash", "echo test"]

# ekrana yazar yazmaz kapanacak demektir. buradan yazmak yerine entrypoint de environmen variable ı okuyup ekrana yazdırdık.
# CMD ["echo",  "Girilen HOST_ENV $(HOST_ENV)"] \
#     ["echo", "Girilen PORT_ENV $(PORT_ENV)"]






#The following ARG variables are set automatically:

#TARGETPLATFORM - platform of the build result. Eg linux/amd64, linux/arm/v7, windows/amd64.
#TARGETOS - OS component of TARGETPLATFORM
#TARGETARCH - architecture component of TARGETPLATFORM
#TARGETVARIANT - variant component of TARGETPLATFORM
#BUILDPLATFORM - platform of the node performing the build.
#BUILDOS - OS component of BUILDPLATFORM
#BUILDARCH - architecture component of BUILDPLATFORM
#BUILDVARIANT - variant component of BUILDPLATFORM

