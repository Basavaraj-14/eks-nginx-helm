FROM ubuntu:22.04 AS builder
WORKDIR /opt
RUN apt update -y && apt install -y maven git openjdk-11-jdk
COPY src ./src
COPY pom.xml .
RUN mvn clean package
FROM tomee:8
WORKDIR /usr/local/tomcat/webapps/
COPY --from=builder /opt/target/*.war ./ROOT.war
EXPOSE 8080
ENTRYPOINT ["catalina.sh"]
CMD ["run"]
