FROM safe-registry.alfastrah.ru/eclipse-temurin:21-jdk-noble AS jre-build

# будем использовать эту папку
ENV JAVA_RUNTIME=/javaruntime
# создаем runtime
RUN $JAVA_HOME/bin/jlink \
         --add-modules java.base,jdk.localedata,jdk.crypto.ec,jdk.crypto.cryptoki,java.logging,java.net.http,java.sql,java.sql.rowset,java.xml,java.management,java.naming,java.security.jgss,java.security.sasl,java.datatransfer,java.desktop,java.rmi,java.instrument,java.scripting,jdk.unsupported \
         --include-locales en,ru \
         --strip-debug \
         --no-man-pages \
         --no-header-files \
         --compress=2 \
         --output $JAVA_RUNTIME
# копируем сертификаты АС в Java
COPY certs/* ./
RUN ${JAVA_RUNTIME}/bin/keytool -import -noprompt -trustcacerts -alias "AlfaPLCRootCA" -file alfa_root.cer -keystore "${JAVA_RUNTIME}/lib/security/cacerts" -storepass changeit
RUN ${JAVA_RUNTIME}/bin/keytool -import -noprompt -trustcacerts -alias "AlfaPLCIssuing01" -file alfa_issuing_1.cer -keystore "${JAVA_RUNTIME}/lib/security/cacerts" -storepass changeit
RUN ${JAVA_RUNTIME}/bin/keytool -import -noprompt -trustcacerts -alias "AlfaPLCIssuing02" -file alfa_issuing_2.cer -keystore "${JAVA_RUNTIME}/lib/security/cacerts" -storepass changeit
RUN ${JAVA_RUNTIME}/bin/keytool -import -noprompt -trustcacerts -alias "AlfaPLCNPS01" -file alfa_nps01.cer -keystore "${JAVA_RUNTIME}/lib/security/cacerts" -storepass changeit
RUN ${JAVA_RUNTIME}/bin/keytool -import -noprompt -trustcacerts -alias "Vault" -file vault.alfastrah.ru.crt -keystore "${JAVA_RUNTIME}/lib/security/cacerts" -storepass changeit
RUN ${JAVA_RUNTIME}/bin/keytool -import -noprompt -trustcacerts -alias "TestTes" -file _.tes.alfastrah.ru.crt -keystore "${JAVA_RUNTIME}/lib/security/cacerts" -storepass changeit
RUN ${JAVA_RUNTIME}/bin/keytool -import -noprompt -trustcacerts -alias "Bags" -file _.staging.bags-search.ru.crt -keystore "${JAVA_RUNTIME}/lib/security/cacerts" -storepass changeit

FROM safe-registry.alfastrah.ru/ubuntu:24.04
# положим в эту папку javaruntime
ENV JAVA_HOME=/opt/java
# добавляем эту папку в PATH
ENV PATH="${JAVA_HOME}/bin:${PATH}"
# кладем javaruntime из предыдущего stage
COPY --from=jre-build /javaruntime $JAVA_HOME
# создаем непривилегированного пользователя, из-под него в дальнейшем будем запускать java-процессы
RUN useradd -ms /bin/bash tes
# Копирование tzdata и ziupdater в контейнер
COPY templates/docker/common/ziupdater-1.1.1.1.jar ziupdater-1.1.1.1.jar
COPY templates/docker/common/tzdata2024a.tar.gz ${JAVA_HOME}/tzdata2024a.tar.gz
RUN ${JAVA_HOME}/bin/java -jar ziupdater-1.1.1.1.jar -l file://${JAVA_HOME}/tzdata2024a.tar.gz

# А дальше нужно всего лишь скопировать jar с приложением, разложить его на слои и указать ENTRYPOINT