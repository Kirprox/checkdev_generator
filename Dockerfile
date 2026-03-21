FROM maven:3.9.6-eclipse-temurin-17

RUN mkdir checkdev_generator

WORKDIR checkdev_generator

COPY . .

RUN mvn package -Dmaven.test.skip=true

CMD ["java", "-jar", "target/generator-1.0.0.jar"]