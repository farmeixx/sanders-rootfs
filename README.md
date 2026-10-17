# Motorola Moto G5S Plus (sanders) — comandos rápidos

Esta branch `help` contém instruções operacionais para as imagens Linux do projeto `farmeixx/sanders-rootfs`. A compilação do kernel e dos RootFS é feita nas GitHub Actions; os três RootFS reutilizam o checkpoint bem-sucedido de kernel da branch `main`.

## Artefatos

| Distribuição | Imagem comprimida |
| --- | --- |
| Alpine | `alpine-sanders-rootfs.ext4.zst` |
| Debian | `debian-sanders-rootfs.ext4.zst` |
| Ubuntu | `ubuntu-sanders-rootfs.ext4.zst` |

Cada build publica também `boot.img` e `rootfs.ext4`, com o kernel e os módulos correspondentes. Não misture imagens de builds diferentes.

**Tamanho inicial do ext4:** Debian e Ubuntu agora usam 1.024 MiB, desde que
sobre pelo menos 64 MiB livres na imagem criada; caso contrário, a build falha.
O Alpine do Sanders ainda tem tamanho adaptativo. Esses valores são o tamanho
**descompactado**, não o tamanho do download `.zst`. Depois o usuário pode
expandir o filesystem na partição `userdata` com `resize2fs`.

## Acesso USB SSH

O rootfs configura uma interface USB RNDIS com o endereço `172.16.42.1`. Após verificar a interface USB e o boot no aparelho, conecte a partir do host:

```sh
ssh root@172.16.42.1
```

O acesso root herdado é intencionalmente permissivo para testes via cabo USB confiável; não conecte esse serviço a redes externas.

## Wi-Fi (NetworkManager)

Os três rootfs incluem NetworkManager e `nmcli`. **No Sanders, o Wi-Fi
ainda depende de teste real do driver e do firmware do próprio aparelho.**
Se `wlan0` estiver disponível:

```sh
nmcli device status
nmcli device wifi list
nmcli --ask device wifi connect "SSID" ifname wlan0
```

Troque `SSID` pelo nome da rede. A opção `--ask` pede a senha
interativamente, sem deixá-la escrita no histórico do shell.

## Verificar os serviços USB

No Sanders com **Alpine (OpenRC)**:

```sh
rc-service usb-gadget status
rc-service usb-sshd status
rc-service dnsmasq status
ip -br addr show usb0
```

No **Debian/Ubuntu (systemd)**:

```sh
systemctl status usb-gadget.service usb-dhcp.service ssh.service
ip -br addr show usb0
```

O arquivo `/etc/usb-gadget.conf` preserva a identidade USB do Sanders:
MAC `02:00:00:00:53:01` no dispositivo, `02:00:00:00:53:02` no
host, identificador `sanders` e IP `172.16.42.1`. O executável
`/usr/local/sbin/usb-gadget` é o mesmo utilizado no Channel;
os arquivos de serviço são específicos de OpenRC ou systemd.

Se o gadget ou UDC falhar, não presuma que o SSH está disponível. A
configuração do SSH permanece **restrita ao IP USB**, não à rede Wi-Fi.

## Corrigir o relógio

```sh
date -u -s "YYYY-MM-DD HH:MM:SS"
date
```

Informe o horário UTC correto.

## Identificar a partição raiz e expandir ext4

Verifique primeiro a partição efetivamente montada em `/`:

```sh
lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINTS
grep ' / ' /proc/mounts
command -v resize2fs
```

Instale `e2fsprogs-extra` (Alpine) ou `e2fsprogs` (Debian/Ubuntu) se necessário.
`/dev/root` pode ser só um apelido; use também `findmnt -n -o SOURCE /`,
`lsblk` e `/proc/mounts` para identificar a **partição userdata real**.
**Não adivinhe o dispositivo.** A expansão online de ext4 montado é suportada
quando o kernel a oferece; **não use opções de redução** na raiz montada.
Somente depois de verificar o dispositivo correto, execute:

```sh
resize2fs /dev/ROOT_PARTITION
df -h /
```

`resize2fs` expande o sistema de arquivos até o tamanho da partição disponível, mas não redimensiona a partição.

## Extrair uma imagem compactada

```sh
zstd -d -f ubuntu-sanders-rootfs.ext4.zst -o rootfs.ext4
```

Adapte o nome para Alpine ou Debian. Se estiver utilizando o artefato `rootfs.ext4` disponibilizado diretamente, não precisa descompactar.

## Observações

- O kernel usa um DTB específico do Sanders; boot image limitada a 16 MiB.
- Nenhum blob ou patch de Wi-Fi do Channel é incorporado.
- Não é necessário montar partições Android `modem`/`vendor` para os RootFS.
- Primeiro boot, USB RNDIS, SSH e Wi-Fi **ainda precisam ser verificados em hardware Sanders**. O teste positivo do Channel não prova compatibilidade da UDC do Sanders.
- Debian e Ubuntu em 1.024 MiB ainda aguardam compilação e verificação da margem de espaço (mínimo 64 MiB livre).
- Se o kernel de origem não fornecer `sanders_defconfig` e `msm8953-motorola-sanders.dts`, o workflow falhará propositalmente, sem usar configuração do Channel.

[Voltar ao builder](https://github.com/farmeixx/sanders-rootfs/tree/main)
