FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ARG DELUGED_HOME=/var/lib/deluged

# WEB UI
EXPOSE 8112

# GUI
EXPOSE 58846

# Environment
ENV DELUGE_CONFIG_DIR=/config
ENV DELUGE_DATA_DIR=/data
ENV WG_I_NAME=wg0
ENV LOCAL_NETWORK=192.168.0.0/16
ENV DELUGE_UMASK=022
ENV DELUGE_WEB_UMASK=027


# Locale
ENV LANG=en_US.UTF-8
ENV LANGUAGE=${LANG}

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        software-properties-common \
        locales && \
    locale-gen ${LANG} && \
#    add-apt-repository -y ppa:deluge-team/stable && \
#    apt-get update && \
    apt-get install -y --no-install-recommends \
        wireguard \
        deluged \
        deluge-web \
        deluge-console \
        iproute2 \
        iptables \
        openresolv \
        supervisor \
        iputils-ping \
        dnsutils \
        traceroute \
        vim && \
    rm -rf /var/lib/apt/lists/*

#RUN useradd --home "${DELUGED_HOME}" debian-deluged

# Link default config dir to root
RUN ln -s /var/lib/deluged "${DELUGE_CONFIG_DIR}"

RUN find / -iname core.conf

# Folders
RUN mkdir -p "${DELUGE_DATA_DIR}" "${DELUGED_HOME}" && \
    chown -R debian-deluged.debian-deluged \
        "${DELUGE_DATA_DIR}" \
        "${DELUGED_HOME}"

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

# Supervisord config
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
