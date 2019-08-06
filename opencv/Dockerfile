FROM python:3

RUN apt-get update && apt-get install -y \
	sqlite3 \
	&& rm -rf /var/lib/apt/lists/*

COPY ./README.rst /usr/src/build/
COPY ./MANIFEST.in /usr/src/build/
COPY ./setup.py /usr/src/build/
COPY ./setup.cfg /usr/src/build/
COPY ./tests /usr/src/build/
COPY ./flaskr /usr/src/build/flaskr
WORKDIR /usr/src/build
RUN useradd buildr \
&& chown -R buildr. /usr/src/build \
&& mkdir -p /home/buildr \
&& printf 'PATH=/home/buildr/.local/bin:$PATH' >> /home/buildr/.bashrc \
&& printf 'PATH=/home/buildr/.local/bin:$PATH' >> /home/buildr/.bash_profile \
&& chown -R buildr. /home/buildr

USER buildr
ENV FLASK_APP=flaskr

# no venv
# && python3 -m venv venv && . venv/bin/activate \

RUN /bin/bash -l -c "source ~/.bashrc \
&& pip3 install --user --no-cache-dir wheel flask \
&& pip3 install --user --no-cache-dir -r flaskr/requirements.txt \
&& python3 setup.py bdist_wheel"

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

COPY --from=0 /usr/src/build/dist/flaskr-1.0.0-py2.py3-none-any.whl .
COPY ./flaskr/requirements.txt ./
RUN /bin/bash -l -c "source ~/.bashrc \
&& python3 -m venv venv && . venv/bin/activate \
&& pip3 install --user --no-cache-dir waitress \
&& pip3 install --user --no-cache-dir -r requirements.txt \
&& pip3 install --user --no-cache-dir ./flaskr-1.0.0-py2.py3-none-any.whl"

COPY flaskr/imagenet_class_index.json ./
COPY ./start.sh ./
ENTRYPOINT [ "/bin/bash", "./start.sh" ]
