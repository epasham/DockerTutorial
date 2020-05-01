# burada dikkat edilmesi gereken konu diğer container ın hazır olduğundan emin olmak
# bunu compose ile çalıştıracağımız için orada depends diye bir tag var oraylada çözülebilir. onuda yazacağız 
# ancak burada da test amaçlı HEALTHCEK komutunu çalıştıracağız.


FROM ubuntu:18.04

RUN apt update
RUN apt install -y iputils-ping

VOLUME myvolume:/home/myvolume



# interval : iki deneme arasında geçecek süre
# timeout : healthcheck komutunun timeout süresi
# start-period : healthchek in hazırlanma süresi, yani ayağa kalkma süresi. 
#                bu süre zarfında healthcheck başlamazsa hata olarka kabül edilmez.
# retries : kaç kere deneyecek
# https://www.alibabacloud.com/help/doc-detail/58588.htm
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 CMD ping project1


# ekrana yazar yazmaz kapanacak demektir.
CMD cat /home/myvolume/copyfile.txt

ENTRYPOINT ["/bin/bash"]

