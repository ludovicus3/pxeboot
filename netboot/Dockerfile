FROM alpine:latest

ENV TFTPBOOT=/tftpboot

RUN apk add --no-cache grub grub-efi grub-bios syslinux

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

VOLUME $TFTPBOOT

ENTRYPOINT ["/entrypoint.sh"]

