require 'puppetx/filemapper'
require 'yaml'

Puppet::Type.type(:fact).provide(:fact) do

  desc "The fact provider to create structured custom facts"


  @unlink_empty_files = true

  include PuppetX::FileMapper

  def select_file
    "/etc/facter/facts.d/#{@resource[:name]}.yaml"
  end

  def self.target_files
    Dir["/etc/facter/facts.d/*.yaml"]
  end

  def self.parse_file(filename, contents)
    return [{}] if contents.nil?

    result = {}
    result[:name] = File.basename(filename, ".yaml")
    begin
      result[:content] = YAML.load(contents).values[0]
    rescue
      result[:content] = contents
    end
    return [result]
  end

  def self.format_file(filename, providers)
    return "" if providers.empty?

    result = ""
    provider = providers.is_a?(Array) ? providers.last : providers
    basename = File.basename(filename, ".yaml")

    provider_content = provider.content
    
    prov_result = munge(provider_content)

    if not prov_result.nil? and not prov_result.empty?
      if provider.ensure == :present and provider.name == basename
        result = { provider.name => prov_result }.to_yaml
      end
    end

    return result
  end

  def self.munge(provider_content)
    if not provider_content.nil?
      if provider_content.is_a?(Array)
        if provider_content[1].nil? 
          if provider_content[0].is_a?(Hash)
            prov_result = provider_content[0]
          else
            prov_result = provider_content[0].to_s
          end
        else
          prov_result = provider_content
        end
      elsif provider_content.is_a?(Hash)
        prov_result = provider_content
      else
        prov_result = provider_content
      end
    end
  end

end
