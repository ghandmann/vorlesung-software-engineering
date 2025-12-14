# Base Image
FROM ubuntu:24.04 

# Daten vom Host ins Image-Layer kopieren
COPY my_script.sh /home/root/ 

# Commando im Layer ausführen
RUN date +'%F %T' > /home/root/image_created

# Startkommando definieren
CMD ["/bin/bash", "/home/root/my_script.sh"]

