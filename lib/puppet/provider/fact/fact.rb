require 'puppetx/filemapper'
require 'yaml'

Puppet::Type.type(:fact).provide(:fact) do

  desc "The fact provider to create structured custom facts"


  @unlink_empty_files = true

#  def self.instances
#    #puts "FACT INSTANCES"
#    provider_hashes = load_all_providers_from_disk
#
#    provider_hashes.map do |h|
#      h.merge!({:provider => self.name, :ensure => :present})
#      new(h)
#    end
#
#  rescue
#    # If something failed while loading instances, mark the provider class
#    # as failed and pass the exception along
#    @failed = true
#    raise
#  end

  def self.prefetch(resources = {})
    #puts "FACT PREFETCH"

    # generate hash of {provider_name => provider}
    providers = instances.inject({}) do |hash, instance|
      hash[instance.name] = instance
      hash
    end
    puts "FACT PREFETCH, providers: #{providers}"
    #puts "FACT PREFETCH, resources: #{resources}"

    # For each prefetched resource, try to match it to a provider
    resources.each_pair do |resource_name, resource|
      puts "FACT PREFETCH, checking, res_name: #{resource_name} - res: #{resource.to_s}"
      puts "FACT PREFETCH, checking, resource[:name]: #{resource[:name]}"
      puts "FACT PREFETCH, checking, resource[:content]: #{resource[:content]}"
      #working#resource_name_res = select_file(resource).include?(resource_name) ? select_file(resource) : resource_name
      resource_name_res = select_file(resource).include?(resource_name) ? select_file(resource) : resource_name
      puts "Checking #{resource} to see if resource_name_res is: #{select_file(resource)} or #{resource_name}"
      #resource_name_res = select_file.include?(resource_name) ? select_file : resource_name
      #puts "FACT PREFETCH, checking2, providers[#{resource_name}]: #{providers[resource_name_res]}"
      #puts "FACT PREFETCH, checking3, providers[#{resource_name_res}]: #{providers[resource_name_res]}"
      if provider = providers[resource_name_res]
        puts "FACT PREFETCH, found provider: #{provider}"
        puts "FACT PREFETCH, found provider-: #{provider.content}"
        resource.provider = provider
      elsif provider = providers[resource_name]
        puts "FACT PREFETCH, found provider2: #{provider}"
        resource.provider = provider
      else
        puts "FACT PREFETCH, NO PROVIDER FOUND"
      end
      #if provider = providers[resource_name]
      #  resource.provider = provider
      #end
    end
  end


  def self.instances
    puts "FACT INSTANCES"
    puts self.name
    puts @property_hash
    puts "Finish INSTANCES"
    provider_hashes = load_all_providers_from_disk

    provider_hashes.map do |h|
      h.merge!({:provider => self.name, :ensure => :present})
      new(h)
    end

  rescue
    # If something failed while loading instances, mark the provider class
    # as failed and pass the exception along
    @failed = true
    raise
  end
#
#
#  def self.prefetch(resources)
##    debug("[prefetch(resources)]")
##    Puppet.debug "Facter prefetch instance: #{instances}"
##    puts "Facter prefetch instance: #{instances}"
#    instances.each do |prov|
#      Puppet.debug "facter prefetch instance resource: (#{prov.name})"
#      puts "facter prefetch instance resource: (#{prov.name})"
#      @provider_name = prov.name
##      super
#      if resource = resources[prov.name]
#        puts "prefetch resource provider #{resource.provider}"
#        resource.provider = prov
#      end
#    end
#    #puts "#{instances}"
##    instances.each do |prov|
##      @provider_name = prov.name
##    end
##    super
#  end
#  def self.content
#    puts "Called SELF CONTENT"
#    []
#  end
#
#  def content
#    puts "Called CONTENT"
#    []
#  end
#
#  def target
#    puts "target method: #{resource} - #{@property_hash}"
#    []
#  end


#  def namevar(name, setting)
#    puts "namevar NAME: #{name}, SETTING: #{setting}"
#  end

#  def create
#    raise Puppet::Error, "#{self.class} is in an error state" if self.class.failed?
#    @resource.class.validproperties.each do |property|
#      puts "create property: #{property}"
#      if value = @resource.should(property)
#        @property_hash[property] = value
#      end
#    end
#
#    self.dirty!
#  end

#  def prepare_properties
#    @resource.class.validproperties.each do |property|
#      puts "prepare properties: #{property}"
#      if value = @resource.should(property)
#        @property_hash[property] = value
#      end
#    end
#  end


#  def prepare_content(content)
#    if content[1].nil?
#      if content[0].is_a?(Hash)
#        puts "HASH!"
#        prov_result = [content[0]]
#        puts prov_result
#        return prov_result
#      else
#        puts "ONLY A STRING or SINGLE ARRAY VALUE"
#        prov_result = content[0].to_s
#        return prov_result
#      end
#    else
#      puts "FULL ON ARRAY"
#      prov_result = content
#      return prov_result
#    end
#  end

  include PuppetX::FileMapper

#  def exists?
#    #puts "LOCAL EXISTS called: #{@property_hash} - #{resource[:content]}"
#    #puts "LOCAL EXISTS cont: #{resource[:name]} - #{resource[:target]}"
#    #puts "LOCAL EXISTS content: #{content}"
#    #prepare_properties
##    @property_hash[:content] = prepare_content(resource[:content])
##    @resource.class.validproperties.each do |property|
##      puts "create property: #{property}"
##      if value = @resource.should(property)
##        puts "create should property: #{value}"
##        puts "create is property: #{@resource[:content]}"
##        #@property_hash[property] = value
##      end
##    end
##
##    @property_hash[:target] ||= resource[:target]
#    #@property_hash[:exists] = File.exist?(select_file)
#    #puts "LOCAL EXISTS file: #{@property_hash[:exists]}"
#    #puts "LOCAL EXISTS ensure: #{@property_hash[:ensure]}"
#    @property_hash[:ensure] and @property_hash[:ensure] == :present
#  end

#  def create
#    format_file
#  end

  def self.select_file(resource)
    #puts "SELF SELECT_FILE prov_name: #{@provider_name}"
    puts "SELF SELECT_FILE #{resource[:target]}"
    "/etc/facter/facts.d/#{resource[:target]}.yaml"
    #"#{@property_hash[:target]}"
  end

  # Not used right now but REQUIRED by FILEMAPPER
  # Not used because we moved prefetch & instances along with select file, into our class
  def select_file
#    puts "SELECT_FILE name: #{@property_hash[:name]} - target: #{@property_hash[:target]}"
    #"/etc/facter/facts.d/#{@property_hash[:target]}.yaml"
    "/etc/facter/facts.d/#{@resource[:target]}.yaml"
    #"#{@property_hash[:target]}"
  end

#  # This allows us to conventiently look up existing status with properties[:foo].
#  def properties
#    if @property_hash.empty?
#      @property_hash[:ensure] = :absent
#    end
#    puts "properties: #{@property_hash}"
#    @property_hash.dup
#  end

  def self.target_files
    #puts "target_files, prop_hash: #{@property_hash}"
    #puts "target_files, prov_name: #{@provider_name}"
    #puts "target_files, resources: #{@resources}"
    ##Dir["/etc/facter/facts.d/*.yaml"]
    #puts "Target: #{@provider_name}"
#    resources.each do |prov|
#      puts "Target: #{prov.name}"
#    end

    Dir["/etc/facter/facts.d/*.yaml"]
  end

  def self.parse_file(filename, contents)
    puts "reached parse_file"
    #return [{}] if filename != "/etc/facter/facts.d/#{@property_hash[:target]}.yaml"
    return [{}] if contents.nil?
    puts filename
#
#    result = {}
#    re = /^(.+?)=(.+)$/
#    line = contents.lines.first
#    line = "" if line.nil?
#
#    if match_data = re.match(line.chomp)
#      result[:name] = match_data[1]
#      result[:content] = match_data[2]
#      result[:target] = File.basename(filename, ".yaml")
#    end
#
#    return [result]
    result = {}
    #result[:name] = filename
    result[:name] = File.basename(filename, ".yaml")
    begin
      result[:content] = YAML.load(contents).values[0]
    rescue
      result[:content] = contents
    end
    #result[:content] = YAML.load(contents)
    result[:target] = File.basename(filename, ".yaml")
    #puts result
    return [result]
  end

  def self.format_file(filename, providers)
    #puts "reached format_file"
    return "" if providers.empty?

    result = ""
    provider = providers.is_a?(Array) ? providers.last : providers
    basename = File.basename(filename, ".yaml")

    #provider_names = providers.map(&:name)

    #puts "format_file providers: #{provider_names}"
    #puts "format_file prov: #{provider}"
    provider_content = provider.content
    #puts "format_file prov.content: #{provider_content}"
    
    prov_result = ""
    if not provider_content.nil?
      if provider_content.is_a?(Array)
        if provider_content[1].nil? 
          if provider_content[0].is_a?(Hash)
#            puts "HASH!"
            prov_result = provider_content[0]
#            puts prov_result
          else
#            puts "ONLY A STRING or SINGLE ARRAY VALUE"
            prov_result = provider_content[0].to_s
          end
        else
#          puts "FULL ON ARRAY"
          prov_result = provider_content
        end
      elsif provider_content.is_a?(Hash)
#        puts "HASH only"
        prov_result = provider_content
      else
#        puts "NOT ARRAY OR HASH"
        prov_result = provider_content
      end
    end
    #if not provider.content.nil?
    #  if provider.content[1].nil? 
    #    if provider.content[0].is_a?(Hash)
    #      puts "HASH!"
    #      prov_result = provider.content[0]
    #      puts prov_result
    #    else
    #      puts "ONLY A STRING or SINGLE ARRAY VALUE"
    #      prov_result = provider.content[0].to_s
    #    end
    #  else
    #    puts "FULL ON ARRAY"
    #    prov_result = provider.content
    #  end
    #end
    #puts "provider.target #{provider.target} - #{basename}"

    if provider.ensure == :present and provider.target == basename
      result = { provider.target => prov_result }.to_yaml
      p "format_file result: #{result}"
      #result = "#{provider.name}=#{provider.content}\n"
    end

    return result
  end
end
