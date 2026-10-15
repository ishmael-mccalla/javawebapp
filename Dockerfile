# For Security Labs we need both the application and DB running within the same container.
# It's far easier to use the MariaDB base image and install Maven and Tomcat on top than
# the other way around. We are using Maven to enable re-compilation within the lab.
#
#https://hub.docker.com/_/mariadb/
# This is Ubuntu 20.04 LTS
FROM mariadb:10.6.2

# Configure MariaDB
ENV MYSQL_RANDOM_ROOT_PASSWORD=true
ENV MYSQL_DATABASE=blab

# Copy DB schema for DB initialisation
COPY db /docker-entrypoint-initdb.d

# Install OpenJDK 17 (required by Aikido Zen) and Maven
# Also install the fortune-mod fortune game
# https://docs.microsoft.com/en-us/dotnet/core/install/linux-ubuntu
RUN apt-get update \
    && apt-get -y install openjdk-17-jdk-headless openjdk-17-jre-headless maven fortune-mod iputils-ping curl \
    && ln -s /usr/games/fortune /bin/ \
    && rm -rf /var/lib/apt/lists/*

# Install Aikido Zen
RUN mkdir -p /opt/zen \
    && curl -L https://github.com/AikidoSec/firewall-java/releases/download/1.1.32/zen.tar.gz | tar -xz -C /opt/zen \
    && chmod -R a+rwX /opt/zen

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

WORKDIR /app
COPY app /app
COPY maven-settings.xml /usr/share/maven/conf/settings.xml

# Compile
RUN mvn clean package && rm -rf target

ENTRYPOINT ["/entrypoint.sh"]
CMD ["-c"]