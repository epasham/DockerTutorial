Gizli tutulması gereken verilern şifrelenmesi çin kubernetes secret vault sunmaktadır. bunun için encryption config dosyası oluşturmamız gerekiyor. Daha sonra bu dosyayı kullanıyor olacağız.

https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data/


Key i linux de oluşturmanın için aşağıdaki komutu kullanabilirsiniz.


```
ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)
```

windows için build-in gelen certutil aracı kullanılabilir. ben bunun üzerinden gösteriyor olacağım. yada internetten farklı araçlarda kullanılabilir.

Bu komutu kullanabilmek için bir dosyaya ihtiyacımız olacak. içinde rastgele 32 karakterden oluşan bir dosya. bunu base64 ile çevirip bir dosyaya yazıyor olacağız. 

```
certutil -encode in.txt out.txt
```

out.txt doosyasındaki base64 encoded metni alıyoruz : TUlJRW93SUJBQUtDQVFFQXp4aWs4NE03eDNiNnJUY3

Ben ileride de açcağımız yaml dosyaları için files klsörü altına yaml adında bir klasör açarak bu klasör içinde oluştuyor olcağım yaml dosyasını. 

encryption-config.yaml adındaki bir dosyayı yaml klasörüne oluşturup alttki kısmı içine kopyalıyoruz.

```
kind: EncryptionConfig
apiVersion: v1
resources:
  - resources:
      - secrets
    providers:
      - aescbc:
          keys:
            - name: key1
              secret: TUlJRW93SUJBQUtDQVFFQXp4aWs4NE03eDNiNnJUY3I=
      - identity: {}
```

Daha sonra yaml klasörünü master node lara (kaynakların bazılarında bu node lara controller da deniyor) kopyalıyoruz. 

Şimdiye kadar şunları yaptık

- alyapı ve internet ayarlarını yaptık
- sertifikaları oluşturduk
- kubeconfig dosyalarını oluşturduk
- ve bütün sertifika, kubeconfig ve secret key leri sunuculara kopyaladık

