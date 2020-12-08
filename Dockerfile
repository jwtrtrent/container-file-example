#Copyright 2020 Trent Jerold Murray
#
#Permission is hereby granted, free of charge, to any person obtaining a copy of 
#this software and associated documentation files (the "Software"), to deal in 
#the Software without restriction, including without limitation the rights to 
#use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies 
#of the Software, and to permit persons to whom the Software is furnished to do 
#so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in all 
#copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE 
#SOFTWARE.

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
