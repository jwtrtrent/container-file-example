# Create dev enviroment
FROM ubi7:7.9
ARG CMAKE_VER=3.19.1
COPY external/cmake-3.19.1.tar.gz /tmp

RUN yum install -y gcc gcc-c++ make openssl-devel tar

RUN tar -C /tmp -xvf /tmp/cmake-$CMAKE_VER.tar.gz && \
    (cd /tmp/cmake-$CMAKE_VER/ && /tmp/cmake-$CMAKE_VER/bootstrap) && \
    make -C /tmp/cmake-$CMAKE_VER/ -j 8 && \
    /tmp/cmake-$CMAKE_VER/bin/cmake --install /tmp/cmake-$CMAKE_VER/ --prefix /usr

# Compile project
COPY sample-project/ /tmp/sample-project
RUN cmake -DCMAKE_BUILD_TYPE=Release -B /tmp/sample-project-build -S /tmp/sample-project && \
    cmake --build /tmp/sample-project-build

# Create Runtime Archive
FROM ubi7-minimal:7.9

COPY --from=0 /tmp/sample-project-build/cpp_test /usr/bin
RUN microdnf install shadow-utils
RUN useradd cpptest
USER cpptest
CMD cpp_test
