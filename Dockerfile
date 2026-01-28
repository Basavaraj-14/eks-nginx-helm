FROM ubuntu:latest AS builder
WORKDIR /opt
RUN apt update -y && apt install maven && apt install git -y && apt install openjdk-jre-11
COPY src ./src
COPY pom.xml .
RUN mvn clean package
FROM tomee:8
WORKDIR /usr/local/webapp
COPY --from=builder /opt/target/*.war /usr/local/webapps/
EXPOSE 8080
ENTRYPOINT ["catalina.sh"]
CMD ["run"]
