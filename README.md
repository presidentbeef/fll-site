# Fledgling Languages List

This is the site for https://fll.presidentbeef.com and not useful for anyone else, probably.


### Deployment with Docker

Use `docker-compose up -d` in the repo main dir to start it with docker.
(Docker and docker-compose need to be installed first.)

Once it is running, connect to it at port 80 with your browser like this:

1. Get the container name from `docker-compose ps`

2. Run `docker inspect <container name> | grep Address` and get its ip

3. Browse to your container's ip at port 80 via http.

To shut it down, use `docker-compose down`. (**Deletes the database.**)


### Deployment (local)

To deploy directly on your machine via unicorn, you need to set up
an nginx forward proxy which serves static files from `./public_html/`
and otherwise proxies through your unicorn instance.

Then, you need to change `unicorn.rb` accordingly with listeners and
for the correct app directory. (This isn't necessary if you deploy via
docker as above, neither is an nginx proxy in that case.)

Once done, you can start unicorn like this:

    bundle install --path vendor
    bundle exec unicorn -c unicorn.rb

Then, start your nginx forward proxy and connect to that with your browser.
