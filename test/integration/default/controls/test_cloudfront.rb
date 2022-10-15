# frozen_string_literal: true

include_controls 'inspec-aws'

require './test/library/common'

tfstate = StateFileReader.new

distribution_id = tfstate.read['outputs']['cloudfront']['value']['cloudfront_distribution_id'].to_s
control 'default' do
  describe aws_cloudfront_distribution(distribution_id) do
    it { should exist }
    it { should have_s3_origin_configs }
    its('viewer_certificate_minimum_ssl_protocol') { should_not match /SSLv3|TLSv1$|TLSv1_2016/ }
    its('viewer_protocol_policies') { should_not include 'allow-all' }
    it { should_not have_viewer_protocol_policies_allowing_http }
    it { should_not have_disallowed_custom_origin_ssl_protocols }
    it { should_not have_disallowed_viewer_certificate_minimum_ssl_protocol }
  end
end
