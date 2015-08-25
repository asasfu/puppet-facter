require 'puppetx/filemapper'
require 'yaml'

Puppet::Type.type(:fact).provide(:fact) do

  desc "The fact provider to create structured custom facts"

  include PuppetX::FileMapper
  @unlink_empty_files = true
  class << self
    attr_accessor :is_managed
  end

  def select_file
    # TODO. Should move this method into prefetch or instances so it's only called once
    begin
      res = @resource.catalog #.resource('resources', 'fact')
      if res
#        res2 = res.resource('resources', 'fact')
#        puts "select_file: resource -#{res2}-"
#        res3 = res2[:purge]
#        puts "select_file: res3purge -#{res3}-"
        self.class.is_managed = true if res.resource('resources', 'fact')[:purge] == true
      end
    rescue
    end
    #puts "select_file: resource.inspect -#{@resource[:check_for_purge_unmanaged].inspect}-"
    #puts "select_file: resource param -#{@resource.parameter('["Fact", "trusted_string"]')}-"
    ##puts "select_file: param -#{@resource.parameter('["Fact", "trusted_string"]').value}-"
    ##puts "select_file: param2 -#{@resource.parameter('check_for_purge_unmanaged').value}-"
    #puts "select_file: param2 -#{@resource.parameter('name').value}-"
    ##puts "select_file: resource -#{@resource.parameters}-"
    #puts "select_file: param -#{@resource[:check_for_purge_unmanaged]}-"
    #puts "select_file: is_managed -#{self.class.is_managed}-"
#    keys = @resource.parameters.keys
#    keys.each do |key|
#      begin
#        value = @resource.parameters[key].value ? @resource.parameters[key].value : @resource.parameters[key].should
#      rescue
#      end
#      #value = @resource.parameters[key].instance_variable_get(:@value) ? @resource.parameters[key].instance_variable_get(:@value) : @resource.parameters[key].instance_variable_get(:@should)
#      puts "Param for key: #{key} is: #{value}"
#    end
#    names = @resource.parameters[:name].instance_variable_get(:@value)
#    puts "select_file: keys -#{keys}-"
#    puts "select_file: name -#{names}-"
#    puts "select_file: managed? -#{@resource.managed?}-"
#    self.class.is_managed = true if @resource[:check_for_purge_unmanaged] == true
    begin
      basename = @resource[:name]
    rescue
      begin
        basename = @property_hash[:name]
        filename = "/etc/facter/facts.d/#{basename}.yaml"
        puts "Found clashing fact file, deleting it, whether managing it or not #{filename}"
        File.delete(filename) if File.exist?(filename)
      rescue
        fail "Fact set failed, you must have a duplicate fact in your external facts directory.\n Check inside the YAML files for a matching root fact"
      end
    end
    if not basename
      fail "Fact set failed, you must have a duplicate fact in your external facts directory.\n Check inside the YAML files for a matching root fact\n Duplicate fact is most likely inside the file: #{@property_hash[:name]}.yaml"
    end
    "/etc/facter/facts.d/#{basename}.yaml"
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
    header_folder if is_managed == true

    return "" if providers.empty?
    return "" if not collect_absent_providers_for_file(filename).empty?

    result_arr = []
    provider = providers.is_a?(Array) ? providers.last : providers
    basename = File.basename(filename, ".yaml")

    provider_content = provider.content
    
    prov_result = munge(provider_content)

    if not prov_result.nil? and not prov_result.empty?
      if provider.ensure == :present and provider.name == basename
        result_arr << header_file
        result_arr << { provider.name => prov_result }.to_yaml
      end
    end

    return result_arr.join("\n") unless result_arr.empty?
    return ""
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

  def self.collect_absent_providers_for_file(filename)
    @all_providers.select do |provider|
      provider.select_file == filename and provider.ensure == :absent
    end
  end

  def self.header_folder
    puts "Write method to make the managed by puppet file in the facts.d dir"
  end

  def self.header_file
    header = <<-HEADER
# HEADER: This file is being managed by puppet. 
# Note. The folder's YAML files may be managed by puppet as well if a '##MANAGED_BY_PUPPET' file exists in this folder
# HEADER: External facts (facts.d) that are not being managed by puppet may be removed automatically.
# HEADER: Last generated at: #{Time.now}
HEADER
    header
  end
end
