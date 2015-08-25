Puppet::Type.newtype(:fact) do
  @doc = "Create a custom fact as text file under /etc/facter/facts.d
      fact { 'environment':
        content => 'production',
        target  => 'env',
      }"

  ensurable do
    defaultvalues
    defaultto do
      if @resource.managed?
        :present
      else
        nil
      end
    end
  end

  newparam(:name, :namevar => true) do
    desc "The fact name"

    validate do |value|
      fail("Name cannot be empty or whitespace") if value.match(/^\s*$/)
      fail("Name cannot contain a path, only alphanumeric including underscores and dashes") if value.match(/\//)
    end
  end

  newproperty(:content, :array_matching => :all) do
    desc "The fact's value, this is the result received if you run `facter fact_name` or have $::fact_name"

    def is_yaml_to_hash(is)
      begin
        YAML.load(is).values[0]
      rescue
        is
      end
    end

    def munging(value)
      if value.is_a?(Array)
        if value[1].nil?
          if value[0].is_a?(Hash)
            prov_result = value[0]
            return prov_result
          else
            prov_result = value[0].to_s
            return prov_result
          end
        else
          prov_result = value
          return prov_result
        end
      elsif value.is_a?(Hash)
        return value
      else
        value_hash = is_yaml_to_hash(value)
        value_hash = value if value_hash.nil? || value_hash.empty? 
      end
      return value_hash
    end

    validate do |value|
      if value.is_a?(Hash)
        fail("Content cannot be empty or whitespace") if value.empty?
      else
        fail("Content cannot be empty or whitespace") if munge(value).match(/^\s*$/)
      end
    end

    munge do |value|
      munging(value)
    end

    def should_to_s(s)
      munging(s)
    end
    
    def insync?(is)
      result = is_yaml_to_hash(is)
      result.is_a?(Array) ? super(result) : super([result])
    end
  end

  #Not meant to be implemented directly by people, rather it's meant to be used in a class as
  # $purge_unmanaged = true
  # resources { 'fact': purge => $purge_unmanaged }
  # Fact { check_for_purge_unmanaged => $purge_unmanaged }
  newparam(:check_for_purge_unmanaged) do
    desc "This parameter will define whether or not to check for a resources { 'fact': purge => true } 
    It is not meant to be implemented directly by people against fact { } resource,
    rather it's meant to be used in a class as:

    $purge_unmanaged = true
    resources { 'fact': purge => $purge_unmanaged }
    Fact { check_for_purge_unmanaged => $purge_unmanaged }i
    "

    defaultto { false }
  end

  autorequire :file do
    "/etc/facter/facts.d/#{self[:name]}.yaml"
  end

end
