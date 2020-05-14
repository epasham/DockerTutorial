docker secret örneği

compose file da postgre için secret kullanılıyor ancak unutulmamalı secret in daha önce oluşturulması gerkiyor.

zaten composefile içinde secret yaratmak ne derece matıklı tartışılır. 

bu nedenle öncelikle secret oluşturuyoruz

```
echo "mypass" | docker secret create psql_password - 
```

daha sonra build gerktirmediği için direk olarak docker stack ile deploy ediyoruz.

```
docker stack deploy -c dcoker-compose.yml drupal
```