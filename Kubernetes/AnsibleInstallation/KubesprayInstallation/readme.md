#### Sistem Altyapı

Sistemi Azure üzerinde kullanıyor olacağız. 

Toplamda 4 sunucu kullanacağız.Master,worker ve etcd nodlarının hepsini aynı sınuculara kuruyor olacağız.  

- Load Balancer: 1 adet düşük bir bilgisayar. Nginx kurulacak. ayrıca nfs diskini de buraya kuracağız.
- Master Node: 3 adet 
- Worker Node: 3 adet
- Etcd Node: 3 adet


ilgili ortamı Ansible Cloud Modullerini kullanarak Azure'da oluşturacağız.

Bnun için gerekli dosyları azure-ansible klasöründe bulabilirsiniz.

Ansible Azure Detaylartı İçin
- [Guide](https://docs.ansible.com/ansible/latest/scenario_guides/guide_azure.html)
- [Ansible Azure Modulleri için](https://docs.ansible.com/ansible/latest/modules/list_of_cloud_modules.html#azure)
- [Örnek Playbook lar için](https://github.com/Azure-Samples/ansible-playbooks)

playbook' u çalıştırmadan once ansible gerekli bağımlıklarını yükleyiniz.

```
$  pip3 install ansible[azure]
$  ansible-galaxy install azure.azure_preview_modules
$  pip3 install -r ~/.ansible/roles/azure.azure_preview_modules/files/requirements-azure.txt

```
ansible syntax check etmek için 
```
$ ansible-playbook playbook.yml --syntax-check
```




#### Sunucu Gereksinimleri

Bütün sunuclara ssh veya username, password ile bağlanabilmeliyiz.

Şuan için başka birşey kurulu olmasına gerek yok. Ansible (Kubespray) gerekesinimleri zaten kendisi download edip kuracak şekilde ayarlanmış.


#### Kurulum

Kubespray github sayfasından 2.13.3 versiyonunu indiriyoruz.

bu versyonun zipli halini ve gerekli konfigürasyonların yapılmış halini bu projeye de ekledim. 

bende Ansible 2.9.12 versionu kurlu olduğu için kubespray klasöründeki requirements dosyasında absible versiyonunu bendeki versyonla değiştirdim.

ayrıca bende Ansible Pyuthon 3 versyonu ile birlikte kurulu komtları da buna göre çağıracağım.

daha sonra alttaki komutla birlikte localimizdeki gereksinimleri kuruyoruz.

```
sudo pip3 install -r requirements.txt
```

- Daha sonra kubespray klasöründe yer alan inventory altındaki sample klasörünü mycluster olarak kopyalıyoruz.
- inventory.ini dosyası için gerekli ayarları [şu linkten](../inventory/mycluster/inventory.ini) görebilirsiniz.
- daha sonra 






