# frozen_string_literal: true

# Clase base para las tareas asíncronas.
class BaseTask
  attr_accessor :id

  @@id = 0
  @@creation_mutex = Mutex.new

  def initialize
    @@creation_mutex.synchronize do
      @id = @@id
      @@id += 1
    end
  end

  def perform_async(**args)
    Thread.new do
      perform(**args)
    end
    @id
  end

  def perform
    raise NotImplementedError
  end
end
