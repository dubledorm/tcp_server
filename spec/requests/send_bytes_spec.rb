#coding: utf-8
require 'rails_helper'
require "awesome_print"

RSpec.describe "send_bytes", type: :request do

  before :each do
    put(api_start_pair_path(port1: 3001, port2: 3002, mode: 'smart'))
    sleep(3)
  end

  after :each do
    put(api_stop_pair_path(port1: 3001, port2: 3002))
    sleep(1)
  end

  context 'should send 10 bytes' do
    it 'send array' do
      s1 = TCPSocket.open('127.0.0.1', 3001)
      s2 = TCPSocket.open('127.0.0.1', 3002)

      result = nil

      thread = Thread.new do
        result = s2.recv(100)
      end

      s1.write([0x03, 0x00, 0x00, 0x16,
                0x11, 0xE0, 0x00, 0x00, 0x00,
                0x01, 0x00, 0xC1, 0x02, 0x02,
                0x02, 0xC2, 0x02, 0x02, 0x02,
                0xC0, 0x01, 0x0A ].pack('C*'))
      thread.join
      expect(result).to eq([0x03, 0x00, 0x00, 0x16,
                            0x11, 0xE0, 0x00, 0x00, 0x00,
                            0x01, 0x00, 0xC1, 0x02, 0x02,
                            0x02, 0xC2, 0x02, 0x02, 0x02,
                            0xC0, 0x01, 0x0A ].pack('C*'))
    end
  end
end

