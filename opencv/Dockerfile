FROM python:3

COPY . /usr/src/build
WORKDIR /usr/src/build
RUN useradd buildr \
&& chown -R buildr. /usr/src/build \
&& mkdir -p /home/buildr \
&& printf 'PATH=/home/buildr/.local/bin:$PATH' >> /home/buildr/.bashrc \
&& printf 'PATH=/home/buildr/.local/bin:$PATH' >> /home/buildr/.bash_profile \
&& chown -R buildr. /home/buildr

USER buildr
ENV FLASK_APP=flaskr

COPY ./flaskr/requirements.txt ./
RUN /bin/bash -l -c "source ~/.bashrc \
&& pip install --user --no-cache-dir -r requirements.txt \
&& python3 -m venv venv && . venv/bin/activate \
&& pip install --user --no-cache-dir flask \
&& python setup.py bdist_egg"

FROM python:3

WORKDIR /usr/src/app

RUN apt-get update && apt-get install -y \
	sqlite3 \
	&& rm -rf /var/lib/apt/lists/*

# For now we want to eliminate downloading pytorch twice
COPY --from=0 /home/buildr /home/flask
RUN useradd flask \
&& chown -R flask. /usr/src/app \
&& mkdir -p /home/flask \
&& printf 'PATH=/home/flask/.local/bin:$PATH' >> /home/flask/.bashrc \
&& printf 'PATH=/home/flask/.local/bin:$PATH' >> /home/flask/.bash_profile \
&& chown -R flask. /home/flask

USER flask
ENV FLASK_APP=flaskr

COPY --from=0 /usr/src/build/dist/flaskr-1.0.0-py3.7.egg .
COPY ./flaskr/requirements.txt ./
RUN /bin/bash -l -c "source ~/.bashrc \
&& easy_install --user ./flaskr-1.0.0-py3.7.egg \
&& pip install --user --no-cache-dir waitress \
&& pip install --user --no-cache-dir -r requirements.txt \
&& python3 -m venv venv && . venv/bin/activate"

COPY flaskr/imagenet_class_index.json ./
COPY ./start.sh ./
ENTRYPOINT [ "/bin/bash", "./start.sh" ]
