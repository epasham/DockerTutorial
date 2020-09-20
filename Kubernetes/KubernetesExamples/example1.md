dotnet-docker klasöründeki projerleri kullanıyor olacağız. 

Bu klasör https://github.com/dotnet/dotnet-docker adresinden alınmıştır içinde dockerfile da hazırdır. 

Amacımız baştan sona bir deployment örneği gösttermek olacak.

3 tane jenkins görev tanımımız olacak.

1. github üzerinden pull requestlerde jenkins üzerinden otomatik build alacak
2. jenkins üzerinden githubdan alınan kod yine jenkins üzerinden verilen versiyon numarasına göre build alınıp private docker registery ye kaydedilecek
3. private registery üzerindeki herhangi bir image deploy edilecek 




