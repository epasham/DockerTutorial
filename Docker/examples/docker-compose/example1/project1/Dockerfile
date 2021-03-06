# build aşaması için ARG kulanmak, build bitti runtime geçtiğimizde ise ENV çalışıyor.
# Alttaki örneklerde bu şekilde

# FROM tagınden önce çalıştırıan tün ARG lar FROM tagından sonra kaybolur buna dikkat etmek lazım.
# sebebi ise multistage image lardan dolayı her bir from onceki fromdan sadce outputu alır geri kalan herşey kaybolur.

# The scope of this ARG instruction comes into picture only after it is declared in the Dockerfile. 
# it goes out of scope once the build is complete. 
#So the scope of the ARG instruction is limited to build stage.
ARG CHECK_VERSION=Latest
ARG UBUNTU_VERSION=16.04


# $UBUNTU_VERSION Dockerfile build edilirken girilecek. boş geçilirse default değer yani 16.04 geçilmiş olacak.
# Yukarıdaki ARG veriesi alında okunmuş oluyor
FROM ubuntu:18.04 as MyUbuntu 
# as dan sonraki MyUbuntu multistage build için grekli
# 1. yöntemde buradaki fromdan altta yazılacak diğer from a output çıkartılabilir.
# 2. yontem test, prod uat gibi ortamların stage leri ayrı ayr ıyapılabilir burada ve build işleminde parametre lark geçirilebilir.
# 3 .yönten örneğin window için ayrı bir from yazılabilir bud ayrı stage olur
# 4. yöntem cmposite yapılabilir 

ARG AFTER_FROM="bu ARG FROM tagindan sonra geldiği için göründü"


# ENV instruction sets the environment variable and this sets the environment for the subsequent build instructions.
# burası klasik anlmada asp.net de kod yazarken envrionment verilerini okurken kullandığımız bölüm.
# asp.net core dosyamızda PORT adında bir environment verisini okuyorsak alttaki Port verisi alınmış olacak.
# burada $PORT ARG verisi olarka comut satısından alınmış oldu
# ilk ENV yani HOST_ENV ise direkt girilmiş oldu.

# build the image (env dosyasıyla veriyi aktarıyoruz)
# docker build -t nodejs-server-env -f Dockerfile.env .

# run the container
# docker run -d --name node-server-env -p 3000:3000 nodejs-server-env

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
RUN echo " $UBUNTU_VERSION ARG değeri görüldüğü gibi gelemdi sebebi FRO dan önce tanımlanması"
RUN echo "AFTER_FROM ARG değeri = $AFTER_FROM"
RUN echo "Girilen HOST_ENV $HOST_ENV, değer görünmedi çünki ENV değerleri Runtime da görülebilir."
RUN echo "Girilen PORT $PORT_ENV, değer görünmedi çünki ENV değerleri Runtime da görülebilir."
RUN mkdir project
RUN mkdir temp
RUN mkdir myvolume



WORKDIR /home/project
COPY entrypoint.sh entrypoint.sh
RUN chmod +x entrypoint.sh


# WORKDIR temp olara ayarlandığı için orada gidecek. 
# ancak biz isteseydik örneğin /temp/copyfile.txt gibi açıkçada belirtebilirdik.
COPY copyfile.txt copyfile.txt


# burada aslında anonimous bir volume oluşturmuş oacağız host üzerinde
# böylece /home/temp e konulan veriler hosts yazılmış olacak
VOLUME /home/temp

# buraya koyduğumuz dosylar yok olacak yani mount işleminden sonra göremeyeceğiz.
# çünki build aşamasında dosyaları koyuyoruz ancak volume tanımlama işi Runtime da oluyor bundan dolayı 
RUN touch /home/temp/temp.txt


# Aynı dosyayı bu sefer diğer containerla paylaşmak için volume a koyuyoruz.
# bu foldersın yanı /home/myvolume un volume olar bağlanması laız bunun içinde docker cli da named voume tanımlanmalı.
# project2 buradan veri okuyacak
# öemmli bir konu şu cli üzerinden mount edildiğinde build aşamasında konan doylar kaybolmaz. örneğin burasi.
# ancak yıkarıda temp olarak dockerfile içinden oluşturup mount ettiğimiz temp klasörüne koyduklarımız yok olacak. 
#
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

