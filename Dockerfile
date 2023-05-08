FROM python:3.8-slim as builder

WORKDIR /usr/app
ENV PATH="/usr/app/venv/bin:$PATH"

RUN sed -e 's/deb.debian.org/mirrors.aliyun.com/g' \
              -e  's/security.debian.org/mirrors.aliyun.com/g' \
        /etc/apt/sources.list -i

RUN apt-get update && apt-get install -y --no-install-recommends ffmpeg && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /usr/app
RUN python -m venv ./venv

COPY requirements.txt .

RUN pip install -r requirements.txt -i https://mirrors.aliyun.com/pypi/simple/

# RUN pip config set global.index-url https://mirrors.aliyun.com/pypi/simple/
# RUN pip config set global.trusted-host mirrors.aliyun.com

FROM python:3.8-slim

WORKDIR /usr/app
ENV PATH="/usr/app/venv/bin:$PATH"

COPY --from=builder /usr/app/venv ./venv
COPY . .

RUN cp ./gui/streamlit_app.py .

CMD ["streamlit", "run", "streamlit_app.py"]

EXPOSE 8501
