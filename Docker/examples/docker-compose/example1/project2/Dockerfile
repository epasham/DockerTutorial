# burada dikkat edilmesi gereken konu diğer container ın hazır olduğundan emin olmak
# bunu compose ile çalıştıracağımız için orada depends diye bir tag var oraylada çözülebilir. onuda yazacağız 
# ancak burada da test amaçlı HEALTHCEK komutunu çalıştıracağız.


FROM ubuntu:18.04

RUN apt update
RUN apt install -y iputils-ping



# burayı alttaki gibi kulanırsak bu imagge için anonimous bir vomume oluşur
# bizim amacımız ise project1 için dcocker cli ile oluşturulup container run edilirken mount edilen
# myvolume adındaki volume bu proje içinde mount edeceğiz ki içindeki doyayı okuyup ekrana yaabilşelim
# VOLUME /home/myvolume

COPY entrypoint.sh /home/entrypoint.sh

RUN chmod +x /home/entrypoint.sh

# interval : iki deneme arasında geçecek süre
# timeout : healthcheck komutunun timeout süresi
# start-period : healthchek in hazırlanma süresi, yani ayağa kalkma süresi. 
#                bu süre zarfında healthcheck başlamazsa hata olarka kabül edilmez.
# retries : kaç kere deneyecek
# https://www.alibabacloud.com/help/doc-detail/58588.htm
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 CMD ping project1

ENTRYPOINT ["/home/entrypoint.sh"]



