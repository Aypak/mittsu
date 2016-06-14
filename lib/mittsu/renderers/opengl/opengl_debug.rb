require 'opengl'

ERROR_STRINGS = {
  OpenGL::GL_NO_ERROR => 'NO_ERROR',
  OpenGL::GL_INVALID_ENUM => 'INVALID_ENUM',
  OpenGL::GL_INVALID_VALUE => 'INVALID_VALUE',
  OpenGL::GL_INVALID_OPERATION => 'INVALID_OPERATION',
  OpenGL::GL_STACK_OVERFLOW => 'STACK_OVERFLOW',
  OpenGL::GL_STACK_UNDERFLOW => 'STACK_UNDERFLOW',
  OpenGL::GL_OUT_OF_MEMORY => 'OUT_OF_MEMORY',
  # OpenGL::GL_TABLE_TOO_LARGE => 'TABLE_TOO_LARGE'
}

module OpenGLDebug
  class DebugShader
    def initialize(handle)
      @handle = handle
      @uniforms = {}
    end

    def set_uniform(handle, name)
      @uniforms[handle] = name
    end

    def get_uniform_name(handle)
      @uniforms[handle]
    end
  end

  module OpenGLProxy
    extend OpenGL
  end

  def self.load_lib
    OpenGL.load_lib
  end

  OpenGL.constants.each do |c|
    const_set c, OpenGL.const_get(c)
  end

  def call_debug_method m, *args
    r = OpenGLProxy.send(m, *args)
    if m.to_s.start_with?('glUniform')
      uniform_name = @@current_shader.get_uniform_name(args.first)
      call = "#{m}('#{uniform_name}',#{args[1..-1].map { |s| s.to_s[0..20] }.join(', ')})"
    else
      call = "#{m}(#{args.map { |s| s.to_s[0..20] }.join(', ')})"
    end
    ret = r.nil? ? '' : " => #{r}"
    puts "#{call}#{ret} (#{caller[0]})"
    e = OpenGLProxy.glGetError
    raise "ERROR: #{m} => #{ERROR_STRINGS[e]}" unless e == OpenGL::GL_NO_ERROR
    r
  end

  OpenGL.instance_methods.each do |m|
    define_method m do |*args|
      self.call_debug_method(m, *args)
    end
  end

  def glCreateProgram
    call_debug_method(:glCreateProgram).tap do |handle|
      @@shaders ||= {}
      @@shaders[handle] = DebugShader.new(handle)
    end
  end

  def glUseProgram(handle)
    @@current_shader = @@shaders[handle]
    call_debug_method(:glUseProgram, handle)
  end

  def glGetUniformLocation(program, name)
    call_debug_method(:glGetUniformLocation, program, name).tap do |handle|
      @@shaders[program].set_uniform(handle, name)
    end
  end
end
