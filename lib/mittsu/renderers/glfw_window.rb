require 'opengl'
require 'glfw'

path = `pkg-config glfw3 --libs-only-L`.chomp.strip[2..-1]
GLFW.load_lib('libglfw3.dylib', path)

include GLFW

module Mittsu
  module GLFW
    class Window
      def initialize(width, height, title)
        glfwInit

        glfwWindowHint GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE
        glfwWindowHint GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE
        glfwWindowHint GLFW_CONTEXT_VERSION_MAJOR, 3
        glfwWindowHint GLFW_CONTEXT_VERSION_MINOR, 3
        glfwWindowHint GLFW_CONTEXT_REVISION, 0

        @width, @height, @title = width, height, title
        @handle = glfwCreateWindow(@width, @height, @title, nil, nil)
        glfwMakeContextCurrent @handle
        glfwSwapInterval 1
      end

      def run
        while glfwWindowShouldClose(@handle) == 0
          yield

          glfwSwapBuffers @handle
          glfwPollEvents
        end
        glfwDestroyWindow @handle
        glfwTerminate
      end

      def get_framebuffer_size
        width, height = ' '*8, ' '*8
        glfwGetFramebufferSize(@handle, width, height)
        [width.unpack('L')[0], height.unpack('L')[0]]
      end
    end
  end
end
