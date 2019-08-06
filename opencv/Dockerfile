FROM python:3

COPY . /usr/src/build
WORKDIR /usr/src/build
COPY ./flaskr/requirements.txt ./
RUN /bin/bash -l -c "source ~/.bashrc \
&& pip install --user --no-cache-dir -r requirements.txt \
&& python3 -m venv venv && . venv/bin/activate \
&& pip install --user --no-cache-dir flask \
&& python setup.py bdist_egg"


FROM python:3

WORKDIR /usr/src/app

COPY --from=0 /usr/srv/build/dist/flaskr-1.0.0-py3.7.egg .

RUN apt-get update && apt-get install -y \
	sqlite3 \
	&& rm -rf /var/lib/apt/lists/*

RUN useradd flask \
&& chown -R flask. /usr/src/app \
&& mkdir -p /home/flask \
&& printf 'PATH=/home/flask/.local/bin:$PATH' >> /home/flask/.bashrc \
&& printf 'PATH=/home/flask/.local/bin:$PATH' >> /home/flask/.bash_profile \
&& chown -R flask. /home/flask

USER flask
ENV FLASK_APP=flaskr

COPY ./flaskr/requirements.txt ./
RUN /bin/bash -l -c "source ~/.bashrc \
&& easy_install --user ./flaskr-1.0.0-py3.7.egg \
&& pip install --user --no-cache-dir waitress \
&& pip install --user --no-cache-dir -r requirements.txt \
&& python3 -m venv venv && . venv/bin/activate"

COPY flaskr/imagenet_class_index.json ./
COPY ./start.sh ./
ENTRYPOINT [ "/bin/bash", "./start.sh" ]
