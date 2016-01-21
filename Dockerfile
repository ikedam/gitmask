FROM phusion/baseimage
MAINTAINER jason@thesparktree.com

# Install Nginx.
RUN \
  add-apt-repository ppa:nginx/development && \
  apt-get update && \
  apt-get install -y build-essential python-dev libffi-dev fcgiwrap curl git unzip libreadline-dev libncurses5-dev libpcre3-dev libssl-dev luajit lua5.1 liblua5.1-0-dev nano perl wget nginx-extras && \
  rm -rf /var/lib/apt/lists/*

# Install luarocks
RUN \
  wget http://luarocks.org/releases/luarocks-2.2.0.tar.gz && \
  tar -xzvf luarocks-2.2.0.tar.gz && \
  rm -f luarocks-2.2.0.tar.gz && \
  cd luarocks-2.2.0 && \
  ./configure && \
  make build && \
  make install && \
  make clean && \
  cd .. && \
  rm -rf luarocks-2.2.0

# Install pip
RUN curl --silent --show-error --retry 5 https://bootstrap.pypa.io/get-pip.py | sudo python2.7

# Install python github library
RUN sudo pip install --pre github3.py

# Copy nginx conf file
ADD ./nginx/git.conf /etc/nginx/sites-enabled/git.conf

#Create gitmask folder structure & set as volumes
RUN mkdir -p /srv/gitmask/

RUN chown -R www-data:www-data /srv/gitmask && \
	chmod -R g+ws /srv/gitmask
ADD ./git/post-receive.py /srv/gitmask/post-receive.py
ADD ./start.sh /srv/gitmask/start.sh
ADD ./git_handler.py /srv/gitmask/git_handler.py
RUN chmod +x /srv/gitmask/start.sh && \
    chmod +x /srv/gitmask/git_handler.py
e

VOLUME ["/srv/gitmask"]

EXPOSE 8080
EXPOSE 943

CMD ["/srv/gitmask/start.sh"]
#service fcgiwrap start
#nginx -g "daemon off;"
#CMD ["nginx", "-g", "daemon off;"]