FROM jjanzic/docker-python3-opencv:contrib-opencv-4.0.1

RUN apt-get -qq update && apt-get install -yqq \
  inotify-tools \
  uuid-runtime \
  && apt-get clean -yqq \
  && rm -rf /var/lib/apt/lists/*
RUN pip install watchdog
RUN useradd opencv
WORKDIR /opencv
COPY opencvwatcher.bash /opencv/opencvwatcher.bash
# COPY tricks.yaml /opencv/tricks.yaml
RUN chown -R opencv. /opencv
USER opencv
CMD [ "/opencv/opencvwatcher.bash" , "/opencvUploads" ]
