FROM jekyll/jekyll:4.2.0

# Install Bundler 1.17.3 to match the Gemfile.lock
RUN gem install bundler -v 1.17.3

# Install missing gem (sassc) if required
RUN gem install sassc -v 2.4.0

WORKDIR /srv/jekyll
COPY . .

CMD ["jekyll", "serve", "--host", "0.0.0.0", "--drafts", "--config", "_config.yml"]
