
FROM ubuntu

# Install tools and libraries:
RUN DEBIAN_FRONTEND=noninteractive apt update --fix-missing -y && apt upgrade -y
RUN DEBIAN_FRONTEND=noninteractive apt install -y ruby ruby-dev sqlite3 libsqlite3-dev gem build-essential sudo vim netcat tree nginx
RUN gem update --system && gem install bundler unicorn && gem update --system

# Add website data from repository:
ADD . /var/www/fll.presidentbeef.com/

# Add helper scripts:
RUN echo "#!/bin/bash" > /launch-nginx.sh
RUN echo "sleep 5" >> /launch-nginx.sh
RUN echo "service nginx start" >> /launch-nginx.sh
RUN chmod +x /launch-nginx.sh
RUN echo "server {" > /etc/nginx/sites-enabled/default
RUN echo "    listen [::]:80 ipv6only=on default_server;" >> /etc/nginx/sites-enabled/default
RUN echo "    listen 0.0.0.0:80 default_server;" >> /etc/nginx/sites-enabled/default
RUN echo "    server_name _;" >> /etc/nginx/sites-enabled/default
RUN echo "    root /var/www/fll.presidentbeef.com/public_html;" >> /etc/nginx/sites-enabled/default
RUN echo "    try_files \$uri/index.html \$uri @rails;" >> /etc/nginx/sites-enabled/default
RUN echo "    location @rails {" >> /etc/nginx/sites-enabled/default
RUN echo "        proxy_pass http://unix:/tmp/unicorn.fllp.sock;" >> /etc/nginx/sites-enabled/default
RUN echo "        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;" >> /etc/nginx/sites-enabled/default
RUN echo "        proxy_set_header Host \$http_host;" >> /etc/nginx/sites-enabled/default
RUN echo "        proxy_redirect off;" >> /etc/nginx/sites-enabled/default
RUN echo "    }" >> /etc/nginx/sites-enabled/default
RUN echo "}" >> /etc/nginx/sites-enabled/default

# Set proper permissions and give www-data user a home dir:
RUN mkdir -p /home/www-data && chown www-data /home/www-data/ && \
    usermod -d /home/www-data/ www-data && chown -R www-data /var/www/ && \
    chmod -R u+rw /var/www/fll.presidentbeef.com/
WORKDIR /var/www/fll.presidentbeef.com
USER www-data
ENV HOME /home/www-data/

# Prepare website for launch:
RUN bundle install --path vendor
RUN bundle config set path 'vendor'
RUN sed -i '/stdout_path/d' ./unicorn.rb && sed -i '/stderr_path/d' ./unicorn.rb
RUN sed -i 's/config_verifycaptcha = true/config_verifycaptcha = false/g' ./config.ru
RUN mkdir -p /var/www/fll.presidentbeef.com/pids/

# Final launch command:
USER root
CMD ["bash", "-c", "nginx -t && bash /launch-nginx.sh & disown && exec sudo -u www-data bundle exec unicorn -c unicorn.rb"]

EXPOSE 80
