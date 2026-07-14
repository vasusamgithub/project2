FROM tomcat:9
COPY target/helloworld.war /usr/local/tomcat/webapps/app.war
