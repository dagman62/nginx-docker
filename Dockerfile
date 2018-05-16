FROM ubuntu

# setup environment variables for installs and configurations
ENV CONF_DIR /etc/nginx/conf.d
ENV APT_SOURCES /etc/apt/sources.list
ENV POLICY_FILE /etc/apt/preferences.d/nginx
ENV UBUNTU_VER bionic 

# add the gpg key for nginx package install
ADD nginx_signing.key /tmp/nginx_signing.key

# install dependancies add configuration files and install nginx
RUN apt-get update && apt-get install -y \
  wget \
  links \
  gnupg2 && \
  cd ~ && \
  apt-key add /tmp/nginx_signing.key && \ 
  echo "# nginx mainline repository" >> ${APT_SOURCES} && \
  echo "deb http://nginx.org/packages/mainline/ubuntu/ ${UBUNTU_VER} nginx" >> ${APT_SOURCES} && \
  echo "deb-src http://nginx.org/packages/mainline/ubuntu/ ${UBUNTU_VER} nginx" >> ${APT_SOURCES} && \
  touch ${POLICY_FILE} && \
  echo "Package: nginx" >> ${POLICY_FILE} && \
  echo "Pin: origin nginx.org" >> ${POLICY_FILE} && \
  echo "Pin-Priority: 900" >> ${POLICY_FILE} && \
  apt-get update && apt-get install -y nginx

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access_log \
	&& ln -sf /dev/stderr /var/log/nginx/error_log

EXPOSE 80

STOPSIGNAL SIGTERM

CMD ["nginx", "-g", "daemon off;"]
