require 'spec_helper'
require 'bosh/dev/sandbox/postgresql'

module Bosh::Dev::Sandbox
  describe Postgresql do
    subject(:postgresql) { described_class.new('fake_db_name', runner, logger, options) }
    let(:runner) { instance_double('Bosh::Core::Shell') }
    let(:options) do
      {
        username: 'my-pguser',
        password: 'my-pgpassword',
        host: 'pg-host',
        port: 9922,
        ca_path: '/path-to-ca',
        tls_enabled: true
      }
    end

    describe 'defaults' do
      it 'has default values set' do
        db = described_class.new('fake_db_name', runner, logger)
        expect(db.username).to eq('postgres')
        expect(db.password).to eq('')
        expect(db.host).to eq('localhost')
        expect(db.port).to eq(5432)
        expect(db.ca_path).to be_nil
        expect(db.tls_enabled).to eq(false)
      end
    end

    describe '#create_db' do
      it 'creates a database' do
        expect(runner).to receive(:run).with(
          %Q{PGPASSWORD=my-pgpassword psql -h pg-host -p 9922 -U my-pguser -c 'create database "fake_db_name";' > /dev/null 2>&1})
        postgresql.create_db
      end
    end

    describe '#drop_db' do
      it 'drops a database' do
        expect(runner).to receive(:run).with(
          %Q{echo 'revoke connect on database "fake_db_name" from public; drop database "fake_db_name";' | PGPASSWORD=my-pgpassword psql -h pg-host -p 9922 -U my-pguser > /dev/null 2>&1})
        postgresql.drop_db
      end
    end

    describe '#dump_db' do
      it 'dumps the database' do
        expect(runner).to receive(:run).with(
          %Q{PGPASSWORD=my-pgpassword pg_dump -h pg-host -p 9922 -U my-pguser -s "fake_db_name"})
        postgresql.dump_db
      end
    end

    describe '#describe_db' do
      it 'describes database tables' do
        expect(runner).to receive(:run).with(
          %Q{PGPASSWORD=my-pgpassword psql -h pg-host -p 9922 -U my-pguser -d "fake_db_name" -c '\\d+ public.*'})
        postgresql.describe_db
      end
    end

    describe '#connection_string' do
      it 'returns a configured string' do
        expect(subject.connection_string).to eq('postgres://my-pguser:my-pgpassword@pg-host:9922/fake_db_name')
      end
    end

    describe '#db_name' do
      it 'returns the configured database name' do
        expect(subject.db_name).to eq('fake_db_name')
      end
    end

    describe '#username' do
      it 'returns the configured username' do
        expect(subject.username).to eq('my-pguser')
      end
    end

    describe '#password' do
      it 'returns nil' do
        expect(subject.password).to eq('my-pgpassword')
      end
    end

    describe '#adapter' do
      it 'has the correct database adapter' do
        expect(subject.adapter).to eq('postgres')
      end
    end

    describe '#port' do
      it 'has the correct port' do
        expect(subject.port).to eq(9922)
      end
    end

    describe '#ca_path' do
      it 'has the correct ca_path' do
        expect(subject.ca_path).to eq('/path-to-ca')
      end
    end

    describe '#tls_enabled' do
      it 'has the correct tls_enabled' do
        expect(subject.tls_enabled).to eq(true)
      end
    end
  end
end
