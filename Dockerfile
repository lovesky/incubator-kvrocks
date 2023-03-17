# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

FROM ubuntu:latest as build

ARG MORE_BUILD_ARGS

# workaround tzdata install hanging
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt update && apt install -y git gcc g++ make cmake autoconf automake libtool python3 libssl-dev
WORKDIR /kvrocks

COPY . .
RUN ./x.py build -DENABLE_OPENSSL=ON -DPORTABLE=ON $MORE_BUILD_ARGS
RUN strip -g /kvrocks/build/kvrocks

FROM ubuntu:latest

RUN apt update && apt install -y libssl-dev

WORKDIR /kvrocks

COPY --from=build /kvrocks/build/kvrocks ./bin/

COPY ./kvrocks.conf  ./conf/
RUN sed -i -e 's%dir /tmp/kvrocks%dir /var/lib/kvrocks%g' ./conf/kvrocks.conf
VOLUME /var/lib/kvrocks

COPY ./LICENSE ./NOTICE ./DISCLAIMER ./
COPY ./licenses ./licenses

EXPOSE 6666:6666
ENTRYPOINT ["./bin/kvrocks", "-c", "./conf/kvrocks.conf"]
