require 'rails_helper'
require "awesome_print"

RSpec.describe "ApiControllers", type: :request do
  describe 'api_health_check' do
    subject { get(api_health_check_path) }
    let(:parsed_response) { JSON.parse(response.body).deep_symbolize_keys }

    context 'ENV[PAIRS_OF_SERVERS ] empty' do
      before :each do
        subject
        ap(parsed_response)
      end

      it { expect(response).to have_http_status(200) }
      it { expect(parsed_response[:status]).to eq('Ok') }
      it { expect(parsed_response[:tcp_server_controls_qu]).to eq(0) }
      it { expect(parsed_response[:threads_qu]).to eq(1) }
      it { expect(parsed_response[:message]).to eq('') }
      it { expect(parsed_response[:pairs]).to eq([]) }
    end

    # context 'ENV[PAIRS_OF_SERVERS ] set one pair in dumb mode' do
    #   before :each do
    #     allow(ENV).to receive(:[]).with("PAIRS_OF_SERVERS").and_return('[{\'pair\': [3001, 3002], \'mode\': \'dumb\'}]')
    #     subject
    #   end
    #
    #   it { expect(response).to have_http_status(200) }
    #   it { expect(parsed_response[:status]).to eq('Ok') }
    #   it { expect(parsed_response[:tcp_server_controls_qu]).to eq(0) }
    #   it { expect(parsed_response[:threads_qu]).to eq(1) }
    #   it { expect(parsed_response[:message]).to eq('') }
    #   it { expect(parsed_response[:pairs]).to eq([]) }
    # end
  end

  describe 'start_pair' do
    after :each do
      $tcp_server_controls.each do |tcp_server_control|
        tcp_server_control.stop
        $tcp_server_controls.delete(tcp_server_control)
      end
    end

    context 'right parameters' do
      subject { put(api_start_pair_path(port1: 3001, port2: 3002, mode: 'dumb')) }
      let(:parsed_response) { JSON.parse(response.body).deep_symbolize_keys }

      it 'should return 200' do
        subject
        expect(response).to have_http_status(200)
      end

      it 'should return message = Ok' do
        subject
        expect(parsed_response[:message]).to eq('Ok')
      end

      it { expect{ subject }.to change($tcp_server_controls, :count).by(1) }

      context 'request for existing pair' do

        it 'should does not do for existing pair 1' do
          put(api_start_pair_path(port1: 3001, port2: 3002, mode: 'dumb'))
          put(api_start_pair_path(port1: 3001, port2: 3002, mode: 'dumb'))

          expect(response).to have_http_status(400)
          expect(parsed_response[:message]).to eq('The port number 3001 already used')
        end

        it 'should does not do for existing pair 2' do
          put(api_start_pair_path(port1: 3001, port2: 3002, mode: 'dumb'))
          put(api_start_pair_path(port1: 3004, port2: 3002, mode: 'dumb'))

          expect(response).to have_http_status(400)
          expect(parsed_response[:message]).to eq('The port number 3002 already used')
        end
      end
    end

    context 'wrong parameters' do
      subject { put(api_start_pair_path()) }
      let(:parsed_response) { JSON.parse(response.body).deep_symbolize_keys }

      before :each do
        subject
        ap(parsed_response)
      end

      it { expect(response).to have_http_status(400) }
      it { expect(parsed_response[:message]).to eq('param is missing or the value is empty: port1') }
    end
   end

  describe 'stop_pair' do
    subject { put(api_stop_pair_path(port1: 3001, port2: 3002, mode: 'dumb')) }
    let(:parsed_response) { JSON.parse(response.body).deep_symbolize_keys }

    after :each do
      $tcp_server_controls.each do |tcp_server_control|
        tcp_server_control.stop
        $tcp_server_controls.delete(tcp_server_control)
      end
    end

    context 'when pair does not exist' do
      it 'should return bad_request' do
        subject

        expect(response).to have_http_status(400)
        expect(parsed_response[:message]).to eq('Don`t find the pair of ports')
      end
    end
  end
end
