FROM tim03/cmake
LABEL maintainer Chen, Wenli <chenwenli@chenwenli.com＞

COPY --from=tim03/libffi /usr/include/ffi.h /usr/include/
COPY --from=tim03/libffi /usr/include/ffitarget.h /usr/include/
COPY --from=tim03/libffi /usr/lib/libffi.* /usr/lib/

COPY --from=tim03/python /usr/include/python2.7 /usr/include/python2.7/
COPY --from=tim03/python /usr/lib/python2.7 /usr/lib/python2.7/
COPY --from=tim03/python /usr/lib/libpython2.7.* /usr/lib/
COPY --from=tim03/python /usr/bin/2to3 /usr/bin/
COPY --from=tim03/python /usr/bin/pydoc /usr/bin/
COPY --from=tim03/python /usr/bin/python /usr/bin/
COPY --from=tim03/python /usr/bin/python-config /usr/bin/
COPY --from=tim03/python /usr/bin/python2 /usr/bin/
COPY --from=tim03/python /usr/bin/python2-config /usr/bin/
COPY --from=tim03/python /usr/bin/python2.7 /usr/bin/
COPY --from=tim03/python /usr/bin/python2.7-config /usr/bin/
COPY --from=tim03/python /usr/bin/smtpd.py /usr/bin/
COPY --from=tim03/python /usr/bin/idle /usr/bin/

WORKDIR /usr/src
ADD http://llvm.org/releases/3.9.1/llvm-3.9.1.src.tar.xz .
ADD http://llvm.org/releases/3.9.1/cfe-3.9.1.src.tar.xz .
ADD http://llvm.org/releases/3.9.1/compiler-rt-3.9.1.src.tar.xz .
COPY md5sums .
RUN md5sum -c md5sums
RUN \
	tar xvf llvm-3.9.1.src.tar.xz && \
	mv -v llvm-3.9.1.src llvm && \
	pushd llvm && \
	tar -xvf ../cfe-3.9.1.src.tar.xz -C tools && \
	tar -xvf ../compiler-rt-3.9.1.src.tar.xz -C projects && \
	mv -v tools/cfe-3.9.1.src tools/clang && \
	mv -v projects/compiler-rt-3.9.1.src projects/compiler-rt && \
	mkdir -v build && \
	cd build && \
	CC=gcc CXX=g++                              \
	cmake -DCMAKE_INSTALL_PREFIX=/usr           \
	      -DLLVM_ENABLE_FFI=ON                  \
	      -DCMAKE_BUILD_TYPE=Release            \
	      -DLLVM_BUILD_LLVM_DYLIB=ON            \
	      -DLLVM_TARGETS_TO_BUILD="host;AMDGPU" \
	      -Wno-dev ..                           && \
	make -j"$(nproc)" && \
	(make check-all || true) && \
	make install && \
	popd && \
	rm -rf llvm

