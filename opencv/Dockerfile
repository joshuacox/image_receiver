FROM jjanzic/docker-python3-opencv:contrib-opencv-4.0.1

RUN pip install watchdog
RUN useradd opencv
WORKDIR /opencv
COPY run /opencv/run
COPY tricks.yaml /opencv/tricks.yaml
RUN chown -R opencv. /opencv
USER opencv
CMD [ "/bin/bash", "/opencv/run" , "./tricks.yaml" ]
