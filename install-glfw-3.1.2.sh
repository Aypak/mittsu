set -x
set -e
if [ ! -e glfw-3.1.2/include/GLFW/glfw3.h ]; then
  wget https://github.com/glfw/glfw/releases/download/3.1.2/glfw-3.1.2.zip
  unzip glfw-3.1.2.zip;
fi
cd glfw-3.1.2
if [ ! -e src/libglfw3.a ]; then
  cmake -D BUILD_SHARED_LIBS=ON .
  make;
fi
if [ ! -e /usr/local/lib/libglfw.so ]; then
  sudo make install;
fi
