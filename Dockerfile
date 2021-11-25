FROM tomcat:8.0-alpine

LABEL maintainer=gopi@gmail.com

//ADD org/springframework/samples/petclinic/18.0.0/petclinic-18.0.0.war /usr/local/tomcat/webapps/

ADD ./target/petclinic.war /usr/local/tomcat/webapps/

EXPOSE 8080

CMD ["catalina.sh", "run"]
