require 'spec_helper'

RSpec.describe BrickFTP::API::File, type: :lib do
  before { BrickFTP.config.api_key = 'xxxxxxxx' }

  describe '.find' do
    subject { described_class.find('Engineering Candidates/John Smith.docx', params: params) }

    let(:params) { {} }
    let(:file) do
      {
        "id" => 1,
        "path" => "Engineering Candidates/John Smith.docx",
        "type" => "file",
        "size" => 61440,
        "mtime" => "2014-05-15T18:34:51+00:00",
        "crc32" => "f341cc60",
        "md5" => "b67236f5bcd29d1307d574fb9fe585b5",
        "download_uri" => "https://s3.amazonaws.com/objects.brickftp.com/metadata/1/84c6ecd0-be8d-0131-dd53-12b5580f0798?AWSAccessKeyId=AKIAIEWLY3MN4YGZQOWA&Signature=8GtrTVcKyPXrchpieNII%2Fo8DzMU%3D&Expires=1400217125&response-content-disposition=attachment;+filename=%22John+Smith.docx%22",
        "provided_mtime" => "2014-05-15T18:34:51+00:00",
        "permissions" => "rwd",
      }
    end

    context 'exists' do
      context 'without query action=stat' do
        before do
          stub_request(:get, 'https://koshigoe.brickftp.com/api/rest/v1/files/Engineering+Candidates%2FJohn+Smith.docx')
            .with(basic_auth: ['xxxxxxxx', 'x'])
            .to_return(body: file.to_json)
        end

        it 'return instance of BrickFTP::API::File' do
          is_expected.to be_an_instance_of BrickFTP::API::File
        end

        it 'set attributes' do
          file = subject
          expect(file.id).to eq 1
          expect(file.path).to eq "Engineering Candidates/John Smith.docx"
          expect(file.type).to eq "file"
          expect(file.size).to eq 61440
          expect(file.mtime).to eq "2014-05-15T18:34:51+00:00"
          expect(file.crc32).to eq "f341cc60"
          expect(file.md5).to eq "b67236f5bcd29d1307d574fb9fe585b5"
          expect(file.download_uri).to eq "https://s3.amazonaws.com/objects.brickftp.com/metadata/1/84c6ecd0-be8d-0131-dd53-12b5580f0798?AWSAccessKeyId=AKIAIEWLY3MN4YGZQOWA&Signature=8GtrTVcKyPXrchpieNII%2Fo8DzMU%3D&Expires=1400217125&response-content-disposition=attachment;+filename=%22John+Smith.docx%22"
          expect(file.provided_mtime).to eq '2014-05-15T18:34:51+00:00'
          expect(file.permissions).to eq 'rwd'
        end
      end

      context 'with query action=stat' do
        let(:params) { { action: 'stat' } }

        before do
          file.delete('download_uri')
          stub_request(:get, 'https://koshigoe.brickftp.com/api/rest/v1/files/Engineering+Candidates%2FJohn+Smith.docx?action=stat')
            .with(basic_auth: ['xxxxxxxx', 'x'])
            .to_return(body: file.to_json)
        end

        it 'return instance of BrickFTP::API::File' do
          is_expected.to be_an_instance_of BrickFTP::API::File
        end

        it 'set attributes' do
          file = subject
          expect(file.id).to eq 1
          expect(file.path).to eq "Engineering Candidates/John Smith.docx"
          expect(file.type).to eq "file"
          expect(file.size).to eq 61440
          expect(file.mtime).to eq "2014-05-15T18:34:51+00:00"
          expect(file.crc32).to eq "f341cc60"
          expect(file.md5).to eq "b67236f5bcd29d1307d574fb9fe585b5"
          expect(file.download_uri).to be_nil
          expect(file.provided_mtime).to eq '2014-05-15T18:34:51+00:00'
          expect(file.permissions).to eq 'rwd'
        end
      end
    end

    context 'not exists' do
      before do
        stub_request(:get, 'https://koshigoe.brickftp.com/api/rest/v1/files/Engineering+Candidates%2FJohn+Smith.docx')
          .with(basic_auth: ['xxxxxxxx', 'x'])
          .to_return(body: '[]')
      end

      it 'return nil' do
        is_expected.to be_nil
      end
    end
  end

  describe '#destroy' do
    context 'single file' do
      subject { file.destroy }

      let(:file) { described_class.new(path: 'Engineering Candidates/John Smith.docx') }

      before do
        stub_request(:delete, 'https://koshigoe.brickftp.com/api/rest/v1/files/Engineering+Candidates%2FJohn+Smith.docx')
          .with(basic_auth: ['xxxxxxxx', 'x'])
          .to_return(body: '[]')
      end

      it 'return true' do
        is_expected.to eq true
      end
    end

    context 'recursive' do
      subject { file.destroy(recursive: true) }

      let(:file) { described_class.new(path: 'Engineering Candidates') }

      before do
        stub_request(:delete, 'https://koshigoe.brickftp.com/api/rest/v1/files/Engineering+Candidates')
          .with(basic_auth: ['xxxxxxxx', 'x'], headers: { 'Depth' => 'infinity' })
          .to_return(body: '[]')
      end

      it 'return true' do
        is_expected.to eq true
      end
    end
  end
end
