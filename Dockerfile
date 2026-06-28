FROM openjdk:8
# ↑ Keep openjdk:8 — your pom.xml has <java.version>1.8</java.version>
# The JAR was compiled with Java 8 so the runtime must also be Java 8

ADD jarstaging/com/satish/demo-workshop/2.1.2/demo-workshop-2.1.2.jar app.jar
# ↑ DO NOT change anything here — here is why each part is fixed:
#
# jarstaging/          = folder created by 'mvn clean deploy' in build stage
# com/satish/          = your groupId 'com.satish' becomes a folder path
# demo-workshop/       = your artifactId from pom.xml
# 2.1.2/               = your version from pom.xml
# demo-workshop-2.1.2.jar = Maven always names JAR as artifactId-version.jar
#
# Changed: sample_app.jar → app.jar (cleaner name, no functional difference)

ENTRYPOINT ["java", "-jar", "app.jar"]
# ↑ Starts the Spring Boot app when the container runs


######
