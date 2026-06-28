FROM eclipse-temurin:8-jre
# ↑ eclipse-temurin is the official replacement for openjdk
# openjdk:8 was removed from Docker Hub
# eclipse-temurin:8-jre is maintained by the Eclipse Foundation
# -jre means Java Runtime only (smaller image, we don't need JDK to run the JAR)

ADD jarstaging/com/satish/demo-workshop/2.1.2/demo-workshop-2.1.2.jar app.jar

ENTRYPOINT ["java", "-jar", "app.jar"]
