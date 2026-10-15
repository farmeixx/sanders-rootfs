# Motorola Moto G5S Plus (sanders) — comandos rápidos

Esta branch `help` contém instruções operacionais para as imagens Linux do projeto `farmeixx/sanders-rootfs`. A compilação do kernel e dos RootFS é feita nas GitHub Actions; os três RootFS reutilizam o checkpoint bem-sucedido de kernel da branch `main`.

## Artefatos

| Distribuição | Imagem comprimida |
| --- | --- |
| Alpine | `alpine-sanders-rootfs.ext4.zst` |
| Debian | `debian-sanders-rootfs.ext4.zst` |
| Ubuntu | `ubuntu-sanders-rootfs.ext4.zst` |

Cada build publica também `boot.img` e `rootfs.ext4`, com o kernel e os módulos correspondentes. Não misture imagens de builds diferentes.

## Acesso USB SSH

O rootfs configura uma interface USB RNDIS com o endereço `172.16.42.1`. Após verificar a interface USB e o boot no aparelho, conecte a partir do host:

```sh
ssh root@172.16.42.1
```

O acesso root herdado é intencionalmente permissivo para testes via cabo USB confiável; não conecte esse serviço a redes externas.

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

Instale `e2fsprogs-extra` (Alpine) ou `e2fsprogs` (Debian/Ubuntu) se necessário. **Não adivinhe o dispositivo.** Depois de confirmar o caminho real e se a operação é segura para o sistema montado, execute:

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
- Primeiro boot, USB RNDIS e SSH ainda precisam ser verificados em hardware Sanders.
- Se o kernel de origem não fornecer `sanders_defconfig` e `msm8953-motorola-sanders.dts`, o workflow falhará propositalmente, sem usar configuração do Channel.

[Voltar ao builder](https://github.com/farmeixx/sanders-rootfs/tree/main)
