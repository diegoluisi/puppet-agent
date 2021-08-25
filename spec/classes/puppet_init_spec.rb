require 'spec_helper'

describe 'puppet', :type => :class do
  let(:facts) { { :concat_basedir => '/var/lib/puppet/concat', :osfamily => 'RedHat', :operatingsystemmajrelease => '7', :id => '0', :path => '/bin', :kernel => 'Linux' } }

  it { should create_class('puppet') }

  context 'default' do
    it { should contain_class('puppet::common') }
    it { should contain_class('puppet::agent') }
    it { should contain_class('puppet::server') }
  end

  describe 'error handling' do
    context 'bad use_srv_records' do
      let(:params) { { :use_srv_records => 'breakme' } }
      it { expect { should create_class('puppet') }.to raise_error(/to have type Boolean/) }
    end

    context 'bad puppetdb' do
      let(:params) { { :puppetdb => 'breakme' } }
      it { expect { should create_class('puppet') }.to raise_error(/to have type Boolean/) }
    end

    context 'bad server_ca_enabled' do
      let(:params) { { :server_ca_enabled => 'breakme' } }
      it { expect { should create_class('puppet') }.to raise_error(/to have type Boolean/) }
    end

    context 'bad runmode' do
      let(:params) { { :runmode => 'breakme' } }
      it { expect { should create_class('puppet') }.to raise_error(/to have type Enum\['cron', 'service', 'none'\]/) }
    end

    context 'bad puppetdb_port' do
      let(:params) { { :puppetdb_port => 'breakme' } }
      it { expect { should create_class('puppet') }.to raise_error(/to have type Integer/) }
    end

    context 'puppetdb, no server' do
      let(:params) { { :puppetdb => true } }
      it { expect { should create_class('puppet') }.to raise_error(/puppetdb_server is required/) }
    end

    context 'bad fileserver_conf' do
      let(:params) { { :fileserver_conf => 'breakme' } }
      it { expect { should create_class('puppet') }.to raise_error(/to have type Optional\[Hash\[String/) }
    end

  end

end
