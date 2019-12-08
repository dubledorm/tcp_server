require 'date'
require 'enumerator'

module Monitoring
  # Базовый класс для записи потока данных от одного tcp сервера
  class Base

    NUMBER_BYTE_IN_LINE = 16

    def initialize(port)
      @port = port
    end

    def write(data)
      data_strings = data_presenter(data)
      data_strings.each do |one_str|
        meassage = "#{Time.now} [#{Thread.current.object_id}] #{port} -> #{one_str}"
        write_to_channel(meassage)
      end
    end

  protected

    # Нижнеуровневая функция для записи подготовленных данных
    def write_to_channel(message)
      raise NotImplementedError
    end

  def data_presenter(data)
    result = []

    data.split('').each_slice(NUMBER_BYTE_IN_LINE) do |d|
      codes = d.map{ |smb| smb.ord }
      one_string = codes.inject('') { |res, elem| res + "%02X " % elem }
      (NUMBER_BYTE_IN_LINE * 3 + 2 - one_string.size).times { one_string += ' ' }
      one_string += d.join
      result << one_string
    end

    result
  end

  private
    attr_accessor :port
  end
end