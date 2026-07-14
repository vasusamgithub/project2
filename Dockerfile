FROM tomcat:9
COPY target/helloworld.jar /usr/local/tomcat/webapps/app.war
