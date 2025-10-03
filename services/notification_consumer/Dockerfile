FROM ruby:3.3.5

WORKDIR /app

RUN apt-get update -qq && apt-get install -y --no-install-recommends build-essential

# Install AWS CLI v2 with architecture detection
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then \
        AWSCLI_ARCH="x86_64"; \
    elif [ "$ARCH" = "aarch64" ]; then \
        AWSCLI_ARCH="aarch64"; \
    else \
        echo "Unsupported architecture: $ARCH" && exit 1; \
    fi && \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-${AWSCLI_ARCH}.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf awscliv2.zip aws

COPY Gemfile Gemfile.lock ./

RUN bundle install

COPY . .

### Using LocalStack
# COPY docker-entry.sh /usr/local/bin/docker-entry.sh
# RUN chmod +x /usr/local/bin/docker-entry.sh
# CMD ["/usr/local/bin/docker-entry.sh"]

CMD ["bundle", "exec", "shoryuken", "-C", "shoryuken.yml"]
